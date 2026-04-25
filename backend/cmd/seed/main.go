package main

import (
	"fmt"
	"log"
	"time"

	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"openmarket/database"
	"openmarket/models"
)

// ─── Helpers ─────────────────────────────────────────────────────────────────

func hashpw(s string) string {
	b, _ := bcrypt.GenerateFromPassword([]byte(s), 10)
	return string(b)
}

func f64(v float64) *float64 { return &v }
func uid(v uint) *uint       { return &v }

func daysAgo(d int) time.Time {
	return time.Now().Add(-time.Duration(d) * 24 * time.Hour)
}

func imgs(ids ...string) models.StringSlice {
	const base = "https://images.unsplash.com/photo-"
	s := make(models.StringSlice, len(ids))
	for i, id := range ids {
		s[i] = base + id + "?w=800&q=80&auto=format&fit=crop"
	}
	return s
}

// ─── Main ────────────────────────────────────────────────────────────────────

func main() {
	godotenv.Load()
	db := database.Connect()

	wipe(db)

	users := seedUsers(db)
	listings := seedListings(db, users)
	seedReviews(db)
	seedOffers(db)
	seedFavorites(db)
	seedMessages(db)
	seedReports(db)
	seedBlocks(db)

	_ = listings
	fmt.Println("\n✅  OpenMarket seeded successfully.")
}

func wipe(db *gorm.DB) {
	for _, tbl := range []string{
		"blocks", "reports", "messages", "favorites",
		"offers", "reviews", "listings", "users",
	} {
		db.Exec("DELETE FROM " + tbl)
		db.Exec("DELETE FROM sqlite_sequence WHERE name='" + tbl + "'")
	}
	log.Println("🗑  All tables wiped")
}

// ─── Users ───────────────────────────────────────────────────────────────────
// All accounts use password: password123

func seedUsers(db *gorm.DB) []models.User {
	pw := hashpw("password123")
	users := []models.User{
		{ID: 1, Name: "Ahmed Al-Mansoori", Email: "ahmed@openmarket.bh", Password: pw, CreatedAt: daysAgo(120)},
		{ID: 2, Name: "Sara Al-Khalid", Email: "sara@openmarket.bh", Password: pw, CreatedAt: daysAgo(110)},
		{ID: 3, Name: "Mohammed Al-Dosari", Email: "mohammed@openmarket.bh", Password: pw, CreatedAt: daysAgo(105)},
		{ID: 4, Name: "Fatima Al-Amin", Email: "fatima@openmarket.bh", Password: pw, CreatedAt: daysAgo(95)},
		{ID: 5, Name: "Yusuf Al-Bahrani", Email: "yusuf@openmarket.bh", Password: pw, CreatedAt: daysAgo(88)},
		{ID: 6, Name: "Noor Al-Hassan", Email: "noor@openmarket.bh", Password: pw, CreatedAt: daysAgo(80)},
		{ID: 7, Name: "Khalid Al-Rumaihi", Email: "khalid@openmarket.bh", Password: pw, CreatedAt: daysAgo(72)},
		{ID: 8, Name: "Layla Al-Zayani", Email: "layla@openmarket.bh", Password: pw, CreatedAt: daysAgo(65)},
		{ID: 9, Name: "Ibrahim Al-Qahtani", Email: "ibrahim@openmarket.bh", Password: pw, CreatedAt: daysAgo(58)},
		{ID: 10, Name: "Mariam Al-Ansari", Email: "mariam@openmarket.bh", Password: pw, CreatedAt: daysAgo(45)},
	}
	if err := db.Create(&users).Error; err != nil {
		log.Fatal("seedUsers:", err)
	}
	log.Printf("👤  %d users created", len(users))
	return users
}

// ─── Listings ────────────────────────────────────────────────────────────────
// 40 listings across all 9 categories, with realistic Bahrain locations,
// USD pricing, varied view counts, and 2 sold listings.

