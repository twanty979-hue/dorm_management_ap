package handlers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// 1. Send LINE OA Bill / Reminder / Broadcast
type SendLineMessageRequest struct {
	TenantID    int64  `json:"tenantId"`
	MessageType string `json:"messageType" binding:"required"` // BILL, RECEIPT, REMINDER, BROADCAST
	Title       string `json:"title"`
	Body        string `json:"body"`
}

func SendLineMessage(c *gin.Context) {
	var req SendLineMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	// Simulated LINE Messaging API dispatch
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": fmt.Sprintf("ส่งข้อความ LINE ประเภท %s ไปยังผู้เช่าเรียบร้อยแล้ว", req.MessageType),
		"data": gin.H{
			"deliveryStatus": "sent",
		},
	})
}

// 2. LINE Webhook Endpoint
func LineWebhook(c *gin.Context) {
	// Receive LINE Webhook Events
	c.JSON(http.StatusOK, gin.H{
		"status": "ok",
	})
}
