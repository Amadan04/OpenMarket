package models

import "time"

type Report struct {
	ID        uint      `json:"id"`
	ListingID uint      `gorm:"index;not null" json:"listing_id"`
	UserID    uint      `gorm:"index;not null" json:"user_id"`
	Reason    string    `gorm:"not null" json:"reason"`
	Details   string    `json:"details"`
	CreatedAt time.Time `json:"created_at"`
}
