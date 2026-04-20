package models

import "time"

type Message struct {
	ID         uint      `json:"id"`
	SenderID   uint      `gorm:"index;not null" json:"sender_id"`
	ReceiverID uint      `gorm:"index;not null" json:"receiver_id"`
	Content    string    `gorm:"not null" json:"content"`
	CreatedAt  time.Time `json:"timestamp"`
}
