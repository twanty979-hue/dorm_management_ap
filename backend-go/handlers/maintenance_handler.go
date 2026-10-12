package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"time"

	"dorm_backend_api/database"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MaintenanceTicketResponse struct {
	ID             int64   `json:"id"`
	RoomID         int64   `json:"roomId"`
	RoomNumber     string  `json:"roomNumber"`
	Title          string  `json:"title"`
	Description    string  `json:"description"`
	Priority       string  `json:"priority"`
	Status         string  `json:"status"`
	TechnicianName string  `json:"technicianName"`
	Cost           float64 `json:"cost"`
	CreatedAt      string  `json:"createdAt"`
	ReporterName   string  `json:"reporterName"`
	ReporterPhone  string  `json:"reporterPhone"`
}

// 1. Get Maintenance Tickets with live Supabase rooms & tenants join
func GetMaintenanceTickets(c *gin.Context) {
	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	resultList := make([]MaintenanceTicketResponse, 0)

	if database.Client != nil {
		data, err := database.Client.From("maintenance_tickets").Eq("org_id", orgID.String()).Order("id", false).Select("*")
		if err == nil && len(data) > 0 {
			var rawTickets []map[string]interface{}
			_ = json.Unmarshal(data, &rawTickets)

			// Query rooms
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

			// Query tenants
			tenantsData, _ := database.Client.From("tenants").Eq("org_id", orgID.String()).Select("*")
			var tenants []map[string]interface{}
			_ = json.Unmarshal(tenantsData, &tenants)
			tenantMap := make(map[int64]map[string]string)
			for _, t := range tenants {
				if tIDVal, ok := t["id"].(float64); ok {
					name := "ผู้เช่า"
					if fn, ok := t["full_name"].(string); ok && fn != "" {
						name = fn
					}
					phone := ""
					if ph, ok := t["phone"].(string); ok {
						phone = ph
					}
					tenantMap[int64(tIDVal)] = map[string]string{"name": name, "phone": phone}
				}
			}

			for _, tk := range rawTickets {
				var id int64
				if idVal, ok := tk["id"].(float64); ok {
					id = int64(idVal)
				}

				var roomID int64
				if rVal, ok := tk["room_id"].(float64); ok {
					roomID = int64(rVal)
				}

				roomNum := "101"
				if rn, found := roomMap[roomID]; found {
					roomNum = rn
				}

				title := "แจ้งซ่อมทั่วไป"
				if t, ok := tk["title"].(string); ok && t != "" {
					title = t
				}

				desc := ""
				if d, ok := tk["description"].(string); ok {
					desc = d
				}

				priority := "normal"
				if p, ok := tk["priority"].(string); ok {
					priority = p
				}

				status := "pending"
				if s, ok := tk["status"].(string); ok {
					status = s
				}

				tech := "ยังไม่ระบุช่าง"
				if tn, ok := tk["technician_name"].(string); ok && tn != "" {
					tech = tn
				}

				cost := 0.0
				if c, ok := tk["cost"].(float64); ok {
					cost = c
				}

				createdAt := time.Now().Format(time.RFC3339)
				if ca, ok := tk["created_at"].(string); ok {
					createdAt = ca
				}

				repName := "ผู้เช่า"
				repPhone := "081-000-0000"
				if tIDVal, ok := tk["tenant_id"].(float64); ok {
					if tInfo, found := tenantMap[int64(tIDVal)]; found {
						repName = tInfo["name"]
						repPhone = tInfo["phone"]
					}
				}

				resultList = append(resultList, MaintenanceTicketResponse{
					ID:             id,
					RoomID:         roomID,
					RoomNumber:     roomNum,
					Title:          title,
					Description:    desc,
					Priority:       priority,
					Status:         status,
					TechnicianName: tech,
					Cost:           cost,
					CreatedAt:      createdAt,
					ReporterName:   repName,
					ReporterPhone:  repPhone,
				})
			}
		}
	}

	log.Printf("🔧 [MAINTENANCE SAAS] org_id: %s, found %d tickets", orgID.String(), len(resultList))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    resultList,
	})
}

// 2. Create Maintenance Ticket
type CreateTicketRequest struct {
	DormID      int64  `json:"dormId"`
	RoomID      int64  `json:"roomId"`
	RoomNumber  string `json:"roomNumber"`
	Title       string `json:"title" binding:"required"`
	Description string `json:"description"`
	Priority    string `json:"priority"` // normal, urgent, low
}

func CreateMaintenanceTicket(c *gin.Context) {
	var req CreateTicketRequest
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
	if req.Priority == "" {
		req.Priority = "normal"
	}

	// If roomId not passed, find by roomNumber
	if req.RoomID == 0 && req.RoomNumber != "" && database.Client != nil {
		rData, _ := database.Client.From("rooms").Eq("org_id", currentOrgID.String()).Eq("room_number", req.RoomNumber).Select("id")
		var rooms []map[string]interface{}
		_ = json.Unmarshal(rData, &rooms)
		if len(rooms) > 0 {
			if idVal, ok := rooms[0]["id"].(float64); ok {
				req.RoomID = int64(idVal)
			}
		}
	}
	if req.RoomID == 0 {
		req.RoomID = 1
	}

	log.Printf("📥 [CREATE MAINTENANCE] Org: %s, Title: %s, RoomID: %d", currentOrgID.String(), req.Title, req.RoomID)

	var createdTicket map[string]interface{}

	if database.Client != nil {
		insertData := map[string]interface{}{
			"org_id":          currentOrgID.String(),
			"dorm_id":         req.DormID,
			"room_id":         req.RoomID,
			"title":           req.Title,
			"description":     req.Description,
			"priority":        req.Priority,
			"status":          "pending",
			"technician_name": "ยังไม่ระบุช่าง",
			"cost":            0,
		}

		resp, err := database.Client.From("maintenance_tickets").Insert(insertData)
		if err != nil {
			log.Printf("❌ Supabase insert maintenance error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
		var created []map[string]interface{}
		_ = json.Unmarshal(resp, &created)
		if len(created) > 0 {
			createdTicket = created[0]
		} else {
			createdTicket = insertData
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "สร้างรายการแจ้งซ่อมเรียบร้อยแล้ว",
		"data":    createdTicket,
	})
}

// 3. Update Maintenance Ticket (Status / Technician / Cost)
func UpdateMaintenanceTicket(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": "Invalid Ticket ID"}})
		return
	}

	var req struct {
		Status         string  `json:"status"`
		TechnicianName string  `json:"technicianName"`
		RepairCost     float64 `json:"repairCost"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	updateMap := make(map[string]interface{})
	if req.Status != "" {
		updateMap["status"] = req.Status
	}
	if req.TechnicianName != "" {
		updateMap["technician_name"] = req.TechnicianName
	}
	if req.RepairCost > 0 {
		updateMap["cost"] = req.RepairCost
	}

	if database.Client != nil && len(updateMap) > 0 {
		_, err := database.Client.From("maintenance_tickets").Eq("id", strconv.FormatInt(id, 10)).Update(updateMap)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "อัปเดตสถานะรายการแจ้งซ่อมเรียบร้อยแล้ว",
	})
}
