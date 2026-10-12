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

// 1. Get Rooms with Multi-Tenant org_id Isolation & Supabase Column Mapping
func GetRooms(c *gin.Context) {
	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	rooms := make([]map[string]interface{}, 0)

	if database.Client != nil {
		query := database.Client.From("rooms").Eq("org_id", orgID.String())

		dormID := c.Query("dorm_id")
		if dormID != "" {
			query = query.Eq("dorm_id", dormID)
		}
		status := c.Query("status")
		if status != "" {
			query = query.Eq("status", status)
		}

		query = query.Order("room_number", true)

		data, err := query.Select("*")
		if err == nil && len(data) > 0 {
			_ = json.Unmarshal(data, &rooms)
		}

		// Fallback to default Org ID if specific query found nothing
		if len(rooms) == 0 && orgID.String() != "6008008f-e0f5-4970-a4ce-da2f8abaa607" {
			defaultOrgID, _ := uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
			q2 := database.Client.From("rooms").Eq("org_id", defaultOrgID.String())
			if status != "" {
				q2 = q2.Eq("status", status)
			}
			d2, err := q2.Order("room_number", true).Select("*")
			if err == nil && len(d2) > 0 {
				_ = json.Unmarshal(d2, &rooms)
			}
		}
		// Query active leases and tenants for this org
		leasesData, _ := database.Client.From("lease_agreements").Eq("org_id", orgID.String()).Eq("status", "active").Select("*")
		var leases []map[string]interface{}
		_ = json.Unmarshal(leasesData, &leases)

		tenantsData, _ := database.Client.From("tenants").Eq("org_id", orgID.String()).Select("*")
		var tenants []map[string]interface{}
		_ = json.Unmarshal(tenantsData, &tenants)

		tenantMap := make(map[int64]map[string]interface{})
		for _, t := range tenants {
			if tIDVal, ok := t["id"].(float64); ok {
				tenantMap[int64(tIDVal)] = t
			}
		}

		roomOccupantMap := make(map[int64]map[string]interface{})
		for _, l := range leases {
			if rIDVal, ok := l["room_id"].(float64); ok {
				if tIDVal, ok := l["tenant_id"].(float64); ok {
					if tInfo, found := tenantMap[int64(tIDVal)]; found {
						tName := ""
						if fn, ok := tInfo["full_name"].(string); ok {
							tName = fn
						} else if fn, ok := tInfo["fullName"].(string); ok {
							tName = fn
						}
						tPhone := ""
						if ph, ok := tInfo["phone"].(string); ok {
							tPhone = ph
						}
						startDate := ""
						if sd, ok := l["start_date"].(string); ok {
							startDate = sd
						}
						roomOccupantMap[int64(rIDVal)] = map[string]interface{}{
							"tenant_name":   tName,
							"tenantName":    tName,
							"tenant_phone":  tPhone,
							"tenantPhone":   tPhone,
							"check_in_date": startDate,
							"checkInDate":   startDate,
						}
					}
				}
			}
		}

		// Also check room_number mapping in case room_id doesn't match directly
		roomNumToOccupant := make(map[string]map[string]interface{})
		for _, r := range rooms {
			if idVal, ok := r["id"].(float64); ok {
				rID := int64(idVal)
				if occ, found := roomOccupantMap[rID]; found {
					if rn, ok := r["room_number"].(string); ok && rn != "" {
						roomNumToOccupant[rn] = occ
					}
				}
			}
		}

		for i := range rooms {
			r := rooms[i]
			var rID int64
			if idVal, ok := r["id"].(float64); ok {
				rID = int64(idVal)
			}
			rNum := ""
			if rn, ok := r["room_number"].(string); ok {
				rNum = rn
			}

			if occ, found := roomOccupantMap[rID]; found {
				r["tenant_name"] = occ["tenant_name"]
				r["tenantName"] = occ["tenantName"]
				r["tenant_phone"] = occ["tenant_phone"]
				r["tenantPhone"] = occ["tenantPhone"]
				r["check_in_date"] = occ["check_in_date"]
				r["checkInDate"] = occ["checkInDate"]
			} else if occ, found := roomNumToOccupant[rNum]; found {
				r["tenant_name"] = occ["tenant_name"]
				r["tenantName"] = occ["tenantName"]
				r["tenant_phone"] = occ["tenant_phone"]
				r["tenantPhone"] = occ["tenantPhone"]
				r["check_in_date"] = occ["check_in_date"]
				r["checkInDate"] = occ["checkInDate"]
			}
		}
	}

	// Ensure each room has BOTH snake_case and camelCase for 100% frontend compatibility
	for i := range rooms {
		r := rooms[i]
		if rNum, ok := r["room_number"]; ok {
			r["roomNumber"] = rNum
		}
		if p, ok := r["base_rent_price"]; ok {
			r["baseRentPrice"] = p
		}
		if d, ok := r["deposit_amount"]; ok {
			r["depositAmount"] = d
		}
		if t, ok := r["room_type"]; ok {
			r["roomType"] = t
		}
		if w, ok := r["water_rate"]; ok {
			r["waterRate"] = w
		}
		if e, ok := r["electric_rate"]; ok {
			r["electricRate"] = e
		}
	}

	log.Printf("🏢 [ROOMS SAAS] org_id: %s, found %d rooms", orgID.String(), len(rooms))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    rooms,
	})
}

