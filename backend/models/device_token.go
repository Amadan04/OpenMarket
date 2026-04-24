package models

import "time"

type DeviceToken struct {
	ID        uint      `json:"id"`
	UserID    uint      `gorm:"index;not null" json:"user_id"`
	Token     string    `gorm:"uniqueIndex;not null" json:"token"`
	Platform  string    `gorm:"default:ios;not null" json:"platform"`
	CreatedAt time.Time `json:"created_at"`
}
