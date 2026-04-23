package handlers

import (
	"net/http"
	"strconv"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateOffer(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		buyerID := c.GetUint("user_id")

		var body struct {
			ListingID uint    `json:"listing_id"`
			Amount    float64 `json:"amount"`
			Note      string  `json:"note"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}
		if body.ListingID == 0 || body.Amount <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "listing_id and amount > 0 are required"})
			return
		}

		var listing models.Listing
		if err := db.First(&listing, body.ListingID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Listing not found"})
			return
		}
		if listing.IsSold {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Listing is already sold"})
			return
		}
		if listing.UserID == buyerID {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot make an offer on your own listing"})
			return
		}

		var existing models.Offer
		err := db.Where("listing_id = ? AND buyer_id = ? AND status IN ?",
			body.ListingID, buyerID, []string{"pending", "countered"}).First(&existing).Error
		if err == nil {
			c.JSON(http.StatusConflict, gin.H{"error": "You already have an active offer on this listing"})
			return
		}

		offer := models.Offer{
			ListingID: body.ListingID,
			BuyerID:   buyerID,
			SellerID:  listing.UserID,
			Amount:    body.Amount,
			Note:      body.Note,
			Status:    models.OfferStatusPending,
		}
		if err := db.Create(&offer).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create offer"})
			return
		}
		c.JSON(http.StatusCreated, offer)
	}
}

func GetMyOffers(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var offers []models.Offer
		if err := db.Where("buyer_id = ?", userID).Order("created_at DESC").Find(&offers).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch offers"})
			return
		}
		c.JSON(http.StatusOK, offers)
	}
}

func GetListingOffers(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		listingID, err := strconv.Atoi(c.Param("id"))
		if err != nil || listingID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid listing id"})
			return
		}

		var listing models.Listing
		if err := db.First(&listing, listingID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Listing not found"})
			return
		}
		if listing.UserID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}

		var offers []models.Offer
		if err := db.Where("listing_id = ?", listingID).Order("created_at DESC").Find(&offers).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch offers"})
			return
		}
		c.JSON(http.StatusOK, offers)
	}
}

func RespondToOffer(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		offerID, err := strconv.Atoi(c.Param("id"))
		if err != nil || offerID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid offer id"})
			return
		}

		var body struct {
			Action        string   `json:"action"`
			CounterAmount *float64 `json:"counter_amount,omitempty"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		var offer models.Offer
		if err := db.First(&offer, offerID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Offer not found"})
			return
		}
		if offer.SellerID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}
		if offer.Status != models.OfferStatusPending {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Offer is already resolved"})
			return
		}

		switch body.Action {
		case "accept":
			offer.Status = models.OfferStatusAccepted
		case "decline":
			offer.Status = models.OfferStatusDeclined
		case "counter":
			if body.CounterAmount == nil || *body.CounterAmount <= 0 {
				c.JSON(http.StatusBadRequest, gin.H{"error": "counter_amount is required for counter action"})
				return
			}
			offer.Status = models.OfferStatusCountered
			offer.CounterAmount = body.CounterAmount
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "action must be accept, decline, or counter"})
			return
		}

		if err := db.Save(&offer).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update offer"})
			return
		}
		c.JSON(http.StatusOK, offer)
	}
}

func WithdrawOffer(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		offerID, err := strconv.Atoi(c.Param("id"))
		if err != nil || offerID <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid offer id"})
			return
		}

		var offer models.Offer
		if err := db.First(&offer, offerID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Offer not found"})
			return
		}
		if offer.BuyerID != userID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
			return
		}
		if offer.Status != models.OfferStatusPending && offer.Status != models.OfferStatusCountered {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Offer cannot be withdrawn"})
			return
		}

		offer.Status = models.OfferStatusWithdrawn
		if err := db.Save(&offer).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to withdraw offer"})
			return
		}
		c.JSON(http.StatusOK, offer)
	}
}
