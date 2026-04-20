package tests

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"testing"

	"openmarket/database"
	"openmarket/models"
	"openmarket/routes"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/gorm"
)

func setupTest(t *testing.T) (*httptest.Server, *gorm.DB) {
	t.Helper()
	gin.SetMode(gin.TestMode)
	_ = os.Setenv("JWT_SECRET", "test-secret")

	db := database.ConnectTest()

	err := db.AutoMigrate(
		&models.User{},
		&models.Listing{},
		&models.Review{},
		&models.Favorite{},
		&models.Message{},
	)
	require.NoError(t, err)

	router := routes.SetupTestRouter(db)
	server := httptest.NewServer(router)

	return server, db
}

func doRequest(t *testing.T, server *httptest.Server, method, path string, body any, token string) *http.Response {
	t.Helper()

	var payload []byte
	if body != nil {
		var err error
		payload, err = json.Marshal(body)
		require.NoError(t, err)
	}

	req, err := http.NewRequest(method, server.URL+path, bytes.NewBuffer(payload))
	require.NoError(t, err)
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	resp, err := http.DefaultClient.Do(req)
	require.NoError(t, err)
	return resp
}

func decodeBody(t *testing.T, resp *http.Response, target any) {
	t.Helper()
	defer resp.Body.Close()
	require.NoError(t, json.NewDecoder(resp.Body).Decode(target))
}

func registerAndLogin(t *testing.T, server *httptest.Server, name, email string) (uint, string) {
	t.Helper()

	registerResp := doRequest(t, server, http.MethodPost, "/auth/register", map[string]any{
		"name":     name,
		"email":    email,
		"password": "password123",
	}, "")
	require.Equal(t, http.StatusCreated, registerResp.StatusCode)

	var registered map[string]any
	decodeBody(t, registerResp, &registered)
	userID := uint(registered["id"].(float64))

	loginResp := doRequest(t, server, http.MethodPost, "/auth/login", map[string]any{
		"email":    email,
		"password": "password123",
	}, "")
	require.Equal(t, http.StatusOK, loginResp.StatusCode)
	var login map[string]any
	decodeBody(t, loginResp, &login)

	return userID, login["token"].(string)
}

func TestAuthAndProfileFlows(t *testing.T) {
	server, _ := setupTest(t)
	defer server.Close()

	resp := doRequest(t, server, http.MethodPost, "/auth/register", map[string]any{
		"name":     "alice",
		"email":    "alice@example.com",
		"password": "password123",
	}, "")
	require.Equal(t, http.StatusCreated, resp.StatusCode)

	var registerBody map[string]any
	decodeBody(t, resp, &registerBody)
	assert.NotEmpty(t, registerBody["token"])
	user := registerBody["user"].(map[string]any)
	assert.Equal(t, "alice", user["name"])
	assert.Equal(t, "alice@example.com", user["email"])

	dupResp := doRequest(t, server, http.MethodPost, "/auth/register", map[string]any{
		"name":     "alice",
		"email":    "alice@example.com",
		"password": "password123",
	}, "")
	require.Equal(t, http.StatusConflict, dupResp.StatusCode)

	loginResp := doRequest(t, server, http.MethodPost, "/auth/login", map[string]any{
		"email":    "alice@example.com",
		"password": "password123",
	}, "")
	require.Equal(t, http.StatusOK, loginResp.StatusCode)
	var loginBody map[string]any
	decodeBody(t, loginResp, &loginBody)
	token := loginBody["token"].(string)
	require.NotEmpty(t, token)

	meResp := doRequest(t, server, http.MethodGet, "/auth/me", nil, token)
	require.Equal(t, http.StatusOK, meResp.StatusCode)
	var meBody map[string]any
	decodeBody(t, meResp, &meBody)
	assert.Equal(t, "alice@example.com", meBody["email"])
	assert.Equal(t, "alice", meBody["name"])

	badLoginResp := doRequest(t, server, http.MethodPost, "/auth/login", map[string]any{
		"email":    "alice@example.com",
		"password": "wrong-password",
	}, "")
	assert.Equal(t, http.StatusUnauthorized, badLoginResp.StatusCode)
}

