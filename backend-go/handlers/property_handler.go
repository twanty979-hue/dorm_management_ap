package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"dorm_backend_api/database"
	"dorm_backend_api/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// 1. Get All Properties / Branches with Multi-Tenant org_id Isolation
func GetProperties(c *gin.Context) {
	properties := make([]models.DormProperty, 0)

	orgIDVal, exists := c.Get("org_id")
	var orgID uuid.UUID
	if exists {
		orgID = orgIDVal.(uuid.UUID)
	} else {
		orgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	if database.Client != nil {
		data, err := database.Client.From("dorm_properties").Eq("org_id", orgID.String()).Order("id", true).Select("*")
		if err != nil {
			log.Printf("⚠️ Error querying properties: %v", err)
		} else if len(data) > 0 {
			_ = json.Unmarshal(data, &properties)
		}
	}

	log.Printf("🏛️ [PROPERTIES SAAS] org_id: %s, found %d properties", orgID.String(), len(properties))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    properties,
	})
}

// 2. Create Property / Branch
func CreateProperty(c *gin.Context) {
	var prop models.DormProperty
	if err := c.ShouldBindJSON(&prop); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	orgIDVal, exists := c.Get("org_id")
	if exists {
		prop.OrgID = orgIDVal.(uuid.UUID)
	} else {
		prop.OrgID, _ = uuid.Parse("6008008f-e0f5-4970-a4ce-da2f8abaa607")
	}

	if database.Client != nil {
		resp, err := database.Client.From("dorm_properties").Insert(map[string]interface{}{
			"org_id":         prop.OrgID.String(),
			"name":           prop.Name,
			"address":        prop.Address,
			"water_rate":     prop.WaterRate,
			"electric_rate":  prop.ElectricRate,
			"is_main_branch": prop.IsMainBranch,
		})
		if err == nil {
			var created []models.DormProperty
			_ = json.Unmarshal(resp, &created)
			if len(created) > 0 {
				prop = created[0]
			}
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "สร้างหอพัก/สาขาใหม่เรียบร้อยแล้ว",
		"data":    prop,
	})
}

// 3. Update Property / Branch Settings (Water, Electric, etc.)
func UpdatePropertySettings(c *gin.Context) {
	propIDStr := c.Param("id")
	if propIDStr == "" {
		propIDStr = "1"
	}

	var req struct {
		Name         *string  `json:"name"`
		WaterRate    *float64 `json:"waterRate"`
		ElectricRate *float64 `json:"electricRate"`
		Address      *string  `json:"address"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
		return
	}

	updateMap := make(map[string]interface{})
	if req.Name != nil {
		updateMap["name"] = *req.Name
	}
	if req.WaterRate != nil {
		updateMap["water_rate"] = *req.WaterRate
	}
	if req.ElectricRate != nil {
		updateMap["electric_rate"] = *req.ElectricRate
	}
	if req.Address != nil {
		updateMap["address"] = *req.Address
	}

	if database.Client != nil {
		_, err := database.Client.From("dorm_properties").Eq("id", propIDStr).Update(updateMap)
		if err != nil {
			log.Printf("❌ Supabase update property error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": gin.H{"message": err.Error()}})
			return
		}
	}

	log.Printf("⚙️ [PROPERTY SETTINGS UPDATED] PropID: %s", propIDStr)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "บันทึกการตั้งค่าหอพักลง Database เรียบร้อยแล้ว",
	})
}
