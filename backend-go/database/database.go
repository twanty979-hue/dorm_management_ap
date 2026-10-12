package database

import (
	"log"

	"dorm_backend_api/config"
	"dorm_backend_api/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func ConnectDB() *gorm.DB {
	dbURL := config.AppConfig.DatabaseURL

	if dbURL == "" {
		log.Println("⚠️  Warning: DATABASE_URL is not set. Please check your .env file")
		return nil
	}

	var err error
	DB, err = gorm.Open(postgres.Open(dbURL), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})

	if err != nil {
		log.Printf("⚠️  Database Connection Error: %v\n", err)
		log.Println("💡 Note: Please ensure your Supabase database password in .env is correct")
		return nil
	}

	log.Println("✅ Connected to Supabase PostgreSQL Database successfully!")

	// Auto-migrate tables if needed
	err = DB.AutoMigrate(
		&models.SubscriptionPlan{},
		&models.Organization{},
		&models.OrgMember{},
		&models.DormProperty{},
		&models.Room{},
		&models.Tenant{},
		&models.LeaseAgreement{},
		&models.MeterReading{},
		&models.Invoice{},
		&models.Payment{},
		&models.MaintenanceTicket{},
		&models.LineOAConfig{},
	)

	if err != nil {
		log.Printf("AutoMigrate note: %v\n", err)
	}

	return DB
}
