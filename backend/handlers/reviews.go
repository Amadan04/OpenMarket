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

type ReviewWithName struct {
	models.Review
	ReviewerName string `json:"reviewer_name"`
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

		// Collect unique reviewer IDs and fetch their names in one query
		idSet := map[uint]struct{}{}
		for _, r := range reviews {
			idSet[r.ReviewerID] = struct{}{}
		}
		ids := make([]uint, 0, len(idSet))
		for id := range idSet {
			ids = append(ids, id)
		}
		var users []models.User
		db.Where("id IN ?", ids).Find(&users)
		nameMap := map[uint]string{}
		for _, u := range users {
			nameMap[u.ID] = u.Name
		}

		enriched := make([]ReviewWithName, len(reviews))
		var average float64
		for i, r := range reviews {
			enriched[i] = ReviewWithName{Review: r, ReviewerName: nameMap[r.ReviewerID]}
			average += float64(r.Rating)
		}
		if len(reviews) > 0 {
			average /= float64(len(reviews))
		}

		c.JSON(http.StatusOK, gin.H{
			"seller_id":      sellerID,
			"average_rating": average,
			"reviews_count":  len(reviews),
			"reviews":        enriched,
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
