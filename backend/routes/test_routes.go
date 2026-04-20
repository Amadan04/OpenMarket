package routes

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupTestRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()
	Setup(r, db)
	return r
}
