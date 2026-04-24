package handlers

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"openmarket/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

// RegisterDevice stores the caller's APNs device token.
func RegisterDevice(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var body struct {
			Token    string `json:"token"`
			Platform string `json:"platform"`
		}
		if err := c.ShouldBindJSON(&body); err != nil || body.Token == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "token is required"})
			return
		}
		if body.Platform == "" {
			body.Platform = "ios"
		}

		dt := models.DeviceToken{
			UserID:   userID,
			Token:    body.Token,
			Platform: body.Platform,
		}
		// Upsert: if token already exists update its user (re-login on new account)
		if err := db.Where("token = ?", body.Token).Assign(models.DeviceToken{UserID: userID}).
			FirstOrCreate(&dt).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register device"})
			return
		}
		c.JSON(http.StatusOK, dt)
	}
}

// UnregisterDevice removes a device token (on logout).
func UnregisterDevice(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetUint("user_id")
		var body struct {
			Token string `json:"token"`
		}
		if err := c.ShouldBindJSON(&body); err != nil || body.Token == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "token is required"})
			return
		}
		db.Where("user_id = ? AND token = ?", userID, body.Token).Delete(&models.DeviceToken{})
		c.JSON(http.StatusOK, gin.H{"message": "Unregistered"})
	}
}

// sendAPNSToUser looks up all device tokens for userID and fires APNs in a goroutine.
func sendAPNSToUser(db *gorm.DB, userID uint, title, body string) {
	go func() {
		var tokens []models.DeviceToken
		if err := db.Where("user_id = ? AND platform = ?", userID, "ios").Find(&tokens).Error; err != nil {
			return
		}
		for _, t := range tokens {
			if err := sendAPNS(t.Token, title, body); err != nil {
				log.Printf("APNs error for user %d: %v", userID, err)
			}
		}
	}()
}

// sendAPNS sends a single APNs push notification.
// Requires env vars: APNS_KEY (PEM contents of .p8 file), APNS_KEY_ID, APNS_TEAM_ID, APNS_BUNDLE_ID.
// Set APNS_SANDBOX=true for development builds.
func sendAPNS(deviceToken, title, body string) error {
	keyPEM := os.Getenv("APNS_KEY")
	keyID := os.Getenv("APNS_KEY_ID")
	teamID := os.Getenv("APNS_TEAM_ID")
	bundleID := os.Getenv("APNS_BUNDLE_ID")

	if keyPEM == "" || keyID == "" || teamID == "" || bundleID == "" || deviceToken == "" {
		return nil // APNs not configured — skip silently
	}

	jwtToken, err := buildAPNSJWT(keyPEM, keyID, teamID)
	if err != nil {
		return fmt.Errorf("jwt: %w", err)
	}

	host := "https://api.push.apple.com"
	if os.Getenv("APNS_SANDBOX") == "true" {
		host = "https://api.sandbox.push.apple.com"
	}

	payload := map[string]any{
		"aps": map[string]any{
			"alert": map[string]string{"title": title, "body": body},
			"sound": "default",
			"badge": 1,
		},
	}
	payloadBytes, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST",
		fmt.Sprintf("%s/3/device/%s", host, deviceToken),
		bytes.NewReader(payloadBytes))
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+jwtToken)
	req.Header.Set("apns-topic", bundleID)
	req.Header.Set("apns-push-type", "alert")
	req.Header.Set("apns-expiration", fmt.Sprintf("%d", time.Now().Add(24*time.Hour).Unix()))
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("APNs response %d for token %s", resp.StatusCode, deviceToken[:8]+"…")
	}
	return nil
}

func buildAPNSJWT(keyPEM, keyID, teamID string) (string, error) {
	block, _ := pem.Decode([]byte(keyPEM))
	if block == nil {
		return "", fmt.Errorf("invalid PEM block")
	}
	raw, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return "", err
	}
	ecKey, ok := raw.(*ecdsa.PrivateKey)
	if !ok {
		return "", fmt.Errorf("APNS_KEY is not an EC private key")
	}

	tok := jwt.NewWithClaims(jwt.SigningMethodES256, jwt.MapClaims{
		"iss": teamID,
		"iat": time.Now().Unix(),
	})
	tok.Header["kid"] = keyID

	return tok.SignedString(ecKey)
}
