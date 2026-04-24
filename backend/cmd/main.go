package main

import (
	"os"

	"openmarket/database"
	"openmarket/hub"
	"openmarket/models"
	"openmarket/routes"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()

	database.Connect()

	database.DB.AutoMigrate(
		&models.User{},
		&models.Listing{},
		&models.Review{},
		&models.Favorite{},
		&models.Message{},
		&models.Report{},
		&models.Offer{},
		&models.Block{},
		&models.DeviceToken{},
	)

	h := hub.New()

	r := gin.Default()
	r.Static("/uploads", "./uploads")
	routes.Setup(r, database.DB, h)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}
