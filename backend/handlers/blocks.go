package handlers

import (
	"net/http"
	"strconv"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func BlockUser(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		blockerID := c.GetUint("user_id")
		blockedID, err := strconv.Atoi(c.Param("id"))
		if err != nil || blockedID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
			return
		}
		if uint(blockedID) == blockerID {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot block yourself"})
			return
		}

		var target models.User
		if err := db.First(&target, blockedID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		block := models.Block{BlockerID: blockerID, BlockedID: uint(blockedID)}
		if err := db.Where(block).FirstOrCreate(&block).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to block user"})
			return
		}
		c.JSON(http.StatusOK, block)
	}
}

func UnblockUser(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		blockerID := c.GetUint("user_id")
		blockedID, err := strconv.Atoi(c.Param("id"))
		if err != nil || blockedID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
			return
		}

		if err := db.Where("blocker_id = ? AND blocked_id = ?", blockerID, blockedID).
			Delete(&models.Block{}).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unblock user"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"message": "Unblocked"})
	}
}

func GetBlockedUsers(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var blocks []models.Block
		if err := db.Where("blocker_id = ?", userID).Find(&blocks).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch blocked users"})
			return
		}
		c.JSON(http.StatusOK, blocks)
	}
}

// blockedIDs returns the list of user IDs blocked by blockerID.
// Used by listing and message handlers to filter out blocked content.
func blockedIDs(db *gorm.DB, blockerID uint) []uint {
	var blocks []models.Block
	db.Select("blocked_id").Where("blocker_id = ?", blockerID).Find(&blocks)
	ids := make([]uint, len(blocks))
	for i, b := range blocks {
		ids[i] = b.BlockedID
	}
	return ids
}