func seedListings(db *gorm.DB, _ []models.User) []models.Listing {
	listings := []models.Listing{

		// ── Vehicles ──────────────────────────────────────────────────────────
		{
			ID: 1, UserID: 1,
			Title:       "Toyota Land Cruiser 2020 VXR",
			Description: "Well-maintained Land Cruiser VXR in exceptional condition. Single owner, full agency service history at Al-Futtaim Toyota. 7-seater, full leather interior, panoramic sunroof, adaptive cruise control, and 360° camera. Zero accidents — clean chassis. Passing and comprehensive insurance valid until end of 2026. Only selling to upgrade.",
			Price: 33500, Category: "Vehicles", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Like New",
			ViewCount: 847, CreatedAt: daysAgo(90),
			Images: imgs("1549317661-bd32c8ce0db2", "1494976388531-d1058494cdd8"),
		},
		{
			ID: 2, UserID: 3,
			Title:       "Honda Civic 2019 1.5T Sport",
			Description: "Sporty Civic in great condition. 1.5T engine, excellent fuel economy — averaging 14 km/L on highway. Brand new tires installed 3 months ago, fresh oil change. Cold AC, Bluetooth, Apple CarPlay, reverse camera. Minor scratch on the rear bumper (visible in photo, priced accordingly). Ready for immediate transfer.",
			Price: 11200, Category: "Vehicles", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Good",
			ViewCount: 312, CreatedAt: daysAgo(75),
			Images: imgs("1494976388531-d1058494cdd8", "1502877338535-766e1452684a"),
		},
		{
			ID: 3, UserID: 7,
			Title:       "Ducati Monster 797 2021",
			Description: "Stunning Ducati Monster 797 with only 8,200 km. Termignoni slip-on exhaust, tank pad, and Ducati frame sliders included. Full service completed at Ducati Bahrain last month — belts changed, fluids fresh. Comes with two helmets as a bonus. Selling due to relocation. Serious buyers only, no time-wasters.",
			Price: 9800, Category: "Vehicles", Location: "Riffa",
			Latitude: 26.1296, Longitude: 50.5554, Condition: "Like New",
			ViewCount: 156, CreatedAt: daysAgo(60),
			Images: imgs("1558981806-ec527fa84c39"),
		},
		{
			ID: 4, UserID: 9,
			Title:       "Toyota Camry 2018 LE",
			Description: "Solid and reliable Camry in very good condition. Automatic, 2.5L engine. Consistent service history with regular oil changes every 5,000 km. Ice-cold AC, Bluetooth, reverse camera, keyless entry. Clean interior with no rips or stains. Passing valid.",
			Price: 8900, Category: "Vehicles", Location: "Hamad Town",
			Latitude: 26.1148, Longitude: 50.5048, Condition: "Good",
			ViewCount: 423, IsSold: true, BuyerID: uid(1), CreatedAt: daysAgo(85),
			Images: imgs("1502877338535-766e1452684a"),
		},
		{
			ID: 5, UserID: 5,
			Title:       "BMW 318i 2021 Sport Line",
			Description: "Beautiful BMW 318i in Alpine White. Sport Line trim with 19\" M-sport rims, sport seats with red stitching, and ambient interior lighting. Only 22,000 km, no accidents whatsoever. Fully loaded: parking sensors front & rear, digital instrument cluster, Harman Kardon premium sound system, heads-up display. Agency maintained at Gulf Motors. A true drivers car.",
			Price: 26000, Category: "Vehicles", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Like New",
			ViewCount: 634, CreatedAt: daysAgo(40),
			Images: imgs("1555215695-3004980ad54e", "1549317661-bd32c8ce0db2"),
		},
		{
			ID: 6, UserID: 2,
			Title:       "Nissan Patrol SE 2019 V8",
			Description: "Commanding Nissan Patrol V8 in perfect family condition. 7 full-leather seats, panoramic roof, dual-zone climate, 360° camera system, premium navigation, and rear entertainment screens. All services done on time at Arabian Motors. No rust, no accidents. Upgrading to a newer model — priced to sell quickly.",
			Price: 28500, Category: "Vehicles", Location: "Muharraq",
			Latitude: 26.2670, Longitude: 50.6150, Condition: "Good",
			ViewCount: 521, CreatedAt: daysAgo(55),
			Images: imgs("1549317661-bd32c8ce0db2"),
		},

		// ── Property ──────────────────────────────────────────────────────────
		{
			ID: 7, UserID: 2,
			Title:       "Furnished Studio Apartment — Juffair",
			Description: "Fully furnished modern studio in the heart of Juffair. 3rd floor, building with pool, gym, and 24h security. Walking distance to restaurants, pharmacies, and the Gulf Hotel. Water and electricity included. High-speed fibre Wi-Fi included. No extra fees. Available immediately — ideal for expats or working professionals.",
			Price: 580, Category: "Property", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Good",
			ViewCount: 89, CreatedAt: daysAgo(30),
			Images: imgs("1502672260-684c44cf1a65", "1564078084-7003cef7e1eb"),
		},
		{
			ID: 8, UserID: 7,
			Title:       "3BHK Villa — Riffa Views Compound",
			Description: "Spacious 3-bedroom villa in the prestigious Riffa Views compound. Private walled garden, covered parking for 2 cars, large open-plan kitchen with island, central A/C throughout, dedicated maid's room, and storage room. Access to compound gym, pool, and playground. Close to Riffa Club, schools, and mosques. Family-only compound — pets not allowed.",
			Price: 2200, Category: "Property", Location: "Riffa",
			Latitude: 26.1296, Longitude: 50.5554, Condition: "Good",
			ViewCount: 234, CreatedAt: daysAgo(50),
			Images: imgs("1564078084-7003cef7e1eb"),
		},
		{
			ID: 9, UserID: 3,
			Title:       "Prime Office Space — Seef District (85 sqm)",
			Description: "85 sqm fitted commercial office on the 4th floor of a Seef tower. Layout includes open workspace, 2 private office partitions, dedicated server/IT room, reception area, and 2 restrooms. Fibre-ready, false ceiling with recessed lighting, and visitor parking available. Ideal for startups, consultancies, or regional SME branches. Available from next month.",
			Price: 3800, Category: "Property", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Like New",
			ViewCount: 67, CreatedAt: daysAgo(45),
			Images: imgs("1497366754035-f200968a6e72"),
		},

		// ── Mobile ────────────────────────────────────────────────────────────
		{
			ID: 10, UserID: 4,
			Title:       "iPhone 15 Pro Max 256GB — Natural Titanium",
			Description: "Lightly used iPhone 15 Pro Max, always kept in Apple silicone case with Belkin screen protector from day one. Battery health at 99%. Face ID works perfectly. Comes with original box, braided USB-C cable, and AppleCare+ valid for 10 more months. Unlocked for all networks worldwide.",
			Price: 980, Category: "Mobile", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Like New",
			ViewCount: 445, CreatedAt: daysAgo(20),
			Images: imgs("1592899677977-9c10ca588bbd", "1511707171634-5f897ff02aa9"),
		},
		{
			ID: 11, UserID: 6,
			Title:       "Samsung Galaxy S24 Ultra 512GB — Titanium Black",
			Description: "S24 Ultra in Titanium Black with 512GB storage. S Pen included and works perfectly. Used for 6 months — in great condition with very minor scratches on the back (invisible with any case). Battery capacity still at 97%. Comes with original box, Samsung cable, and adapter. SIM-unlocked.",
			Price: 750, Category: "Mobile", Location: "Adliya",
			Latitude: 26.2054, Longitude: 50.5892, Condition: "Good",
			ViewCount: 287, CreatedAt: daysAgo(35),
			Images: imgs("1610945415295-d9bbf067e59c"),
		},
		{
			ID: 12, UserID: 1,
			Title:       "Apple iPad Pro M2 11\" WiFi+Cellular 256GB",
			Description: "iPad Pro M2 with cellular, 256GB, Space Grey. Lightly used — mainly for reading and light travel work. Display has zero scratches. Apple Pencil 2nd gen included and charges wirelessly as expected. Magic Keyboard Folio also included — worth over $300 alone. Absolute powerhouse device.",
			Price: 820, Category: "Mobile", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Like New",
			ViewCount: 198, CreatedAt: daysAgo(18),
			Images: imgs("1544244015-0df4b3ffc6b0"),
		},
		{
			ID: 13, UserID: 5,
			Title:       "Google Pixel 8 Pro 128GB — Obsidian",
			Description: "Pixel 8 Pro in Obsidian black. Guaranteed 7 years of Android OS updates. Exceptional camera system with AI-powered photo editing. Very minor scuffs on the aluminium frame — screen and back glass are perfect. Battery performs excellently. Selling to switch ecosystems.",
			Price: 480, Category: "Mobile", Location: "Isa Town",
			Latitude: 26.1731, Longitude: 50.5384, Condition: "Good",
			ViewCount: 112, CreatedAt: daysAgo(28),
			Images: imgs("1598327105666-5b89351aff97"),
		},
		{
			ID: 14, UserID: 8,
			Title:       "iPhone 13 128GB Midnight",
			Description: "iPhone 13 in good overall condition. Battery health at 87%. No cracks on screen or back glass. Home screen and Face ID work fine. Comes with a charger. Ready to transfer immediately.",
			Price: 520, Category: "Mobile", Location: "Budaiya",
			Latitude: 26.2296, Longitude: 50.4582, Condition: "Good",
			ViewCount: 378, IsSold: true, BuyerID: uid(3), CreatedAt: daysAgo(70),
			Images: imgs("1632661674596-df8be070a5c5"),
		},

		// ── Electronics ───────────────────────────────────────────────────────
		{
			ID: 15, UserID: 1,
			Title:       "MacBook Pro M3 14\" 16GB/512GB — Space Black",
			Description: "MacBook Pro with M3 chip in Space Black — the new exclusive finish. 16GB unified memory, 512GB SSD. Purchased 5 months ago, used for UI/UX design. No dents, scratches, or marks anywhere. Liquid Retina XDR display is flawless. Comes with original 96W USB-C charger and box. Performance is simply unmatched.",
			Price: 1750, Category: "Electronics", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Like New",
			ViewCount: 923, CreatedAt: daysAgo(15),
			Images: imgs("1517336714731-489689fd1ca8", "1496181323117-61cd3dd3ee91"),
		},
		{
			ID: 16, UserID: 3,
			Title:       "Sony Alpha A7 IV Mirrorless Camera Body",
			Description: "Sony A7 IV body only. 33MP full-frame BSI-CMOS sensor, 4K/60p video, 10 fps burst, dual card slots. Used professionally for 1 year. Shutter count under 14,800. Sensor cleaned at Alpha Zone 2 months ago — zero dust spots. Comes with 2 NP-FZ100 batteries, dual USB charger, Peak Design camera bag, and 67mm UV filter.",
			Price: 2100, Category: "Electronics", Location: "Muharraq",
			Latitude: 26.2670, Longitude: 50.6150, Condition: "Good",
			ViewCount: 341, CreatedAt: daysAgo(42),
			Images: imgs("1516035069371-29a1b244cc32", "1502920514313-54077ec04b5e"),
		},
		{
			ID: 17, UserID: 2,
			Title:       "Sony WH-1000XM5 Wireless Headphones",
			Description: "Sony's flagship noise-cancelling headphones. Used only a handful of times for travel. Industry-leading ANC, 30-hour battery life, multi-point Bluetooth connection. Sound quality is reference-grade. All original accessories included: premium carry case, 3.5mm cable, USB-C cable, and flight adapter. Pristine condition.",
			Price: 200, Category: "Electronics", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Like New",
			ViewCount: 267, CreatedAt: daysAgo(22),
			Images: imgs("1505740420928-5e560c06d30e"),
		},
		{
			ID: 18, UserID: 7,
			Title:       "LG OLED evo C3 55\" 4K Smart TV",
			Description: "LG OLED evo C3 55-inch 4K 120Hz TV — one of the best TVs ever made. Dolby Vision, HDR10, HLG, and Dolby Atmos supported. NVIDIA G-Sync and AMD FreeSync Premium compatible — phenomenal for gaming. Perfect black levels, infinite contrast ratio. Original stand and remote included. Purchased 14 months ago from LG Bahrain.",
			Price: 750, Category: "Electronics", Location: "Riffa",
			Latitude: 26.1296, Longitude: 50.5554, Condition: "Good",
			ViewCount: 189, CreatedAt: daysAgo(32),
			Images: imgs("1593784991095-a205069470b6"),
		},
		{
			ID: 19, UserID: 9,
			Title:       "PlayStation 5 Disc Edition + 2 Controllers + 3 Games",
			Description: "PS5 Disc Edition in excellent condition — no overheating issues, whisper quiet. Bundle includes: 2 DualSense controllers (Cosmic Red and Midnight Black), Spider-Man 2 (disc), God of War Ragnarök (disc), and Elden Ring (disc). All working perfectly. Selling because I built a gaming PC. Everything original.",
			Price: 530, Category: "Electronics", Location: "Hamad Town",
			Latitude: 26.1148, Longitude: 50.5048, Condition: "Good",
			ViewCount: 611, CreatedAt: daysAgo(12),
			Images: imgs("1606144042614-b2417e99c4e3"),
		},
		{
			ID: 20, UserID: 5,
			Title:       "DJI Mini 3 Pro + RC Controller + Fly More Kit Plus",
			Description: "Complete DJI Mini 3 Pro setup. Includes: RC controller with built-in screen (no phone needed), Fly More Kit Plus with 3 Intelligent Flight Batteries (~47 min each), 65W charging hub, shoulder bag, and ND filter set (ND16/64/256). Total air time under 4 hours. Zero crashes or damage. Ideal for content creators and travel filmmakers.",
			Price: 580, Category: "Electronics", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Like New",
			ViewCount: 434, CreatedAt: daysAgo(8),
			Images: imgs("1473968512647-3e447244af8f"),
		},

		// ── Furniture ─────────────────────────────────────────────────────────
		{
			ID: 21, UserID: 6,
			Title:       "L-Shaped Sectional Sofa — Beige Microfiber",
			Description: "Large L-shaped sectional in premium beige microfiber. Deep, comfortable seats with removable cushion covers. Very minor fading on the left armrest (shown in photos, priced accordingly). Dimensions: 290cm x 200cm. Chaise section detaches from main sofa for transport. Steam-cleaned 1 month ago. Pick-up only from Zinj — large item, bring help.",
			Price: 980, Category: "Furniture", Location: "Zinj",
			Latitude: 26.2083, Longitude: 50.5639, Condition: "Good",
			ViewCount: 156, CreatedAt: daysAgo(48),
			Images: imgs("1555041469-a586c61ea9bc"),
		},
		{
			ID: 22, UserID: 8,
			Title:       "King Size Solid Wood Bed Frame + Magniflex Mattress",
			Description: "Solid acacia wood king size bed frame with 4 deep storage drawers underneath — great for Bahrain apartments. Includes a Magniflex Eliocel Memory king mattress (medium-firm, worth BD 350 new). 3 years old, always used with a waterproof mattress protector. Relocating out of Bahrain — must sell as a set. Serious buyers only.",
			Price: 480, Category: "Furniture", Location: "Budaiya",
			Latitude: 26.2296, Longitude: 50.4582, Condition: "Good",
			ViewCount: 98, CreatedAt: daysAgo(38),
			Images: imgs("1631049307264-da0ec9d70304"),
		},
		{
			ID: 23, UserID: 10,
			Title:       "Extendable Glass Dining Table + 6 Fabric Chairs",
			Description: "Modern dining set with tempered glass extendable table (160cm to 220cm) on a brushed steel base. 6 matching padded chairs in grey fabric with tapered wooden legs. A barely-visible scratch on the underside of the table extension — not visible when closed or seated. Sturdy, well-built set in excellent functional shape.",
			Price: 640, Category: "Furniture", Location: "Isa Town",
			Latitude: 26.1731, Longitude: 50.5384, Condition: "Good",
			ViewCount: 134, CreatedAt: daysAgo(25),
			Images: imgs("1449247709967-d4461a6a6103"),
		},
		{
			ID: 24, UserID: 4,
			Title:       "IKEA Bekant Sit-Stand Desk — 160x80cm White",
			Description: "Electric height-adjustable IKEA Bekant sit-stand desk in white, 160cm x 80cm. Motor works flawlessly — moves from 65cm to 125cm with one button press. Purchased new for WFH, now back to office full time so no longer needed. Minor cable management marks on underside. Can dismantle and help with loading.",
			Price: 250, Category: "Furniture", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Like New",
			ViewCount: 87, CreatedAt: daysAgo(14),
			Images: imgs("1518455027359-f3f8164ba6bd"),
		},
		{
			ID: 25, UserID: 1,
			Title:       "IKEA PAX Wardrobe — 200x236cm Hasvik Sliding Doors",
			Description: "Large IKEA PAX wardrobe system with Hasvik sliding mirror doors, 200cm wide x 236cm tall x 58cm deep. Komplement interior with hanging rails, 4 shelves, 2 drawers, and trouser hanger. Disassembles into flat-pack for transport. Selling because redecorating bedroom. Will help dismantle. Must pick up from Seef.",
			Price: 320, Category: "Furniture", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Good",
			ViewCount: 76, CreatedAt: daysAgo(55),
			Images: imgs("1558997519-83ea9252eeb8"),
		},

		// ── Fashion ───────────────────────────────────────────────────────────
		{
			ID: 26, UserID: 3,
			Title:       "Rolex Submariner Date 116610LN — Full Set",
			Description: "100% authentic Rolex Submariner Date in stainless steel, black dial and Cerachrom bezel. Reference 116610LN. Full set — original Rolex box, warranty card, hang tags, and green wallet. Purchased from Kanoo Jewellers Bahrain. Worn on special occasions only, serviced 8 months ago at an authorised Rolex service centre. Serious buyers with budget only, please.",
			Price: 8500, Category: "Fashion", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Like New",
			ViewCount: 782, CreatedAt: daysAgo(33),
			Images: imgs("1523275335684-37898b6baf30"),
		},
		{
			ID: 27, UserID: 2,
			Title:       "Louis Vuitton Neverfull MM — Damier Ebene",
			Description: "Authentic Louis Vuitton Neverfull MM in Damier Ebene canvas with Rose Ballerine pink interior. Purchased from LV boutique in Paris — receipt included. Original dust bag. Canvas in excellent condition. Light wear on the leather handles — completely normal patina for this model, no cracking or peeling. A timeless, spacious everyday bag.",
			Price: 1550, Category: "Fashion", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Good",
			ViewCount: 543, CreatedAt: daysAgo(29),
			Images: imgs("1548036328-c9fa89d128fa"),
		},
		{
			ID: 28, UserID: 7,
			Title:       "Nike Air Jordan 1 Retro High OG Chicago — Size US 10",
			Description: "Jordan 1 Retro High OG in the iconic Chicago colourway. Size US 10 (EU 44). Worn twice to take photos — near deadstock condition. Both lace sets (red and white) included. Original box with receipt from Nike Bahrain City Centre. Authentication tag still attached. No yellowing on the soles. A grail colourway at a fair price.",
			Price: 225, Category: "Fashion", Location: "Riffa",
			Latitude: 26.1296, Longitude: 50.5554, Condition: "Like New",
			ViewCount: 389, CreatedAt: daysAgo(17),
			Images: imgs("1542291026-7eec264c27ff"),
		},
		{
			ID: 29, UserID: 6,
			Title:       "Ray-Ban Aviator Classic RB3025 — Gold/G15",
			Description: "Classic Ray-Ban Aviator in gold metal frame with G-15 green polarised lens, size 58mm. The most iconic sunglasses ever made. Includes original Ray-Ban hard case, soft cleaning cloth, and box. Minor surface marks on one lens visible under direct light — barely noticeable when wearing. Priced accordingly.",
			Price: 120, Category: "Fashion", Location: "Adliya",
			Latitude: 26.2054, Longitude: 50.5892, Condition: "Good",
			ViewCount: 167, CreatedAt: daysAgo(44),
			Images: imgs("1572635196237-14b3f281503f"),
		},
		{
			ID: 30, UserID: 9,
			Title:       "Gucci GG Marmont Reversible Leather Belt — 90cm",
			Description: "Authentic Gucci GG Marmont reversible leather belt, 3.8cm wide, size 90/36. Black on one side, brown on the other. Double G gold-tone hardware. Purchased from Gucci boutique at Dubai Mall — original box, dust bag, and receipt included. Worn only 3-4 times. A versatile wardrobe essential at half the retail price.",
			Price: 250, Category: "Fashion", Location: "Hamad Town",
			Latitude: 26.1148, Longitude: 50.5048, Condition: "Like New",
			ViewCount: 223, CreatedAt: daysAgo(21),
			Images: imgs("1553062407-98eeb64c6a62"),
		},

		// ── Sports ────────────────────────────────────────────────────────────
		{
			ID: 31, UserID: 5,
			Title:       "Trek Domane SL 5 Road Bike 2022 — Size 54cm",
			Description: "Trek Domane SL 5 endurance road bike in Nautical Navy/Chrome, size 54cm (suits riders 175-182cm). Shimano 105 R7000 groupset, carbon fork, Bontrager Paradigm Elite wheels. IsoSpeed front and rear decouplers make this incredibly comfortable on long rides. Bontrager saddle, Supernova lights, and bottle cages included. Ridden on weekends, well-maintained.",
			Price: 1100, Category: "Sports", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Good",
			ViewCount: 298, CreatedAt: daysAgo(52),
			Images: imgs("1532298229144-0ec0c57515c7"),
		},
		{
			ID: 32, UserID: 1,
			Title:       "Yamaha F310 Acoustic Guitar + Full Starter Kit",
			Description: "Yamaha F310 acoustic guitar — a classic beginner/intermediate model known for great tone and playability. Excellent playing condition, no cracks or buzzing. Comes with: padded Yamaha gig bag, clip-on chromatic tuner, Kyser capo, 2 extra string sets (Elixir + D'Addario), guitar picks, and a wall hanger. Everything you need to start playing today.",
			Price: 95, Category: "Sports", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Good",
			ViewCount: 187, CreatedAt: daysAgo(36),
			Images: imgs("1510915361894-db8b60106cb1"),
		},
		{
			ID: 33, UserID: 8,
			Title:       "NordicTrack T 6.5 Si Treadmill",
			Description: "NordicTrack T 6.5 Si treadmill in working condition. FlexSelect cushioning, 20 built-in workout programs, iFit-enabled with 10\" touchscreen. Incline up to 12%. Belt has normal wear — plenty of life remaining. Motor runs perfectly with no noise or overheating issues. Folds flat for storage. Must sell — relocating and cannot ship it.",
			Price: 750, Category: "Sports", Location: "Budaiya",
			Latitude: 26.2296, Longitude: 50.4582, Condition: "Good",
			ViewCount: 132, CreatedAt: daysAgo(62),
			Images: imgs("1534438327276-14e5300c3a48"),
		},

		// ── Books ─────────────────────────────────────────────────────────────
		{
			ID: 34, UserID: 4,
			Title:       "Full IELTS Preparation Bundle — Cambridge + Barron's",
			Description: "Complete IELTS preparation package that helped me score 7.5. Includes: Cambridge IELTS books 1–15 (full series), Barron's IELTS SuperPack (book + 2 audio CDs), and Vocabulary for IELTS with audio. Light highlights and margin notes in some books — all content fully readable and intact. Selling as a lot only.",
			Price: 48, Category: "Books", Location: "Manama",
			Latitude: 26.2154, Longitude: 50.5832, Condition: "Good",
			ViewCount: 56, CreatedAt: daysAgo(19),
			Images: imgs("1544716278-ca5e3f4abd8c"),
		},
		{
			ID: 35, UserID: 10,
			Title:       "Mechanical Engineering Textbooks — UOB Curriculum Set",
			Description: "8 core Mechanical Engineering textbooks aligned with the University of Bahrain curriculum. Includes: Thermodynamics (Cengel & Boles, 9th Ed), Fluid Mechanics (Cengel, 4th Ed), Machine Design (Shigley, 10th Ed), Engineering Mathematics (Kreyszig), Mechanics of Materials (Hibbeler), and more. Light pencil annotations in some. A great investment for ME students.",
			Price: 92, Category: "Books", Location: "Isa Town",
			Latitude: 26.1731, Longitude: 50.5384, Condition: "Good",
			ViewCount: 43, CreatedAt: daysAgo(27),
			Images: imgs("1497633762265-9d179a990aa6"),
		},
		{
			ID: 36, UserID: 2,
			Title:       "Contemporary Arabic Literature — 15 Novel Collection",
			Description: "Curated collection of 15 Arabic novels by celebrated authors including Naguib Mahfouz (Cairo Trilogy), Ahlam Mosteghanemi (Memory in the Flesh), Elias Khoury (Gate of the Sun), and others. All in good readable condition with minor spine creasing. Selling as a set — not splitting. Perfect for Arabic literature lovers or university students.",
			Price: 35, Category: "Books", Location: "Juffair",
			Latitude: 26.2046, Longitude: 50.6031, Condition: "Good",
			ViewCount: 78, CreatedAt: daysAgo(41),
			Images: imgs("1481627834876-b7833e8f5570"),
		},
		{
			ID: 37, UserID: 7,
			Title:       "Essential Business & Finance Bookshelf — 10 Titles",
			Description: "10 must-read business books, each read once and kept in excellent condition: Rich Dad Poor Dad, The Intelligent Investor, Zero to One, Thinking Fast and Slow, Good to Great, Atomic Habits, The Lean Startup, Shoe Dog, Never Split the Difference, and Sapiens. Perfect for entrepreneurs, students, or anyone building financial knowledge.",
			Price: 65, Category: "Books", Location: "Seef",
			Latitude: 26.2124, Longitude: 50.5478, Condition: "Good",
			ViewCount: 61, CreatedAt: daysAgo(53),
			Images: imgs("1507842217343-583bb7270b66"),
		},

		// ── Other ─────────────────────────────────────────────────────────────
		{
			ID: 38, UserID: 6,
			Title:       "Chicco Trio System Stroller + KeyFit 30 Car Seat",
			Description: "Complete Chicco Trio travel system suitable from birth to 4 years. Stroller folds compactly, easy one-hand fold mechanism. KeyFit 30 car seat with base — ADAC tested, click-in mounting. Washed and sanitised recently. All safety buckles and harnesses click and lock correctly. Used for 18 months, normal wear only. A great full system at a fraction of retail.",
			Price: 225, Category: "Other", Location: "Adliya",
			Latitude: 26.2054, Longitude: 50.5892, Condition: "Good",
			ViewCount: 94, CreatedAt: daysAgo(31),
			Images: imgs("1519689680058-324335c77eba"),
		},
		{
			ID: 39, UserID: 9,
			Title:       "Nespresso Vertuo Next + Aeroccino 3 Frother",
			Description: "Nespresso Vertuo Next in Dark Grey with the Aeroccino 3 milk frother. Barcode-scanning technology automatically sets the perfect brewing parameters for every cup — espresso to alto sizes. Descaled regularly, runs perfectly. Comes with 20 assorted Vertuo capsules to get you started. A great machine for home or small office.",
			Price: 145, Category: "Other", Location: "Hamad Town",
			Latitude: 26.1148, Longitude: 50.5048, Condition: "Like New",
			ViewCount: 201, CreatedAt: daysAgo(9),
			Images: imgs("1495474472287-4d71bcdd2085"),
		},
		{
			ID: 40, UserID: 10,
			Title:       "Indoor Plant Collection — 5 Healthy Statement Pots",
			Description: "5 thriving indoor plants, each in its own ceramic pot included in the price: Monstera Deliciosa (large, ~80cm), Peace Lily (flowering), Golden Pothos (trailing, 60cm), Snake Plant (Sansevieria, upright), and ZZ Plant (glossy, low-maintenance). All pest-free and recently fertilised. Perfect for home or office. Pick-up from A'ali only — fragile items, please handle with care.",
			Price: 40, Category: "Other", Location: "A'ali",
			Latitude: 26.1643, Longitude: 50.5148, Condition: "Good",
			ViewCount: 167, CreatedAt: daysAgo(6),
			Images: imgs("1485955900006-10f4d324d411"),
		},
	}

	if err := db.Create(&listings).Error; err != nil {
		log.Fatal("seedListings:", err)
	}
	log.Printf("📦  %d listings created", len(listings))
	return listings
}

