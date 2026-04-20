package database

import (
	"log"

	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

func ConnectTest() *gorm.DB {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect test DB: %v", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		log.Fatal("Failed to get sql DB")
	}

	// Keep one connection so the in-memory database remains stable for test lifetime.
	sqlDB.SetMaxOpenConns(1)
	db.Exec("PRAGMA foreign_keys = ON")

	return db
}
