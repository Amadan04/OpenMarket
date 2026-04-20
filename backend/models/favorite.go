package models

type Favorite struct {
	ID        uint `json:"id"`
	UserID    uint `gorm:"not null;index:idx_user_listing,unique" json:"user_id"`
	ListingID uint `gorm:"not null;index:idx_user_listing,unique" json:"listing_id"`
}