// ─── Reviews ─────────────────────────────────────────────────────────────────

func seedReviews(db *gorm.DB) {
	reviews := []models.Review{
		{SellerID: 9, ReviewerID: 1, Rating: 5, Comment: "Ibrahim was fantastic — car was exactly as described, transfer was smooth and quick. One of the best private-sale experiences I've had in Bahrain.", CreatedAt: daysAgo(80)},
		{SellerID: 8, ReviewerID: 3, Rating: 4, Comment: "Layla was responsive and the phone was in the condition shown. There was a slight delay meeting up, but she communicated well throughout. Good seller overall.", CreatedAt: daysAgo(65)},
		{SellerID: 3, ReviewerID: 2, Rating: 5, Comment: "Mohammed is a genuinely trustworthy seller. The camera was pristine, shutter count accurate, sensor spotless. Honest listing with clear photos. Highly recommended.", CreatedAt: daysAgo(38)},
		{SellerID: 1, ReviewerID: 6, Rating: 5, Comment: "Great experience — iPad was in perfect condition exactly as advertised, all accessories included, meeting was on time. Ahmed is a reliable seller.", CreatedAt: daysAgo(15)},
		{SellerID: 5, ReviewerID: 7, Rating: 4, Comment: "Yusuf was punctual and the bike matched the photos. Could have been cleaned up a bit more but mechanically perfect. Would buy from him again.", CreatedAt: daysAgo(48)},
		{SellerID: 6, ReviewerID: 4, Rating: 3, Comment: "Stroller was functional but had a loose buckle not mentioned in the listing. Noor was polite when I brought it up but the description wasn't fully accurate. Manage your expectations.", CreatedAt: daysAgo(28)},
		{SellerID: 2, ReviewerID: 9, Rating: 5, Comment: "Sara is a pleasure to deal with. Book collection was well-preserved, she was flexible with timing, and even gave me a bag to carry them. Exactly what you want in a seller.", CreatedAt: daysAgo(38)},
		{SellerID: 7, ReviewerID: 10, Rating: 5, Comment: "Khalid is very professional — books were in excellent shape, he had them sorted by title, and even threw in an extra notebook. Couldn't be happier. 5 stars!", CreatedAt: daysAgo(50)},
		{SellerID: 1, ReviewerID: 4, Rating: 4, Comment: "MacBook was as listed. Ahmed replied quickly and was patient with my questions. There's a small scuff on the bottom not mentioned in the listing, but it's minor. Great buy overall.", CreatedAt: daysAgo(12)},
		{SellerID: 4, ReviewerID: 5, Rating: 5, Comment: "Fatima was incredibly honest and helpful throughout. IELTS books were well-organised, she even shared some study tips. This is how marketplace selling should feel. Thank you!", CreatedAt: daysAgo(16)},
		{SellerID: 9, ReviewerID: 2, Rating: 5, Comment: "Ibrahim's PS5 bundle is an absolute steal. Every disc and controller worked perfectly. He even cleaned the console before handing it over. Smooth transaction in Hamad Town.", CreatedAt: daysAgo(10)},
		{SellerID: 3, ReviewerID: 7, Rating: 3, Comment: "The Rolex is nice but priced noticeably above comparable listings on other platforms. Mohammed wasn't flexible on price at all. Communication was fine, but do your market research first.", CreatedAt: daysAgo(30)},
	}
	if err := db.Create(&reviews).Error; err != nil {
		log.Fatal("seedReviews:", err)
	}
	log.Printf("⭐  %d reviews created", len(reviews))
}

