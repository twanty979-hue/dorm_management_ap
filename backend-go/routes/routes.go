package routes

import (
	"net/http"

	"dorm_backend_api/handlers"
	"dorm_backend_api/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	// Global Middlewares
	r.Use(middleware.CORSMiddleware())

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"service": "Dormitory Management SaaS API (Go / Gin)",
			"version": "1.0.0",
		})
	})

	// API v1 Group
	v1 := r.Group("/api/v1")
	{
		// 1. Auth Endpoints
		auth := v1.Group("/auth")
		{
			auth.POST("/register", handlers.Register)
			auth.POST("/login", handlers.Login)
		}

		// 2. LINE Webhook Endpoint (No auth required)
		v1.POST("/line/webhook", handlers.LineWebhook)

		// Authenticated Routes
		api := v1.Group("")
		api.Use(middleware.AuthMiddleware())
		{
			// Properties / Branches
			api.GET("/properties", handlers.GetProperties)
			api.POST("/properties", handlers.CreateProperty)
			api.PATCH("/properties/:id", handlers.UpdatePropertySettings)

			// Rooms
			api.GET("/rooms", handlers.GetRooms)
			api.POST("/rooms", handlers.CreateRoom)
			api.PATCH("/rooms/:id/status", handlers.UpdateRoomStatus)

			// Tenants & Leases
			api.GET("/tenants", handlers.GetTenants)
			api.POST("/leases", handlers.CreateLease)
			api.DELETE("/tenants/:id", handlers.TerminateLease)

			// Meter Readings
			api.GET("/meters", handlers.GetMeters)
			api.POST("/meters/batch-record", handlers.RecordMeters)

			// Invoices & Billing
			api.GET("/invoices", handlers.GetInvoices)
			api.POST("/invoices", handlers.CreateInvoice)
			api.POST("/invoices/generate", handlers.CreateInvoice)
			api.PATCH("/invoices/:id/status", handlers.UpdateInvoiceStatus)

			// Payments & Slips
			api.POST("/payments/submit-slip", handlers.SubmitPayment)
			api.PATCH("/payments/:invoiceId/approve", handlers.ApprovePayment)

			// Maintenance Tickets
			api.GET("/maintenance", handlers.GetMaintenanceTickets)
			api.POST("/maintenance", handlers.CreateMaintenanceTicket)
			api.PATCH("/maintenance/:id", handlers.UpdateMaintenanceTicket)

			// LINE OA Messaging
			api.POST("/line/send-message", handlers.SendLineMessage)

			// Reports & Analytics
			api.GET("/reports/financial-summary", handlers.GetFinancialSummary)
		}
	}

	return r
}