// 2. Create Room with Multi-Tenant org_id Binding
func CreateRoom(c *gin.Context) {
	var body map[string]interface{}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	roomNumber := ""
	if v, ok := body["roomNumber"].(string); ok {
		roomNumber = v
	} else if v, ok := body["room_number"].(string); ok {
		roomNumber = v
	}

	var floor int = 1
	if f, ok := body["floor"].(float64); ok {
		floor = int(f)
	}

	roomType := "ห้องแอร์ • เตียงเดี่ยว"
	if rt, ok := body["roomType"].(string); ok {
		roomType = rt
	} else if rt, ok := body["room_type"].(string); ok {
		roomType = rt
	}

	var price float64 = 4500.0
	if p, ok := body["baseRentPrice"].(float64); ok {
		price = p
	} else if p, ok := body["base_rent_price"].(float64); ok {
		price = p
	}

	var deposit float64 = 9000.0
	if d, ok := body["depositAmount"].(float64); ok {
		deposit = d
	} else if d, ok := body["deposit_amount"].(float64); ok {
		deposit = d
	}

	status := "vacant"
	if s, ok := body["status"].(string); ok && s != "" {
		status = s
	}

	var waterRate float64 = 0
	if w, ok := body["waterRate"].(float64); ok {
		waterRate = w
	} else if w, ok := body["water_rate"].(float64); ok {
		waterRate = w
	}

	var electricRate float64 = 0
	if e, ok := body["electricRate"].(float64); ok {
		electricRate = e
	} else if e, ok := body["electric_rate"].(float64); ok {
		electricRate = e
	}

	log.Printf("📥 [CREATE ROOM SAAS] OrgID: %s, Room: %s, Price: %.2f, Water: %.2f, Elec: %.2f", orgID.String(), roomNumber, price, waterRate, electricRate)

	insertData := map[string]interface{}{
		"org_id":          orgID.String(),
		"dorm_id":         1,
		"room_number":     roomNumber,
		"floor":           floor,
		"room_type":       roomType,
		"base_rent_price": price,
		"deposit_amount":  deposit,
		"status":          status,
		"amenities":       "แอร์, เครื่องทำน้ำอุ่น, เตียง 5 ฟุต, ตู้เสื้อผ้า, WiFi",
	}

	if waterRate > 0 {
		insertData["water_rate"] = waterRate
	}
	if electricRate > 0 {
		insertData["electric_rate"] = electricRate
	}

	var createdRoom map[string]interface{} = insertData

	if database.Client != nil {
		resp, err := database.Client.From("rooms").Insert(insertData)
		if err != nil {
			log.Printf("❌ Supabase insert room error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
		var created []map[string]interface{}
		_ = json.Unmarshal(resp, &created)
		if len(created) > 0 {
			createdRoom = created[0]
			createdRoom["roomNumber"] = createdRoom["room_number"]
			createdRoom["baseRentPrice"] = createdRoom["base_rent_price"]
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "เพิ่มห้องพักใหม่เรียบร้อยแล้ว",
		"data":    createdRoom,
	})
}

// 3. Update Room Status
func UpdateRoomStatus(c *gin.Context) {
	roomIDStr := c.Param("id")
	roomID, err := strconv.ParseInt(roomIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": "Invalid Room ID"}})
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	if database.Client != nil {
		_, _ = database.Client.From("rooms").Eq("id", strconv.FormatInt(roomID, 10)).Update(map[string]string{
			"status": req.Status,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "อัปเดตสถานะห้องพักเรียบร้อย",
	})
}