// ─── Offers ──────────────────────────────────────────────────────────────────

func seedOffers(db *gorm.DB) {
	offers := []models.Offer{
		// Pending
		{
			ListingID: 15, BuyerID: 4, SellerID: 1, Amount: 1600,
			Note:   "Hi Ahmed, would you consider 1,600? I can meet anywhere in Seef this weekend and pay cash.",
			Status: models.OfferStatusPending, CreatedAt: daysAgo(2),
		},
		{
			ListingID: 5, BuyerID: 8, SellerID: 5, Amount: 24500,
			Note:   "Hello! Very interested in the BMW. Best I can do is 24,500 — is that acceptable? I'm serious and ready to move fast.",
			Status: models.OfferStatusPending, CreatedAt: daysAgo(3),
		},
		{
			ListingID: 10, BuyerID: 7, SellerID: 4, Amount: 900,
			Note:   "900 cash today — I can come to Manama within the hour. Let me know.",
			Status: models.OfferStatusPending, CreatedAt: daysAgo(1),
		},

		// Countered
		{
			ListingID: 16, BuyerID: 9, SellerID: 3, Amount: 1900,
			Note:          "Would you take 1,900? I've seen comparable A7 IVs listed for less with similar shutter counts.",
			Status:        models.OfferStatusCountered, CounterAmount: f64(2000),
			CreatedAt: daysAgo(10),
		},
		{
			ListingID: 26, BuyerID: 1, SellerID: 3, Amount: 7800,
			Note:          "Serious buyer here — 7,800 cash, I can meet in Manama tomorrow morning. Full payment, no delays.",
			Status:        models.OfferStatusCountered, CounterAmount: f64(8200),
			CreatedAt: daysAgo(25),
		},

		// Accepted
		{
			ListingID: 31, BuyerID: 3, SellerID: 5, Amount: 1000,
			Note:   "Can you do 1,000? I can pick up from Seef this Friday with cash.",
			Status: models.OfferStatusAccepted, CreatedAt: daysAgo(45),
		},
		{
			ListingID: 19, BuyerID: 2, SellerID: 9, Amount: 500,
			Note:   "500 firm and I can come today — I'm already in the Hamad Town area.",
			Status: models.OfferStatusAccepted, CreatedAt: daysAgo(8),
		},

		// Declined
		{
			ListingID: 1, BuyerID: 6, SellerID: 1, Amount: 28000,
			Note:   "28,000 is my absolute final for the Land Cruiser. Hope we can close this.",
			Status: models.OfferStatusDeclined, CreatedAt: daysAgo(70),
		},
		{
			ListingID: 27, BuyerID: 4, SellerID: 2, Amount: 1200,
			Note:   "Would you consider 1,200 for the LV bag? I think that's fair given the handle wear.",
			Status: models.OfferStatusDeclined, CreatedAt: daysAgo(20),
		},

		// Withdrawn
		{
			ListingID: 21, BuyerID: 5, SellerID: 6, Amount: 850,
			Note:   "850 for the sofa — I have a pickup truck and can come this weekend.",
			Status: models.OfferStatusWithdrawn, CreatedAt: daysAgo(40),
		},
	}
	if err := db.Create(&offers).Error; err != nil {
		log.Fatal("seedOffers:", err)
	}
	log.Printf("💸  %d offers created", len(offers))
}

