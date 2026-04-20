package models

import "time"

type Review struct {
	ID         uint      `json:"id"`
	Rating     int       `gorm:"not null" json:"rating"`
	Comment    string    `json:"comment"`
	SellerID   uint      `gorm:"index;not null" json:"seller_id"`
	ReviewerID uint      `gorm:"index;not null" json:"reviewer_id"`
	CreatedAt  time.Time `json:"created_at"`
}
