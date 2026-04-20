package database

import (
	"log"
	"os"

	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() *gorm.DB {
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "openmarket.db"
	}

	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect database")
	}

	DB = db
	return db
}
