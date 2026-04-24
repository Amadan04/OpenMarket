package handlers

import (
	"fmt"
	"net/http"
	"strconv"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddReview(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var review models.Review
		if err := c.ShouldBindJSON(&review); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		if review.SellerID == 0 || review.Rating < 1 || review.Rating > 5 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Valid seller_id and rating (1-5) are required"})
			return
		}

		review.ReviewerID = c.GetUint("user_id")
		if review.ReviewerID == review.SellerID {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot review yourself"})
			return
		}

		var seller models.User
		if err := db.First(&seller, review.SellerID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Seller not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch seller"})
			return
		}

		if err := db.Create(&review).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add review"})
			return
		}

		sendAPNSToUser(db, review.SellerID, "New review",
			fmt.Sprintf("Someone left you a %d-star review.", review.Rating))
		c.JSON(http.StatusCreated, review)
	}
}

func GetSellerReviews(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		sellerID, err := strconv.Atoi(c.Param("id"))
		if err != nil || sellerID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
			return
		}

		var reviews []models.Review
		if err := db.Where("seller_id = ?", sellerID).Order("created_at DESC").Find(&reviews).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
			return
		}

		var average float64
		if len(reviews) > 0 {
			total := 0
			for _, review := range reviews {
				total += review.Rating
			}
			average = float64(total) / float64(len(reviews))
		}

		c.JSON(http.StatusOK, gin.H{
			"seller_id":      sellerID,
			"average_rating": average,
			"reviews_count":  len(reviews),
			"reviews":        reviews,
		})
	}
}

func DeleteReview(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid review id"})
			return
		}

		var review models.Review
		if err := db.First(&review, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Review not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch review"})
			return
		}

		if review.ReviewerID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		if err := db.Delete(&review).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete review"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Deleted"})
	}
}
