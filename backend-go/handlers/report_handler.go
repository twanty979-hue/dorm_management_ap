package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// 1. Get Monthly Financial Summary
func GetFinancialSummary(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"month":                "สิงหาคม 2026",
			"totalRevenue":         248500.0,
			"momGrowthPercent":     4.5,
			"netProfit":            213200.0,
			"totalExpenses":        35300.0,
			"collectionRatePercent": 94.2,
			"paidCount":            42,
			"unpaidCount":          3,
			"breakdown": gin.H{
				"rent":      195000.0,
				"electric":  32400.0,
				"water":     8100.0,
				"commonFee": 13000.0,
			},
		},
	})
}
