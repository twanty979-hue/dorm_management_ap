package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"dorm_backend_api/database"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TenantWithLeaseResponse DTO for frontend
type TenantWithLeaseResponse struct {
	ID             int64   `json:"id"`
	FullName       string  `json:"fullName"`
	Phone          string  `json:"phone"`
	IDCardNumber   string  `json:"idCardNumber"`
	LineUserID     string  `json:"lineUserId"`
	RoomNumber     string  `json:"roomNumber"`
	Floor          int     `json:"floor"`
	MonthlyRent    float64 `json:"monthlyRent"`
	DepositAmount  float64 `json:"depositAmount"`
	StartDate      string  `json:"startDate"`
	EndDate        string  `json:"endDate"`
	Status         string  `json:"status"`
	IsExpiringSoon bool    `json:"isExpiringSoon"`
}

// 1. Get Tenants with Multi-Tenant org_id Isolation & Lease Join
func GetTenants(c *gin.Context) {
	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	resultList := make([]TenantWithLeaseResponse, 0)

	if database.Client != nil {
		// 1. Query tenants
		tenantsData, err := database.Client.From("tenants").Eq("org_id", orgID.String()).Order("id", false).Select("*")
		if err == nil && len(tenantsData) > 0 {
			var rawTenants []map[string]interface{}
			_ = json.Unmarshal(tenantsData, &rawTenants)

			// 2. Query leases
			leasesData, _ := database.Client.From("lease_agreements").Eq("org_id", orgID.String()).Select("*")
			var rawLeases []map[string]interface{}
			if len(leasesData) > 0 {
				_ = json.Unmarshal(leasesData, &rawLeases)
			}

			// 3. Query rooms
			roomsData, _ := database.Client.From("rooms").Eq("org_id", orgID.String()).Select("*")
			var rawRooms []map[string]interface{}
			if len(roomsData) > 0 {
				_ = json.Unmarshal(roomsData, &rawRooms)
			}

			// Map rooms by ID
			roomMap := make(map[int64]map[string]interface{})
			for _, r := range rawRooms {
				if idVal, ok := r["id"].(float64); ok {
					roomMap[int64(idVal)] = r
				}
			}

			// Map leases by TenantID
			leaseMap := make(map[int64]map[string]interface{})
			for _, l := range rawLeases {
				if tIDVal, ok := l["tenant_id"].(float64); ok {
					leaseMap[int64(tIDVal)] = l
				}
			}

			// Build enriched DTO
			for _, t := range rawTenants {
				var tID int64
				if idVal, ok := t["id"].(float64); ok {
					tID = int64(idVal)
				}

				name := ""
				if fn, ok := t["full_name"].(string); ok {
					name = fn
				} else if fn, ok := t["fullName"].(string); ok {
					name = fn
				}

				phone := ""
				if ph, ok := t["phone"].(string); ok {
					phone = ph
				}

				idCard := ""
				if ic, ok := t["id_card_number"].(string); ok {
					idCard = ic
				} else if ic, ok := t["idCardNumber"].(string); ok {
					idCard = ic
				}

				lineID := ""
				if l, ok := t["line_user_id"].(string); ok {
					lineID = l
				}
				if lineID == "" {
					lineID = phone
				}

				lease, hasLease := leaseMap[tID]
				roomNum := "101"
				floor := 1
				monthlyRent := 4500.0
				deposit := 9000.0
				startStr := "01/01/2026"
				endStr := "31/12/2026"
				status := "active"

				if hasLease {
					if mr, ok := lease["monthly_rent"].(float64); ok {
						monthlyRent = mr
					}
					if da, ok := lease["deposit_amount"].(float64); ok {
						deposit = da
					}
					if s, ok := lease["status"].(string); ok {
						status = s
					}
					if sd, ok := lease["start_date"].(string); ok {
						startStr = sd
					}
					if ed, ok := lease["end_date"].(string); ok {
						endStr = ed
					}
					if rIDVal, ok := lease["room_id"].(float64); ok {
						if r, found := roomMap[int64(rIDVal)]; found {
							if rn, ok := r["room_number"].(string); ok {
								roomNum = rn
							}
							if fl, ok := r["floor"].(float64); ok {
								floor = int(fl)
							}
						}
					}
				}

				resultList = append(resultList, TenantWithLeaseResponse{
					ID:             tID,
					FullName:       name,
					Phone:          phone,
					IDCardNumber:   idCard,
					LineUserID:     lineID,
					RoomNumber:     roomNum,
					Floor:          floor,
					MonthlyRent:    monthlyRent,
					DepositAmount:  deposit,
					StartDate:      startStr,
					EndDate:        endStr,
					Status:         status,
					IsExpiringSoon: false,
				})
			}
		}
	}

	log.Printf("👥 [TENANTS SAAS] org_id: %s, found %d tenants with live leases", orgID.String(), len(resultList))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    resultList,
	})
}

