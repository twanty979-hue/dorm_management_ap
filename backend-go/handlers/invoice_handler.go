package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"dorm_backend_api/database"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type InvoiceResponse struct {
	ID            int64   `json:"id"`
	InvoiceNumber string  `json:"invoiceNumber"`
	RoomNumber    string  `json:"roomNumber"`
	TenantName    string  `json:"tenantName"`
	BillingMonth  string  `json:"billingMonth"`
	RentAmount    float64 `json:"rentAmount"`
	WaterUnits    float64 `json:"waterUnits"`
	WaterTotal    float64 `json:"waterTotal"`
	ElectricUnits float64 `json:"electricUnits"`
	ElectricTotal float64 `json:"electricTotal"`
	AdditionalFee float64 `json:"additionalFee"`
	Discount      float64 `json:"discount"`
	GrandTotal    float64 `json:"grandTotal"`
	DueDate       string  `json:"dueDate"`
	Status        string  `json:"status"`
	CreatedAt     string  `json:"createdAt"`
}

// 1. Get Invoices with live Supabase rooms & tenants join
func GetInvoices(c *gin.Context) {
	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	resultList := make([]InvoiceResponse, 0)

	if database.Client != nil {
		// 1. Query invoices
		invData, err := database.Client.From("invoices").Eq("org_id", orgID.String()).Order("id", false).Select("*")
		if err == nil && len(invData) > 0 {
			var invoices []map[string]interface{}
			_ = json.Unmarshal(invData, &invoices)

			// 2. Query rooms
			roomsData, _ := database.Client.From("rooms").Eq("org_id", orgID.String()).Select("*")
			var rooms []map[string]interface{}
			_ = json.Unmarshal(roomsData, &rooms)
			roomMap := make(map[int64]string)
			for _, r := range rooms {
				if rIDVal, ok := r["id"].(float64); ok {
					rNum := "101"
					if rn, ok := r["room_number"].(string); ok {
						rNum = rn
					}
					roomMap[int64(rIDVal)] = rNum
				}
			}

			// 3. Query tenants
			tenantsData, _ := database.Client.From("tenants").Eq("org_id", orgID.String()).Select("*")
			var tenants []map[string]interface{}
			_ = json.Unmarshal(tenantsData, &tenants)
			tenantMap := make(map[int64]string)
			for _, t := range tenants {
				if tIDVal, ok := t["id"].(float64); ok {
					name := "ผู้เช่า"
					if fn, ok := t["full_name"].(string); ok && fn != "" {
						name = fn
					}
					tenantMap[int64(tIDVal)] = name
				}
			}

			for _, inv := range invoices {
				var id int64
				if idVal, ok := inv["id"].(float64); ok {
					id = int64(idVal)
				}

				invNum := ""
				if in, ok := inv["invoice_number"].(string); ok {
					invNum = in
				}

				roomNum := "101"
				if rIDVal, ok := inv["room_id"].(float64); ok {
					if rn, found := roomMap[int64(rIDVal)]; found {
						roomNum = rn
					}
				}

				tenantName := "ผู้เช่า"
				if tIDVal, ok := inv["tenant_id"].(float64); ok {
					if tn, found := tenantMap[int64(tIDVal)]; found {
						tenantName = tn
					}
				}

				billingMonth := ""
				if bm, ok := inv["billing_month"].(string); ok {
					billingMonth = bm
				}

				rent := 0.0
				if ra, ok := inv["rent_amount"].(float64); ok {
					rent = ra
				}

				wUnits := 0.0
				if wu, ok := inv["water_units"].(float64); ok {
					wUnits = wu
				}
				wTotal := 0.0
				if wt, ok := inv["water_total"].(float64); ok {
					wTotal = wt
				}

				eUnits := 0.0
				if eu, ok := inv["electric_units"].(float64); ok {
					eUnits = eu
				}
				eTotal := 0.0
				if et, ok := inv["electric_total"].(float64); ok {
					eTotal = et
				}

				addFee := 0.0
				if af, ok := inv["additional_fee"].(float64); ok {
					addFee = af
				}

				disc := 0.0
				if d, ok := inv["discount"].(float64); ok {
					disc = d
				}

				grandTotal := 0.0
				if gt, ok := inv["grand_total"].(float64); ok {
					grandTotal = gt
				}

				dueDate := ""
				if dd, ok := inv["due_date"].(string); ok {
					dueDate = dd
				}

				status := "unpaid"
				if st, ok := inv["status"].(string); ok {
					status = st
				}

				createdAt := ""
				if ca, ok := inv["created_at"].(string); ok {
					createdAt = ca
				}

				resultList = append(resultList, InvoiceResponse{
					ID:            id,
					InvoiceNumber: invNum,
					RoomNumber:    roomNum,
					TenantName:    tenantName,
					BillingMonth:  billingMonth,
					RentAmount:    rent,
					WaterUnits:    wUnits,
					WaterTotal:    wTotal,
					ElectricUnits: eUnits,
					ElectricTotal: eTotal,
					AdditionalFee: addFee,
					Discount:      disc,
					GrandTotal:    grandTotal,
					DueDate:       dueDate,
					Status:        status,
					CreatedAt:     createdAt,
				})
			}
		}
	}

	log.Printf("🧾 [INVOICES SAAS] org_id: %s, found %d invoices", orgID.String(), len(resultList))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    resultList,
	})
}