func TestProductsFavoritesMessagesReviewsEndToEnd(t *testing.T) {
	server, _ := setupTest(t)
	defer server.Close()

	aliceID, tokenAlice := registerAndLogin(t, server, "Alice", "alice@example.com")
	bobID, tokenBob := registerAndLogin(t, server, "Bob", "bob@example.com")

	createResp := doRequest(t, server, http.MethodPost, "/products", map[string]any{
		"title":       "Gaming Laptop RTX",
		"description": "RTX machine for sale",
		"price":       1000.0,
		"category":    "Electronics",
		"location":    "Cairo",
		"images":      []string{"https://example.com/laptop-1.jpg", "https://example.com/laptop-2.jpg"},
		"latitude":    30.0444,
		"longitude":   31.2357,
		"user_id":     9999,
	}, tokenAlice)
	require.Equal(t, http.StatusCreated, createResp.StatusCode)

	var product models.Listing
	decodeBody(t, createResp, &product)
	require.NotZero(t, product.ID)
	assert.Equal(t, aliceID, product.UserID)
	assert.Equal(t, 2, len(product.Images))

	getByIDResp := doRequest(t, server, http.MethodGet, "/products/"+toPathID(product.ID), nil, tokenBob)
	require.Equal(t, http.StatusOK, getByIDResp.StatusCode)
	var fetched models.Listing
	decodeBody(t, getByIDResp, &fetched)
	assert.Equal(t, product.ID, fetched.ID)

	updateResp := doRequest(t, server, http.MethodPut, "/products/"+toPathID(product.ID), map[string]any{
		"title":       "Gaming Laptop RTX Updated",
		"description": "Updated description",
		"price":       1100.0,
		"category":    "Electronics",
		"location":    "Giza",
		"images":      []string{"https://example.com/laptop-updated.jpg"},
		"latitude":    30.0131,
		"longitude":   31.2089,
	}, tokenAlice)
	require.Equal(t, http.StatusOK, updateResp.StatusCode)
	var updated models.Listing
	decodeBody(t, updateResp, &updated)
	assert.Equal(t, "Gaming Laptop RTX Updated", updated.Title)
	assert.Equal(t, "Giza", updated.Location)
	assert.Equal(t, 1, len(updated.Images))

	allResp := doRequest(t, server, http.MethodGet, "/products?page=1&limit=10&search=Laptop", nil, tokenAlice)
	require.Equal(t, http.StatusOK, allResp.StatusCode)
	var allProducts []models.Listing
	decodeBody(t, allResp, &allProducts)
	require.NotEmpty(t, allProducts)

	searchResp := doRequest(t, server, http.MethodGet, "/products/search?category=Electronics&min_price=1000&max_price=1200&q=Updated", nil, tokenAlice)
	require.Equal(t, http.StatusOK, searchResp.StatusCode)
	var searched []models.Listing
	decodeBody(t, searchResp, &searched)
	require.Len(t, searched, 1)
	assert.Equal(t, updated.ID, searched[0].ID)

	nearbyResp := doRequest(t, server, http.MethodGet, "/products/nearby?lat=30.0131&lng=31.2089&radius_km=5", nil, tokenBob)
	require.Equal(t, http.StatusOK, nearbyResp.StatusCode)
	var nearby []models.Listing
	decodeBody(t, nearbyResp, &nearby)
	require.Len(t, nearby, 1)
	assert.Equal(t, updated.ID, nearby[0].ID)

	// Favorites
	favAddResp := doRequest(t, server, http.MethodPost, "/favorites/"+toPathID(updated.ID), nil, tokenBob)
	require.Equal(t, http.StatusOK, favAddResp.StatusCode)
	var fav models.Favorite
	decodeBody(t, favAddResp, &fav)
	assert.Equal(t, bobID, fav.UserID)
	assert.Equal(t, updated.ID, fav.ListingID)

	favsResp := doRequest(t, server, http.MethodGet, "/favorites", nil, tokenBob)
	require.Equal(t, http.StatusOK, favsResp.StatusCode)
	var favs []map[string]any
	decodeBody(t, favsResp, &favs)
	require.Len(t, favs, 1)
	productInFav := favs[0]["product"].(map[string]any)
	assert.Equal(t, float64(updated.ID), productInFav["id"])

	favDeleteResp := doRequest(t, server, http.MethodDelete, "/favorites/"+toPathID(updated.ID), nil, tokenBob)
	require.Equal(t, http.StatusOK, favDeleteResp.StatusCode)

	// Messaging
	msgSendResp := doRequest(t, server, http.MethodPost, "/messages", map[string]any{
		"receiver_id": bobID,
		"content":     "Hi Bob, still interested?",
	}, tokenAlice)
	require.Equal(t, http.StatusCreated, msgSendResp.StatusCode)
	var sentMsg models.Message
	decodeBody(t, msgSendResp, &sentMsg)
	require.NotZero(t, sentMsg.ID)
	assert.Equal(t, "Hi Bob, still interested?", sentMsg.Content)

	conversationsResp := doRequest(t, server, http.MethodGet, "/conversations", nil, tokenAlice)
	require.Equal(t, http.StatusOK, conversationsResp.StatusCode)
	var convs []map[string]any
	decodeBody(t, conversationsResp, &convs)
	require.Len(t, convs, 1)
	assert.Equal(t, float64(bobID), convs[0]["id"])

	conversationMessagesResp := doRequest(t, server, http.MethodGet, "/conversations/"+toPathID(bobID)+"/messages", nil, tokenAlice)
	require.Equal(t, http.StatusOK, conversationMessagesResp.StatusCode)
	var convMessages []models.Message
	decodeBody(t, conversationMessagesResp, &convMessages)
	require.Len(t, convMessages, 1)
	assert.Equal(t, sentMsg.ID, convMessages[0].ID)

	// Reviews
	reviewResp := doRequest(t, server, http.MethodPost, "/reviews", map[string]any{
		"seller_id": aliceID,
		"rating":    5,
		"comment":   "Great seller and smooth deal",
	}, tokenBob)
	require.Equal(t, http.StatusCreated, reviewResp.StatusCode)
	var review models.Review
	decodeBody(t, reviewResp, &review)
	require.NotZero(t, review.ID)
	assert.Equal(t, bobID, review.ReviewerID)
	assert.Equal(t, aliceID, review.SellerID)

	getSellerReviewsResp := doRequest(t, server, http.MethodGet, "/users/"+toPathID(aliceID)+"/reviews", nil, tokenAlice)
	require.Equal(t, http.StatusOK, getSellerReviewsResp.StatusCode)
	var sellerReviews map[string]any
	decodeBody(t, getSellerReviewsResp, &sellerReviews)
	assert.Equal(t, float64(aliceID), sellerReviews["seller_id"])
	assert.Equal(t, float64(5), sellerReviews["average_rating"])
	assert.Equal(t, float64(1), sellerReviews["reviews_count"])
	reviewList := sellerReviews["reviews"].([]any)
	require.Len(t, reviewList, 1)

	// Cleanup checks for APIs also documented in server routes.
	reviewDeleteResp := doRequest(t, server, http.MethodDelete, "/reviews/"+toPathID(review.ID), nil, tokenBob)
	require.Equal(t, http.StatusOK, reviewDeleteResp.StatusCode)

	messageDeleteResp := doRequest(t, server, http.MethodDelete, "/messages/"+toPathID(sentMsg.ID), nil, tokenAlice)
	require.Equal(t, http.StatusOK, messageDeleteResp.StatusCode)

	productDeleteResp := doRequest(t, server, http.MethodDelete, "/products/"+toPathID(updated.ID), nil, tokenAlice)
	require.Equal(t, http.StatusOK, productDeleteResp.StatusCode)
}

