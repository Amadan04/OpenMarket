package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type conversationSummary struct {
	ID          uint           `json:"id"`
	Participant models.User    `json:"participant"`
	LastMessage models.Message `json:"last_message"`
}

func SendMessage(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var msg models.Message
		if err := c.ShouldBindJSON(&msg); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		msg.Content = strings.TrimSpace(msg.Content)
		if msg.ReceiverID == 0 || msg.Content == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "receiver_id and content are required"})
			return
		}

		msg.SenderID = c.GetUint("user_id")
		if msg.SenderID == msg.ReceiverID {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot send message to yourself"})
			return
		}

		var receiver models.User
		if err := db.First(&receiver, msg.ReceiverID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Receiver not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch receiver"})
			return
		}

		var blockCheck models.Block
		if err := db.Where("(blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)",
			msg.SenderID, msg.ReceiverID, msg.ReceiverID, msg.SenderID).First(&blockCheck).Error; err == nil {
			c.JSON(http.StatusForbidden, gin.H{"error": "Cannot message this user"})
			return
		}

		if err := db.Create(&msg).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send message"})
			return
		}
		c.JSON(http.StatusCreated, msg)
	}
}

func GetConversations(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var messages []models.Message
		if err := db.Where("sender_id = ? OR receiver_id = ?", userID, userID).
			Order("created_at DESC").
			Find(&messages).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch conversations"})
			return
		}

		blocked := blockedIDs(db, userID)
		blockedSet := map[uint]bool{}
		for _, id := range blocked {
			blockedSet[id] = true
		}

		conversationMap := map[uint]conversationSummary{}
		for _, msg := range messages {
			participantID := msg.SenderID
			if participantID == userID {
				participantID = msg.ReceiverID
			}

			if blockedSet[participantID] {
				continue
			}
			if _, exists := conversationMap[participantID]; exists {
				continue
			}

			var participant models.User
			if err := db.Select("id", "name", "email", "created_at").First(&participant, participantID).Error; err != nil {
				continue
			}

			conversationMap[participantID] = conversationSummary{
				ID:          participantID,
				Participant: participant,
				LastMessage: msg,
			}
		}

		conversations := make([]conversationSummary, 0, len(conversationMap))
		for _, convo := range conversationMap {
			conversations = append(conversations, convo)
		}
		c.JSON(http.StatusOK, conversations)
	}
}

func GetConversationMessages(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		otherUserID, err := strconv.Atoi(c.Param("id"))
		if err != nil || otherUserID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation id"})
			return
		}
		if uint(otherUserID) == userID {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid conversation id"})
			return
		}

		var messages []models.Message
		if err := db.Where(
			"(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
			userID, otherUserID, otherUserID, userID,
		).Order("created_at ASC").Find(&messages).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
			return
		}
		c.JSON(http.StatusOK, messages)
	}
}

func DeleteMessage(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil || id <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid message id"})
			return
		}

		var msg models.Message
		if err := db.First(&msg, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{"error": "Message not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch message"})
			return
		}

		if msg.SenderID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		if err := db.Delete(&msg).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete message"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Deleted"})
	}
}