// 2. Create Invoice into Supabase
type CreateInvoiceRequest struct {
	DormID        int64   `json:"dormId"`
	RoomID        int64   `json:"roomId" binding:"required"`
	TenantID      int64   `json:"tenantId"`
	RoomNumber    string  `json:"roomNumber"`
	BillingMonth  string  `json:"billingMonth"`
	RentAmount    float64 `json:"rentAmount" binding:"required"`
	WaterUnits    float64 `json:"waterUnits"`
	WaterTotal    float64 `json:"waterTotal"`
	ElectricUnits float64 `json:"electricUnits"`
	ElectricTotal float64 `json:"electricTotal"`
	AdditionalFee float64 `json:"additionalFee"`
	Discount      float64 `json:"discount"`
	GrandTotal    float64 `json:"grandTotal"`
	DueDate       string  `json:"dueDate"`
}

func CreateInvoice(c *gin.Context) {
	var req CreateInvoiceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	orgIDVal, exists := c.Get("org_id")
	var currentOrgID uuid.UUID
	if exists {
		currentOrgID = orgIDVal.(uuid.UUID)
	} else {
		currentOrgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	if req.DormID == 0 {
		req.DormID = 1
	}
	if req.BillingMonth == "" {
		req.BillingMonth = time.Now().Format("2006-01")
	}
	if req.DueDate == "" {
		req.DueDate = time.Now().AddDate(0, 0, 7).Format("2006-01-02")
	}
	if req.GrandTotal == 0 {
		req.GrandTotal = req.RentAmount + req.WaterTotal + req.ElectricTotal + req.AdditionalFee - req.Discount
	}

	invNum := fmt.Sprintf("INV-%s-%s-%d", time.Now().Format("200601"), req.RoomNumber, time.Now().Unix()%1000)

	log.Printf("📥 [CREATE INVOICE] Org: %s, Room: %s, Total: %.2f", currentOrgID.String(), req.RoomNumber, req.GrandTotal)

	var createdInvoice map[string]interface{}

	if database.Client != nil {
		insertData := map[string]interface{}{
			"org_id":         currentOrgID.String(),
			"dorm_id":        req.DormID,
			"room_id":        req.RoomID,
			"tenant_id":      req.TenantID,
			"invoice_number": invNum,
			"billing_month":  req.BillingMonth,
			"rent_amount":    req.RentAmount,
			"water_units":    req.WaterUnits,
			"water_total":    req.WaterTotal,
			"electric_units": req.ElectricUnits,
			"electric_total": req.ElectricTotal,
			"additional_fee": req.AdditionalFee,
			"discount":       req.Discount,
			"grand_total":    req.GrandTotal,
			"due_date":       req.DueDate,
			"status":         "unpaid",
		}

		resp, err := database.Client.From("invoices").Insert(insertData)
		if err != nil {
			log.Printf("❌ Supabase insert invoice error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
		var created []map[string]interface{}
		_ = json.Unmarshal(resp, &created)
		if len(created) > 0 {
			createdInvoice = created[0]
		} else {
			createdInvoice = insertData
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": fmt.Sprintf("ออกใบแจ้งหนี้ %s เรียบร้อยแล้ว", invNum),
		"data":    createdInvoice,
	})
}

// 3. Update Invoice Status / Approve Payment
func UpdateInvoiceStatus(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": "Invalid Invoice ID"}})
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"` // paid, pending_verification, unpaid
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	if database.Client != nil {
		_, err := database.Client.From("invoices").Eq("id", strconv.FormatInt(id, 10)).Update(map[string]interface{}{
			"status": req.Status,
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": fmt.Sprintf("อัปเดตสถานะใบแจ้งหนี้เป็น %s เรียบร้อยแล้ว", req.Status),
	})
}