// ─── Favorites ───────────────────────────────────────────────────────────────

func seedFavorites(db *gorm.DB) {
	favorites := []models.Favorite{
		{UserID: 1, ListingID: 10},
		{UserID: 1, ListingID: 15},
		{UserID: 1, ListingID: 31},
		{UserID: 2, ListingID: 1},
		{UserID: 2, ListingID: 19},
		{UserID: 2, ListingID: 26},
		{UserID: 3, ListingID: 5},
		{UserID: 3, ListingID: 17},
		{UserID: 3, ListingID: 32},
		{UserID: 4, ListingID: 15},
		{UserID: 4, ListingID: 19},
		{UserID: 4, ListingID: 21},
		{UserID: 5, ListingID: 10},
		{UserID: 5, ListingID: 26},
		{UserID: 6, ListingID: 1},
		{UserID: 6, ListingID: 5},
		{UserID: 7, ListingID: 15},
		{UserID: 7, ListingID: 16},
		{UserID: 8, ListingID: 20},
		{UserID: 9, ListingID: 15},
		{UserID: 9, ListingID: 28},
		{UserID: 10, ListingID: 39},
		{UserID: 10, ListingID: 40},
	}
	if err := db.Create(&favorites).Error; err != nil {
		log.Fatal("seedFavorites:", err)
	}
	log.Printf("❤️   %d favorites created", len(favorites))
}

