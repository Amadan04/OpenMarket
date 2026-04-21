package main

import (
	"fmt"
	"log"
	"math/rand"
	"openmarket/database"
	"openmarket/models"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	godotenv.Load("../../.env")
	godotenv.Load(".env")
	database.Connect()
	database.DB.AutoMigrate(&models.User{}, &models.Listing{}, &models.Review{}, &models.Favorite{}, &models.Message{})

	// Users
	users := []struct{ name, email, pass string }{
		{"Ahmed Al-Mansoori", "ahmed@example.com", "password123"},
		{"Sara Hassan", "sara@example.com", "password123"},
		{"Mohammed Ali", "mohammed@example.com", "password123"},
	}

	var createdUsers []models.User
	for _, u := range users {
		hash, _ := bcrypt.GenerateFromPassword([]byte(u.pass), bcrypt.DefaultCost)
		user := models.User{Name: u.name, Email: u.email, Password: string(hash)}
		if err := database.DB.Where("email = ?", u.email).FirstOrCreate(&user).Error; err == nil {
			createdUsers = append(createdUsers, user)
			fmt.Printf("User: %s (%s / %s)\n", u.name, u.email, u.pass)
		}
	}

	if len(createdUsers) == 0 {
		log.Fatal("No users created")
	}

	// Listings
	listings := []struct {
		title, desc, category, location string
		price                           float64
		lat, lng                        float64
		images                          []string
	}{
		{"Vintage Leica M6 Camera", "Excellent condition, comes with 50mm lens and original case.", "Electronics", "Manama", 850, 26.2235, 50.5876, []string{"https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400"}},
		{"Mid-Century Teak Desk", "Beautiful 1960s Danish teak desk. Minor scratches on top.", "Furniture", "Riffa", 320, 26.1299, 50.5550, []string{"https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400"}},
		{"Trek FX3 Road Bike", "Barely used, upgraded saddle. Size M. Great for commuting.", "Sports", "Muharraq", 480, 26.2697, 50.6087, []string{"https://images.unsplash.com/photo-1511994298241-608e28f14fde?w=400"}},
		{"iPhone 14 Pro 256GB", "Deep purple, battery health 94%. Comes with box and charger.", "Mobile", "Saar", 620, 26.1897, 50.4912, []string{"https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=400"}},
		{"Eames Lounge Chair Replica", "High quality reproduction in walnut and black leather.", "Furniture", "Adliya", 390, 26.2152, 50.5934, []string{"https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400"}},
		{"Sony WH-1000XM5 Headphones", "Like new, only used twice. Comes with all accessories.", "Electronics", "Juffair", 210, 26.2061, 50.5989, []string{"https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400"}},
		{"Linen Blazer - Size L", "Cream colored, worn twice. Perfect for summer.", "Fashion", "Manama", 45, 26.2235, 50.5876, []string{"https://images.unsplash.com/photo-1594938298603-c8148c4b4057?w=400"}},
		{"MacBook Pro M2 14-inch", "Space gray, 16GB RAM, 512GB SSD. AppleCare until 2025.", 1450, 26.2697, 50.6087, []string{"https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400"}},
		{"Acoustic Guitar - Yamaha F310", "Great starter guitar, comes with case and extra strings.", "Other", "Isa Town", 95, 26.1699, 50.5271, []string{"https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400"}},
		{"Plant Collection - 5 pots", "Mix of succulents and tropical plants. All healthy.", "Other", "Budaiya", 35, 26.2105, 50.4356, []string{"https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400"}},
	}

	for i, l := range listings {
		owner := createdUsers[i%len(createdUsers)]
		category := l.category
		if category == "" {
			category = "Electronics"
		}
		listing := models.Listing{
			Title:       l.title,
			Description: l.desc,
			Price:       l.price,
			Category:    category,
			Location:    l.location,
			Latitude:    l.lat,
			Longitude:   l.lng,
			UserID:      owner.ID,
			Images:      models.StringSlice(l.images),
		}
		database.DB.Create(&listing)
		fmt.Printf("Listing: %s ($%.0f)\n", l.title, l.price)
	}

	// Reviews
	if len(createdUsers) >= 2 {
		comments := []string{
			"Great seller, very responsive!",
			"Item exactly as described. Smooth transaction.",
			"Fast pickup, item in perfect condition.",
			"",
		}
		for i := 0; i < 4; i++ {
			seller := createdUsers[i%len(createdUsers)]
			reviewer := createdUsers[(i+1)%len(createdUsers)]
			if seller.ID == reviewer.ID {
				continue
			}
			database.DB.Create(&models.Review{
				SellerID:   seller.ID,
				ReviewerID: reviewer.ID,
				Rating:     rand.Intn(2) + 4,
				Comment:    comments[i%len(comments)],
			})
		}
		fmt.Println("Reviews seeded")
	}

	fmt.Println("\nSeed complete!")
	fmt.Println("Login with: ahmed@example.com / password123")
}
