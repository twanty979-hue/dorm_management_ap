package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"dorm_backend_api/database"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MeterRoomResponse struct {
	RoomID          int64   `json:"roomId"`
	RoomNumber      string  `json:"roomNumber"`
	Floor           int     `json:"floor"`
	TenantName      string  `json:"tenantName"`
	IsOccupied      bool    `json:"isOccupied"`
	PrevElectric    float64 `json:"prevElectric"`
	CurrentElectric float64 `json:"currentElectric"`
	PrevWater       float64 `json:"prevWater"`
	CurrentWater    float64 `json:"currentWater"`
	ElectricRate    float64 `json:"electricRate"`
	WaterRate       float64 `json:"waterRate"`
	IsRecorded      bool    `json:"isRecorded"`
	RecordedAt      string  `json:"recordedAt,omitempty"`
}

// 1. Get Meters with live DB rooms, tenants, and latest meter readings from Supabase
func GetMeters(c *gin.Context) {
	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	resultList := make([]MeterRoomResponse, 0)
	electricRate := 8.0
	waterRate := 18.0

	if database.Client != nil {
		// 1. Get property rates
		propData, _ := database.Client.From("dorm_properties").Eq("org_id", orgID.String()).Select("*")
		var props []map[string]interface{}
		_ = json.Unmarshal(propData, &props)
		if len(props) > 0 {
			if er, ok := props[0]["electric_rate"].(float64); ok {
				electricRate = er
			}
			if wr, ok := props[0]["water_rate"].(float64); ok {
				waterRate = wr
			}
		}

		// 2. Query rooms
		roomsData, err := database.Client.From("rooms").Eq("org_id", orgID.String()).Order("room_number", true).Select("*")
		if err == nil && len(roomsData) > 0 {
			var rooms []map[string]interface{}
			_ = json.Unmarshal(roomsData, &rooms)

			// 3. Query tenants & leases
			leasesData, _ := database.Client.From("lease_agreements").Eq("org_id", orgID.String()).Eq("status", "active").Select("*")
			var leases []map[string]interface{}
			_ = json.Unmarshal(leasesData, &leases)

			tenantsData, _ := database.Client.From("tenants").Eq("org_id", orgID.String()).Select("*")
			var tenants []map[string]interface{}
			_ = json.Unmarshal(tenantsData, &tenants)

			tenantMap := make(map[int64]string)
			for _, t := range tenants {
				if tIDVal, ok := t["id"].(float64); ok {
					name := "ผู้เช่า"
					if fn, ok := t["full_name"].(string); ok && fn != "" {
						name = fn
					} else if fn, ok := t["fullName"].(string); ok && fn != "" {
						name = fn
					}
					tenantMap[int64(tIDVal)] = name
				}
			}

			roomOccupantMap := make(map[int64]string)
			for _, l := range leases {
				if rIDVal, ok := l["room_id"].(float64); ok {
					if tIDVal, ok := l["tenant_id"].(float64); ok {
						if tName, found := tenantMap[int64(tIDVal)]; found {
							roomOccupantMap[int64(rIDVal)] = tName
						}
					}
				}
			}

			// 4. Query latest meter readings (matching exact Supabase schema: electric_prev, electric_curr, water_prev, water_curr)
			metersData, _ := database.Client.From("meter_readings").Eq("org_id", orgID.String()).Order("id", false).Select("*")
			var meters []map[string]interface{}
			_ = json.Unmarshal(metersData, &meters)

			latestMeterMap := make(map[int64]map[string]interface{})
			for _, m := range meters {
				if rIDVal, ok := m["room_id"].(float64); ok {
					rID := int64(rIDVal)
					if _, exists := latestMeterMap[rID]; !exists {
						latestMeterMap[rID] = m
					}
				}
			}

			for _, r := range rooms {
				var rID int64
				if idVal, ok := r["id"].(float64); ok {
					rID = int64(idVal)
				}

				rNum := "101"
				if rn, ok := r["room_number"].(string); ok && rn != "" {
					rNum = rn
				} else if rn, ok := r["roomNumber"].(string); ok && rn != "" {
					rNum = rn
				}

				floor := 1
				if fl, ok := r["floor"].(float64); ok {
					floor = int(fl)
				}

				status := "vacant"
				if st, ok := r["status"].(string); ok {
					status = st
				}
				isOccupied := status == "occupied"

				tenantName := "ห้องว่าง (ไม่มีผู้เช่า)"
				if occName, found := roomOccupantMap[rID]; found {
					tenantName = occName
					isOccupied = true
				}

				// Defaults for meter readings
				prevElec := 1000.0 + float64(rID*150)
				currElec := 0.0
				prevWater := 200.0 + float64(rID*30)
				currWater := 0.0
				isRecorded := false

				if m, found := latestMeterMap[rID]; found {
					// Check exact schema column names: electric_prev, electric_curr, water_prev, water_curr
					if pe, ok := m["electric_prev"].(float64); ok {
						prevElec = pe
					} else if pe, ok := m["prev_electric"].(float64); ok {
						prevElec = pe
					}
					if ce, ok := m["electric_curr"].(float64); ok {
						currElec = ce
					} else if ce, ok := m["current_electric"].(float64); ok {
						currElec = ce
					}
					if pw, ok := m["water_prev"].(float64); ok {
						prevWater = pw
					} else if pw, ok := m["prev_water"].(float64); ok {
						prevWater = pw
					}
					if cw, ok := m["water_curr"].(float64); ok {
						currWater = cw
					} else if cw, ok := m["current_water"].(float64); ok {
						currWater = cw
					}
					if currElec > 0 || currWater > 0 {
						isRecorded = true
					}
				}

				resultList = append(resultList, MeterRoomResponse{
					RoomID:          rID,
					RoomNumber:      rNum,
					Floor:           floor,
					TenantName:      tenantName,
					IsOccupied:      isOccupied,
					PrevElectric:    prevElec,
					CurrentElectric: currElec,
					PrevWater:       prevWater,
					CurrentWater:    currWater,
					ElectricRate:    electricRate,
					WaterRate:       waterRate,
					IsRecorded:      isRecorded,
				})
			}
		}
	}

	log.Printf("⚡ [METERS SAAS] org_id: %s, loaded %d rooms for meter reading", orgID.String(), len(resultList))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    resultList,
		"rates": gin.H{
			"electricRate": electricRate,
			"waterRate":    waterRate,
		},
	})
}

