package handlers

import (
	"net/http"
	"strconv"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddFavorite(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		listingID, err := strconv.Atoi(c.Param("productId"))
		if err != nil || listingID <= 0 {
			listingID, err = strconv.Atoi(c.Param("id"))
		}
		if err != nil || listingID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product id"})
			return
		}

		var listing models.Listing
		if err := db.First(&listing, listingID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Listing not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch listing"})
			return
		}

		fav := models.Favorite{
			UserID:    userID,
			ListingID: uint(listingID),
		}

		if err := db.Where("user_id = ? AND listing_id = ?", userID, listingID).FirstOrCreate(&fav).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to favorite listing"})
			return
		}

		c.JSON(http.StatusOK, fav)
	}
}

func DeleteFavorite(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		productID, err := strconv.Atoi(c.Param("productId"))
		if err != nil || productID <= 0 {
			productID, err = strconv.Atoi(c.Param("id"))
		}
		if err != nil || productID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product id"})
			return
		}

		var fav models.Favorite
		if err := db.Where("user_id = ? AND listing_id = ?", userID, productID).First(&fav).Error; err != nil {
			// fallback for legacy calls that pass favorite id instead of listing id
			err = db.First(&fav, productID).Error
		}
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Favorite not found for this product"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch favorite"})
			return
		}

		if fav.UserID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		if err := db.Delete(&fav).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete favorite"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Deleted"})
	}
}

func GetFavorites(db *gorm.DB) gin.HandlerFunc {
	type favoriteResponse struct {
		ID      uint           `json:"id"`
		UserID  uint           `json:"user_id"`
		Product models.Listing `json:"product"`
	}

	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var favorites []models.Favorite
		if err := db.Where("user_id = ?", userID).Find(&favorites).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch favorites"})
			return
		}

		result := make([]favoriteResponse, 0, len(favorites))
		for _, fav := range favorites {
			var listing models.Listing
			if err := db.First(&listing, fav.ListingID).Error; err != nil {
				continue
			}
			result = append(result, favoriteResponse{
				ID:      fav.ID,
				UserID:  fav.UserID,
				Product: listing,
			})
		}

		c.JSON(http.StatusOK, result)
	}
}