// ─── Messages ────────────────────────────────────────────────────────────────

func seedMessages(db *gorm.DB) {
	msgs := []models.Message{

		// Fatima (4) ↔ Ahmed (1) about MacBook (listing 15)
		{SenderID: 4, ReceiverID: 1, Content: "Hi Ahmed! Is the MacBook Pro still available?", CreatedAt: daysAgo(5)},
		{SenderID: 1, ReceiverID: 4, Content: "Yes still available! Feel free to ask anything.", CreatedAt: daysAgo(5)},
		{SenderID: 4, ReceiverID: 1, Content: "Great. What's the battery cycle count?", CreatedAt: daysAgo(4)},
		{SenderID: 1, ReceiverID: 4, Content: "It's at 87 cycles. Screen has zero dead pixels and the keyboard is perfect. I can do a video call if you want to see it running.", CreatedAt: daysAgo(4)},
		{SenderID: 4, ReceiverID: 1, Content: "That sounds good. Would you consider 1,650?", CreatedAt: daysAgo(3)},
		{SenderID: 1, ReceiverID: 4, Content: "Lowest I can go is 1,700. It still has 3 months of warranty and is in like-new condition.", CreatedAt: daysAgo(3)},
		{SenderID: 4, ReceiverID: 1, Content: "Alright, deal! When can we meet? I'm available this Saturday in Seef.", CreatedAt: daysAgo(2)},
		{SenderID: 1, ReceiverID: 4, Content: "Saturday works perfectly. How about 11am at the Seef Mall food court? I'll bring the box and charger.", CreatedAt: daysAgo(2)},

		// Sara (2) ↔ Mohammed (3) about Sony Camera (listing 16)
		{SenderID: 2, ReceiverID: 3, Content: "Hello! Is the A7 IV still for sale?", CreatedAt: daysAgo(8)},
		{SenderID: 3, ReceiverID: 2, Content: "Yes it is! Just updated the listing today. Are you a photographer?", CreatedAt: daysAgo(8)},
		{SenderID: 2, ReceiverID: 3, Content: "Yes, mainly portrait and travel. Does the sensor have any dust spots or fungus?", CreatedAt: daysAgo(7)},
		{SenderID: 3, ReceiverID: 2, Content: "Zero dust or fungus — I had it sensor-cleaned professionally at Alpha Zone 2 months ago. I can shoot a white wall test on video call to prove it.", CreatedAt: daysAgo(7)},
		{SenderID: 2, ReceiverID: 3, Content: "That would be really reassuring. Can we do a quick video call tonight around 8pm?", CreatedAt: daysAgo(6)},
		{SenderID: 3, ReceiverID: 2, Content: "8pm works for me. I'll send you my WhatsApp number — talk soon!", CreatedAt: daysAgo(6)},

		// Khalid (7) ↔ Fatima (4) about iPhone 15 Pro Max (listing 10)
		{SenderID: 7, ReceiverID: 4, Content: "Salam! Is the iPhone 15 Pro Max still available? Is the price negotiable at all?", CreatedAt: daysAgo(3)},
		{SenderID: 4, ReceiverID: 7, Content: "Wa salam! Yes still available. A little room for negotiation — what's your best offer?", CreatedAt: daysAgo(3)},
		{SenderID: 7, ReceiverID: 4, Content: "I can do 930 cash. I'm in the Manama area so pickup is very easy.", CreatedAt: daysAgo(2)},
		{SenderID: 4, ReceiverID: 7, Content: "How about 950? That's my final — battery health is 99% and there's AppleCare left. I have another message from someone else too.", CreatedAt: daysAgo(2)},
		{SenderID: 7, ReceiverID: 4, Content: "OK 950 is fair. Can we meet tomorrow evening around 6pm?", CreatedAt: daysAgo(1)},
		{SenderID: 4, ReceiverID: 7, Content: "Perfect, confirmed. I'll send you the exact meeting spot. Please bring cash.", CreatedAt: daysAgo(1)},

		// Yusuf (5) ↔ Noor (6) about Sofa (listing 21)
		{SenderID: 5, ReceiverID: 6, Content: "Hi! I'm interested in the sofa. Is the microfiber easy to clean?", CreatedAt: daysAgo(12)},
		{SenderID: 6, ReceiverID: 5, Content: "Very easy — microfiber wipes down with a damp cloth. I steam-cleaned it last month too so it's fresh.", CreatedAt: daysAgo(12)},
		{SenderID: 5, ReceiverID: 6, Content: "Good to know. Does it fully dismantle? I'm on the 4th floor with no elevator.", CreatedAt: daysAgo(11)},
		{SenderID: 6, ReceiverID: 5, Content: "Yes — the chaise section detaches completely from the main sofa. Two people can carry each part up stairs without any problem.", CreatedAt: daysAgo(11)},
		{SenderID: 5, ReceiverID: 6, Content: "Perfect, I'll send you an offer through the app now.", CreatedAt: daysAgo(10)},
	}
	if err := db.Create(&msgs).Error; err != nil {
		log.Fatal("seedMessages:", err)
	}
	log.Printf("💬  %d messages created", len(msgs))
}

