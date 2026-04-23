package handlers

import (
	"net/http"
	"strings"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateReport(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var input struct {
			ListingID uint   `json:"listing_id"`
			Reason    string `json:"reason"`
			Details   string `json:"details"`
		}
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}
		input.Reason = strings.TrimSpace(input.Reason)
		if input.ListingID == 0 || input.Reason == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "listing_id and reason are required"})
			return
		}

		userID := c.GetUint("user_id")
		report := models.Report{
			ListingID: input.ListingID,
			UserID:    userID,
			Reason:    input.Reason,
			Details:   strings.TrimSpace(input.Details),
		}
		if err := db.Create(&report).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to submit report"})
			return
		}
		c.JSON(http.StatusCreated, gin.H{"message": "Report submitted"})
	}
}
