package handlers

import (
	"errors"
	"net/http"
	"os"
	"strings"

	"openmarket/hub"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/net/websocket"
)

// WSHandler upgrades the connection and registers it with the hub.
// Auth: JWT passed as ?token=<jwt> query parameter.
func WSHandler(h *hub.Hub) gin.HandlerFunc {
	server := websocket.Server{
		// Accept any origin (mobile app has no browser origin).
		Handshake: func(_ *websocket.Config, _ *http.Request) error { return nil },
		Handler: func(ws *websocket.Conn) {
			// Parse userID from the token stored in ws.Request().
			userID, err := wsUserID(ws.Request())
			if err != nil {
				ws.Close()
				return
			}

			h.Register(userID, ws)
			defer h.Unregister(userID)

			// Block until the client disconnects. We only push server→client,
			// but we must keep reading to detect close frames.
			var buf string
			for {
				if err := websocket.Message.Receive(ws, &buf); err != nil {
					break
				}
			}
		},
	}

	return func(c *gin.Context) {
		server.ServeHTTP(c.Writer, c.Request)
	}
}

// wsUserID extracts and validates the JWT from the ?token= query param.
func wsUserID(r *http.Request) (uint, error) {
	tokenStr := r.URL.Query().Get("token")
	if tokenStr == "" {
		// Also accept Bearer header (for testing with tools like websocat).
		auth := r.Header.Get("Authorization")
		parts := strings.SplitN(auth, " ", 2)
		if len(parts) == 2 {
			tokenStr = parts[1]
		}
	}
	if tokenStr == "" {
		return 0, errors.New("missing token")
	}

	secret := os.Getenv("JWT_SECRET")
	tok, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		if t.Method != jwt.SigningMethodHS256 {
			return nil, errors.New("invalid signing method")
		}
		return []byte(secret), nil
	})
	if err != nil || !tok.Valid {
		return 0, errors.New("invalid token")
	}

	claims, ok := tok.Claims.(jwt.MapClaims)
	if !ok {
		return 0, errors.New("bad claims")
	}
	uid, ok := claims["user_id"].(float64)
	if !ok || uid <= 0 {
		return 0, errors.New("bad user_id claim")
	}
	return uint(uid), nil
}