func TestProtectedRoutesRequireAuth(t *testing.T) {
	server, _ := setupTest(t)
	defer server.Close()

	protectedRequests := []struct {
		method string
		path   string
		body   any
	}{
		{method: http.MethodGet, path: "/auth/me"},
		{method: http.MethodPost, path: "/products", body: map[string]any{"title": "NoAuth", "price": 10}},
		{method: http.MethodGet, path: "/products"},
		{method: http.MethodGet, path: "/products/search"},
		{method: http.MethodGet, path: "/products/nearby?lat=30&lng=31"},
		{method: http.MethodPost, path: "/favorites/1"},
		{method: http.MethodGet, path: "/favorites"},
		{method: http.MethodPost, path: "/messages", body: map[string]any{"receiver_id": 1, "content": "hello"}},
		{method: http.MethodGet, path: "/conversations"},
		{method: http.MethodGet, path: "/conversations/1/messages"},
		{method: http.MethodPost, path: "/reviews", body: map[string]any{"seller_id": 1, "rating": 5}},
		{method: http.MethodGet, path: "/users/1/reviews"},
	}

	for _, req := range protectedRequests {
		resp := doRequest(t, server, req.method, req.path, req.body, "")
		assert.Equal(t, http.StatusUnauthorized, resp.StatusCode, req.method+" "+req.path)
	}
}

func toPathID(id uint) string {
	return strconv.FormatUint(uint64(id), 10)
}