// 2. Batch Record Meter into Supabase matching exact schema
type MeterRecordItem struct {
	RoomID          int64   `json:"roomId"`
	PrevElectric    float64 `json:"prevElectric"`
	CurrentElectric float64 `json:"currentElectric"`
	PrevWater       float64 `json:"prevWater"`
	CurrentWater    float64 `json:"currentWater"`
}

type BatchMeterRequest struct {
	DormID       int64             `json:"dormId"`
	BillingMonth string            `json:"billingMonth"`
	Readings     []MeterRecordItem `json:"readings" binding:"required"`
}

func RecordMeters(c *gin.Context) {
	var req BatchMeterRequest
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

	log.Printf("📥 [RECORD METERS] Org: %s, Count: %d", currentOrgID.String(), len(req.Readings))

	if database.Client != nil {
		for _, r := range req.Readings {
			// Save into Supabase meter_readings table using EXACT schema column names:
			// (org_id, dorm_id, room_id, billing_month, electric_prev, electric_curr, water_prev, water_curr)
			_, err := database.Client.From("meter_readings").Insert(map[string]interface{}{
				"org_id":        currentOrgID.String(),
				"dorm_id":       req.DormID,
				"room_id":       r.RoomID,
				"billing_month": req.BillingMonth,
				"electric_prev": r.PrevElectric,
				"electric_curr": r.CurrentElectric,
				"water_prev":    r.PrevWater,
				"water_curr":    r.CurrentWater,
			})
			if err != nil {
				log.Printf("⚠️ Insert meter_readings for room %d error: %v", r.RoomID, err)
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": fmt.Sprintf("บันทึกเลขมิเตอร์ %d ห้องลงฐานข้อมูลเรียบร้อยแล้ว", len(req.Readings)),
	})
}
