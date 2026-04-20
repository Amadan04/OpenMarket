package main

import (
	"os"

	"openmarket/database"
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
	)

	r := gin.Default()
	routes.Setup(r, database.DB)

	r.Run(":" + os.Getenv("PORT"))
}
