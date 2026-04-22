package handlers

import (
	"math"
	"net/http"
	"strconv"
	"strings"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateListing(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var listing models.Listing
		if err := c.ShouldBindJSON(&listing); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		listing.Title = strings.TrimSpace(listing.Title)
		if listing.Title == "" || listing.Price < 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Title is required and price must be non-negative"})
			return
		}
		if listing.Images == nil {
			listing.Images = models.StringSlice{}
		}

		userID := c.GetUint("user_id")
		listing.UserID = userID

		if err := db.Create(&listing).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create listing"})
			return
		}

		c.JSON(http.StatusCreated, listing)
	}
}

func GetListings(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var listings []models.Listing

		query := db

		if q := c.Query("search"); q != "" {
			query = query.Where("title LIKE ? OR description LIKE ?", "%"+q+"%", "%"+q+"%")
		}

		if userID := c.Query("user_id"); userID != "" {
			if uid, err := strconv.Atoi(userID); err == nil && uid > 0 {
				query = query.Where("user_id = ?", uid)
			}
		}

		limit := 20
		offset := 0
		if limitStr := c.Query("limit"); limitStr != "" {
			if parsed, err := strconv.Atoi(limitStr); err == nil && parsed > 0 && parsed <= 100 {
				limit = parsed
			}
		}
		if pageStr := c.Query("page"); pageStr != "" {
			if parsed, err := strconv.Atoi(pageStr); err == nil && parsed > 0 {
				offset = (parsed - 1) * limit
			}
		}

		if err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&listings).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch listings"})
			return
		}

		c.JSON(http.StatusOK, listings)
	}
}

func GetListingByID(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product id"})
			return
		}

		var listing models.Listing
		if err := db.First(&listing, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch product"})
			return
		}
		c.JSON(http.StatusOK, listing)
	}
}

func UpdateListing(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product id"})
			return
		}

		userID := c.GetUint("user_id")
		var listing models.Listing
		if err := db.First(&listing, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch product"})
			return
		}

		if listing.UserID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		var input models.Listing
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		input.Title = strings.TrimSpace(input.Title)
		if input.Title == "" || input.Price < 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Title is required and price must be non-negative"})
			return
		}

		updates := map[string]interface{}{
			"title":       input.Title,
			"description": input.Description,
			"price":       input.Price,
			"category":    input.Category,
			"location":    input.Location,
			"images":      input.Images,
			"latitude":    input.Latitude,
			"longitude":   input.Longitude,
		}
		if err := db.Model(&listing).Updates(updates).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update product"})
			return
		}

		if err := db.First(&listing, id).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch updated product"})
			return
		}
		c.JSON(http.StatusOK, listing)
	}
}

func SearchListings(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var listings []models.Listing
		query := db.Model(&models.Listing{})

		if category := strings.TrimSpace(c.Query("category")); category != "" {
			query = query.Where("LOWER(category) = LOWER(?)", category)
		}

		if minPrice := c.Query("min_price"); minPrice != "" {
			if v, err := strconv.ParseFloat(minPrice, 64); err == nil {
				query = query.Where("price >= ?", v)
			}
		}
		if maxPrice := c.Query("max_price"); maxPrice != "" {
			if v, err := strconv.ParseFloat(maxPrice, 64); err == nil {
				query = query.Where("price <= ?", v)
			}
		}
		if q := strings.TrimSpace(c.Query("q")); q != "" {
			query = query.Where("title LIKE ? OR description LIKE ?", "%"+q+"%", "%"+q+"%")
		}

		if err := query.Order("created_at DESC").Find(&listings).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to search products"})
			return
		}
		c.JSON(http.StatusOK, listings)
	}
}

func NearbyListings(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		lat, err := strconv.ParseFloat(c.Query("lat"), 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "lat is required"})
			return
		}
		lng, err := strconv.ParseFloat(c.Query("lng"), 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "lng is required"})
			return
		}
		radiusKm := 10.0
		if radius := c.Query("radius_km"); radius != "" {
			if v, err := strconv.ParseFloat(radius, 64); err == nil && v > 0 {
				radiusKm = v
			}
		}

		var listings []models.Listing
		if err := db.Where("latitude != 0 OR longitude != 0").Find(&listings).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch products"})
			return
		}

		result := make([]models.Listing, 0)
		for _, listing := range listings {
			if distanceKm(lat, lng, listing.Latitude, listing.Longitude) <= radiusKm {
				result = append(result, listing)
			}
		}
		c.JSON(http.StatusOK, result)
	}
}

func MarkAsSold(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid listing id"})
			return
		}
		userID := c.GetUint("user_id")

		var listing models.Listing
		if err := db.First(&listing, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Listing not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch listing"})
			return
		}

		if listing.UserID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		if err := db.Model(&listing).Update("is_sold", true).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark as sold"})
			return
		}

		listing.IsSold = true
		c.JSON(http.StatusOK, listing)
	}
}

func DeleteListing(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid listing id"})
			return
		}
		userID := c.GetUint("user_id")

		var listing models.Listing
		if err := db.First(&listing, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Listing not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch listing"})
			return
		}

		if listing.UserID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		if err := db.Delete(&listing).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete listing"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Deleted"})
	}
}

func distanceKm(lat1, lng1, lat2, lng2 float64) float64 {
	const earthRadiusKm = 6371
	dLat := toRadians(lat2 - lat1)
	dLng := toRadians(lng2 - lng1)

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(toRadians(lat1))*math.Cos(toRadians(lat2))*
			math.Sin(dLng/2)*math.Sin(dLng/2)

	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	return earthRadiusKm * c
}

func toRadians(deg float64) float64 {
	return deg * math.Pi / 180
}