// 2. Create Lease & Tenant
type CreateLeaseRequest struct {
	RoomID        int64   `json:"roomId" binding:"required"`
	DormID        int64   `json:"dormId"`
	FullName      string  `json:"fullName" binding:"required"`
	Phone         string  `json:"phone" binding:"required"`
	IDCardNumber  string  `json:"idCardNumber"`
	StartDate     string  `json:"startDate" binding:"required"`
	EndDate       string  `json:"endDate" binding:"required"`
	MonthlyRent   float64 `json:"monthlyRent" binding:"required"`
	DepositAmount float64 `json:"depositAmount"`
	WaterRate     float64 `json:"waterRate"`
	ElectricRate  float64 `json:"electricRate"`
}

func CreateLease(c *gin.Context) {
	var req CreateLeaseRequest
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

	log.Printf("📥 [CREATE TENANT LEASE] Org: %s, Name: %s, RoomID: %d, Water: %.2f, Elec: %.2f", currentOrgID.String(), req.FullName, req.RoomID, req.WaterRate, req.ElectricRate)

	var tenantID int64 = 0

	if database.Client != nil {
		resp, err := database.Client.From("tenants").Insert(map[string]interface{}{
			"org_id":         currentOrgID.String(),
			"full_name":      req.FullName,
			"phone":          req.Phone,
			"id_card_number": req.IDCardNumber,
			"line_user_id":   req.Phone,
		})
		if err != nil {
			log.Printf("❌ Supabase insert tenant error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}

		var createdTenants []map[string]interface{}
		_ = json.Unmarshal(resp, &createdTenants)
		if len(createdTenants) > 0 {
			if idVal, ok := createdTenants[0]["id"].(float64); ok {
				tenantID = int64(idVal)
			}
		}

		// Insert lease agreement
		leasePayload := map[string]interface{}{
			"org_id":         currentOrgID.String(),
			"dorm_id":        1,
			"room_id":        req.RoomID,
			"tenant_id":      tenantID,
			"start_date":     req.StartDate,
			"end_date":       req.EndDate,
			"monthly_rent":   req.MonthlyRent,
			"deposit_amount": req.DepositAmount,
			"status":         "active",
		}
		if req.WaterRate > 0 {
			leasePayload["water_rate"] = req.WaterRate
		}
		if req.ElectricRate > 0 {
			leasePayload["electric_rate"] = req.ElectricRate
		}
		_, _ = database.Client.From("lease_agreements").Insert(leasePayload)

		// Update room status to occupied
		_, _ = database.Client.From("rooms").Eq("id", strconv.FormatInt(req.RoomID, 10)).Update(map[string]string{
			"status": "occupied",
		})
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "สร้างสัญญาเช่าและเพิ่มผู้เช่าสำเร็จ",
		"data": gin.H{
			"tenantId": tenantID,
			"fullName": req.FullName,
			"roomId":   req.RoomID,
		},
	})
}

// 3. Terminate Lease / Tenant Checkout
func TerminateLease(c *gin.Context) {
	tenantIDStr := c.Param("id")
	tenantID, err := strconv.ParseInt(tenantIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": "Invalid Tenant ID"}})
		return
	}

	orgIDVal, _ := c.Get("org_id")
	orgID := orgIDVal.(uuid.UUID)

	if database.Client != nil {
		// 1. Find Lease
		leasesData, _ := database.Client.From("lease_agreements").Eq("tenant_id", strconv.FormatInt(tenantID, 10)).Eq("org_id", orgID.String()).Select("*")
		var leases []map[string]interface{}
		_ = json.Unmarshal(leasesData, &leases)

		if len(leases) > 0 {
			var roomID int64
			var leaseID int64
			if rVal, ok := leases[0]["room_id"].(float64); ok {
				roomID = int64(rVal)
			}
			if lVal, ok := leases[0]["id"].(float64); ok {
				leaseID = int64(lVal)
			}

			// Set lease terminated
			_, _ = database.Client.From("lease_agreements").Eq("id", strconv.FormatInt(leaseID, 10)).Update(map[string]string{
				"status": "terminated",
			})
			// Set room vacant
			_, _ = database.Client.From("rooms").Eq("id", strconv.FormatInt(roomID, 10)).Update(map[string]string{
				"status": "vacant",
			})
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "ดำเนินการย้ายออกและคืนห้องพักเรียบร้อยแล้ว",
	})
}
