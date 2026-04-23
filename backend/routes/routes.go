package routes

import (
	"openmarket/handlers"
	"openmarket/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func Setup(r *gin.Engine, db *gorm.DB) {
	auth := r.Group("/auth")
	{
		auth.POST("/register", handlers.Register(db))
		auth.POST("/login", handlers.Login(db))
	}
	authProtected := r.Group("/auth")
	authProtected.Use(middleware.AuthMiddleware())
	{
		authProtected.GET("/me", handlers.Me(db))
	}

	api := r.Group("/")
	api.Use(middleware.AuthMiddleware())
	{
		// Legacy listing routes kept for compatibility.
		api.POST("/listings", handlers.CreateListing(db))
		api.GET("/listings", handlers.GetListings(db))
		api.GET("/listings/:id", handlers.GetListingByID(db))
		api.PUT("/listings/:id", handlers.UpdateListing(db))
		api.DELETE("/listings/:id", handlers.DeleteListing(db))

		// Required product routes.
		api.POST("/products", handlers.CreateListing(db))
		api.GET("/products", handlers.GetListings(db))
		api.GET("/products/search", handlers.SearchListings(db))
		api.GET("/products/nearby", handlers.NearbyListings(db))
		api.GET("/products/:id", handlers.GetListingByID(db))
		api.PUT("/products/:id", handlers.UpdateListing(db))
		api.PATCH("/products/:id/sold", handlers.MarkAsSold(db))
		api.DELETE("/products/:id", handlers.DeleteListing(db))

		api.POST("/reviews", handlers.AddReview(db))
		api.DELETE("/reviews/:id", handlers.DeleteReview(db))
		api.GET("/users/:id/reviews", handlers.GetSellerReviews(db))

		api.POST("/favorites/:productId", handlers.AddFavorite(db))
		api.DELETE("/favorites/:productId", handlers.DeleteFavorite(db))
		api.GET("/favorites", handlers.GetFavorites(db))

		api.POST("/upload", handlers.UploadImage())

		api.POST("/reports", handlers.CreateReport(db))

		api.POST("/users/:id/block", handlers.BlockUser(db))
		api.DELETE("/users/:id/block", handlers.UnblockUser(db))
		api.GET("/blocks", handlers.GetBlockedUsers(db))

		api.POST("/offers", handlers.CreateOffer(db))
		api.GET("/offers/my", handlers.GetMyOffers(db))
		api.GET("/products/:id/offers", handlers.GetListingOffers(db))
		api.PATCH("/offers/:id", handlers.RespondToOffer(db))
		api.DELETE("/offers/:id", handlers.WithdrawOffer(db))

		api.POST("/messages", handlers.SendMessage(db))
		api.DELETE("/messages/:id", handlers.DeleteMessage(db))
		api.GET("/conversations", handlers.GetConversations(db))
		api.GET("/conversations/:id/messages", handlers.GetConversationMessages(db))
	}
}
