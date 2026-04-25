package routes

import (
	"openmarket/hub"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupTestRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()
	h := hub.New()
	Setup(r, db, h)
	return r
}