// ─── Reports ─────────────────────────────────────────────────────────────────

func seedReports(db *gorm.DB) {
	reports := []models.Report{
		{
			ListingID: 26, UserID: 8,
			Reason:  "Counterfeit item",
			Details: "The Rolex Submariner in this listing shows several inconsistencies with a genuine 116610LN — the dial font on the 'Submariner' text, the crown guards, and the rehaut engraving all look off in the photos. The price is also below what a genuine full-set example would sell for. I'd recommend requiring proof of purchase or an authorised dealer inspection before allowing this listing.",
			CreatedAt: daysAgo(30),
		},
		{
			ListingID: 1, UserID: 10,
			Reason:  "Scam / Fraud",
			Details: "This exact Land Cruiser listing (same photos, nearly identical description) appeared on another local classifieds platform under a completely different username and phone number, at a different price. This looks like either a scam listing or a photo-stolen repost. Please verify the seller's identity and ownership documents before proceeding.",
			CreatedAt: daysAgo(82),
		},
		{
			ListingID: 7, UserID: 5,
			Reason:  "Misleading description",
			Details: "The apartment is described as 'fully furnished' but based on other photos I found of the same unit on a property portal, the furniture is extremely minimal — just a bed and a small table. The listing photos appear to be taken from the developer's show unit rather than the actual apartment. The description is misleading.",
			CreatedAt: daysAgo(25),
		},
	}
	if err := db.Create(&reports).Error; err != nil {
		log.Fatal("seedReports:", err)
	}
	log.Printf("🚩  %d reports created", len(reports))
}

// ─── Blocks ──────────────────────────────────────────────────────────────────

func seedBlocks(db *gorm.DB) {
	blocks := []models.Block{
		{BlockerID: 1, BlockedID: 10, CreatedAt: daysAgo(20)},
		{BlockerID: 6, BlockedID: 3, CreatedAt: daysAgo(45)},
	}
	if err := db.Create(&blocks).Error; err != nil {
		log.Fatal("seedBlocks:", err)
	}
	log.Printf("🚫  %d blocks created", len(blocks))
}
