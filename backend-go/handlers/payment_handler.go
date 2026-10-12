package handlers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"dorm_backend_api/database"
	"dorm_backend_api/models"

	"github.com/gin-gonic/gin"
)

// 1. Submit Payment Slip
type SubmitPaymentRequest struct {
	InvoiceID     int64   `json:"invoiceId" binding:"required"`
	Amount        float64 `json:"amount" binding:"required"`
	PaymentMethod string  `json:"paymentMethod"`
	SlipImageURL  string  `json:"slipImageUrl"`
}

func SubmitPayment(c *gin.Context) {
	var req SubmitPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	payment := models.Payment{
		InvoiceID:     req.InvoiceID,
		Amount:        req.Amount,
		PaymentMethod: req.PaymentMethod,
		SlipImageURL:  req.SlipImageURL,
		PaidAt:        time.Now(),
	}

	if database.DB != nil {
		database.DB.Create(&payment)
		// Update invoice status to pending_verification
		database.DB.Model(&models.Invoice{}).Where("id = ?", req.InvoiceID).Update("status", "pending_verification")
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "ส่งหลักฐานการโอนเงินเรียบร้อย รอเจ้าของหอพักตรวจสอบ",
		"data":    payment,
	})
}

// 2. Approve Payment & Issue e-Receipt
func ApprovePayment(c *gin.Context) {
	invoiceIDStr := c.Param("invoiceId")
	invoiceID, _ := strconv.ParseInt(invoiceIDStr, 10, 64)

	receiptNum := fmt.Sprintf("REC-%s-%03d", time.Now().Format("200601"), invoiceID)

	if database.DB != nil {
		now := time.Now()
		database.DB.Model(&models.Invoice{}).Where("id = ?", invoiceID).Update("status", "paid")
		database.DB.Model(&models.Payment{}).Where("invoice_id = ?", invoiceID).Updates(map[string]interface{}{
			"verified_at":    now,
			"receipt_number": receiptNum,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "อนุมัติการชำระเงินและออกใบเสร็จเรียบร้อยแล้ว",
		"data": gin.H{
			"receiptNumber": receiptNum,
			"status":        "paid",
		},
	})
}
