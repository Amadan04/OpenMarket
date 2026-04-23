package models

import "time"

type Block struct {
	ID        uint      `json:"id"`
	BlockerID uint      `gorm:"uniqueIndex:idx_block;not null" json:"blocker_id"`
	BlockedID uint      `gorm:"uniqueIndex:idx_block;not null" json:"blocked_id"`
	CreatedAt time.Time `json:"created_at"`
}
