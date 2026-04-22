package models

import (
	"database/sql/driver"
	"encoding/json"
	"time"
)

type StringSlice []string

func (s StringSlice) Value() (driver.Value, error) {
	if s == nil {
		return "[]", nil
	}
	b, err := json.Marshal(s)
	if err != nil {
		return nil, err
	}
	return string(b), nil
}

func (s *StringSlice) Scan(value interface{}) error {
	if value == nil {
		*s = StringSlice{}
		return nil
	}

	var raw []byte
	switch v := value.(type) {
	case []byte:
		raw = v
	case string:
		raw = []byte(v)
	default:
		return nil
	}

	if len(raw) == 0 {
		*s = StringSlice{}
		return nil
	}
	return json.Unmarshal(raw, s)
}

type Listing struct {
	ID          uint        `json:"id"`
	Title       string      `gorm:"not null" json:"title"`
	Description string      `json:"description"`
	Price       float64     `json:"price"`
	Category    string      `json:"category"`
	Location    string      `json:"location"`
	Images      StringSlice `gorm:"type:text;not null;default:'[]'" json:"images"`
	Latitude    float64     `json:"latitude"`
	Longitude   float64     `json:"longitude"`
	Condition   string      `gorm:"default:'Good'" json:"condition"`
	ViewCount   int         `gorm:"default:0" json:"view_count"`
	IsSold      bool        `gorm:"default:false" json:"is_sold"`
	UserID      uint        `gorm:"index;not null" json:"user_id"`
	CreatedAt   time.Time   `json:"created_at"`
}
