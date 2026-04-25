package handlers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

const maxUploadSize = 10 << 20 // 10 MB

func UploadImage() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxUploadSize)

		file, err := c.FormFile("image")
		if err != nil {
			if err.Error() == "http: request body too large" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "file too large (max 10 MB)"})
				return
			}
			c.JSON(http.StatusBadRequest, gin.H{"error": "image file is required"})
			return
		}

		if file.Size > maxUploadSize {
			c.JSON(http.StatusBadRequest, gin.H{"error": "file too large (max 10 MB)"})
			return
		}

		ext := filepath.Ext(file.Filename)
		allowed := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".webp": true}
		if !allowed[ext] {
			c.JSON(http.StatusBadRequest, gin.H{"error": "only jpg, png, webp allowed"})
			return
		}

		if err := os.MkdirAll("uploads", 0755); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "storage error"})
			return
		}

		filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
		dst := filepath.Join("uploads", filename)
		if err := c.SaveUploadedFile(file, dst); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save file"})
			return
		}

		host := os.Getenv("BASE_URL")
		if host == "" {
			host = "http://localhost:" + os.Getenv("PORT")
		}
		c.JSON(http.StatusOK, gin.H{"url": fmt.Sprintf("%s/uploads/%s", host, filename)})
	}
}
