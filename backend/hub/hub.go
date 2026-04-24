package hub

import (
	"sync"

	"golang.org/x/net/websocket"
)

// client wraps a websocket connection with a write mutex.
// golang.org/x/net/websocket does not serialize concurrent writes.
type client struct {
	conn *websocket.Conn
	mu   sync.Mutex
}

func (c *client) send(msg string) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	return websocket.Message.Send(c.conn, msg)
}

// Hub maintains the set of active WebSocket connections keyed by user ID.
type Hub struct {
	mu      sync.RWMutex
	clients map[uint]*client
}

func New() *Hub {
	return &Hub{clients: make(map[uint]*client)}
}

// Register adds a connection for userID, closing any previous one.
func (h *Hub) Register(userID uint, conn *websocket.Conn) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if existing, ok := h.clients[userID]; ok {
		existing.conn.Close()
	}
	h.clients[userID] = &client{conn: conn}
}

// Unregister removes the connection for userID.
func (h *Hub) Unregister(userID uint) {
	h.mu.Lock()
	defer h.mu.Unlock()
	delete(h.clients, userID)
}

// Send delivers a JSON string to userID if they are connected.
// Returns true if the user was online.
func (h *Hub) Send(userID uint, payload string) bool {
	h.mu.RLock()
	c, ok := h.clients[userID]
	h.mu.RUnlock()
	if !ok {
		return false
	}
	if err := c.send(payload); err != nil {
		h.Unregister(userID)
		return false
	}
	return true
}
