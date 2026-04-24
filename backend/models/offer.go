package models

import "time"

type OfferStatus string

const (
	OfferStatusPending   OfferStatus = "pending"
	OfferStatusAccepted  OfferStatus = "accepted"
	OfferStatusDeclined  OfferStatus = "declined"
	OfferStatusCountered OfferStatus = "countered"
	OfferStatusWithdrawn OfferStatus = "withdrawn"
)

type Offer struct {
	ID            uint        `json:"id"`
	ListingID     uint        `gorm:"index;not null" json:"listing_id"`
	BuyerID       uint        `gorm:"index;not null" json:"buyer_id"`
	SellerID      uint        `gorm:"index;not null" json:"seller_id"`
	Amount        float64     `gorm:"not null" json:"amount"`
	Note          string      `json:"note"`
	Status        OfferStatus `gorm:"default:pending;not null" json:"status"`
	CounterAmount *float64    `json:"counter_amount,omitempty"`
	BuyerName     string      `gorm:"-" json:"buyer_name,omitempty"`
	CreatedAt     time.Time   `json:"created_at"`
	UpdatedAt     time.Time   `json:"updated_at"`
}
