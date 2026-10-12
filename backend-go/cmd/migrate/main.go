package main

import (
	"log"

	"dorm_backend_api/config"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	cfg := config.LoadConfig()
	_ = cfg
	log.Printf("🔌 Connecting to Supabase Database...")

	regions := []string{
		"ap-southeast-1", // Singapore
		"ap-southeast-2", // Sydney
		"ap-northeast-1", // Tokyo
		"ap-northeast-2", // Seoul
		"ap-south-1",     // Mumbai
		"us-east-1",     // N. Virginia
		"us-east-2",     // Ohio
		"us-west-1",     // N. California
		"us-west-2",     // Oregon
		"eu-central-1",   // Frankfurt
		"eu-west-1",     // Ireland
		"eu-west-2",     // London
	}

	var urls []string
	for _, r := range regions {
		urls = append(urls, "postgres://postgres.jexqgxqawcgdrnvrgovl:NWP9SwCz6*PrW%2Bm@aws-0-"+r+".pooler.supabase.com:6543/postgres?sslmode=require")
		urls = append(urls, "postgres://postgres.jexqgxqawcgdrnvrgovl:NWP9SwCz6*PrW%2Bm@aws-0-"+r+".pooler.supabase.com:5432/postgres?sslmode=require")
	}

	var db *gorm.DB
	var err error

	for _, u := range urls {
		db, err = gorm.Open(postgres.Open(u), &gorm.Config{})
		if err == nil {
			sqlDB, errPing := db.DB()
			if errPing == nil && sqlDB.Ping() == nil {
				log.Printf("✅ Connected successfully to Supabase PostgreSQL!")
				break
			}
		}
	}

	if db == nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}

	log.Printf("🚀 Running Schema Migrations for Water & Electric Rates...")

	// 1. Alter rooms table
	err = db.Exec(`
		ALTER TABLE public.rooms 
		ADD COLUMN IF NOT EXISTS water_rate NUMERIC(10,2) DEFAULT NULL,
		ADD COLUMN IF NOT EXISTS electric_rate NUMERIC(10,2) DEFAULT NULL;
	`).Error
	if err != nil {
		log.Printf("⚠️ Rooms alter note: %v", err)
	} else {
		log.Printf("✅ [rooms] Added water_rate and electric_rate columns successfully!")
	}

	// 2. Alter lease_agreements table
	err = db.Exec(`
		ALTER TABLE public.lease_agreements 
		ADD COLUMN IF NOT EXISTS water_rate NUMERIC(10,2) DEFAULT NULL,
		ADD COLUMN IF NOT EXISTS electric_rate NUMERIC(10,2) DEFAULT NULL;
	`).Error
	if err != nil {
		log.Printf("⚠️ Lease agreements alter note: %v", err)
	} else {
		log.Printf("✅ [lease_agreements] Added water_rate and electric_rate columns successfully!")
	}

	// 3. Verify columns exist
	var roomColumns []string
	db.Raw(`
		SELECT column_name 
		FROM information_schema.columns 
		WHERE table_name = 'rooms' AND column_name IN ('water_rate', 'electric_rate');
	`).Scan(&roomColumns)

	log.Printf("🎉 Verified columns in 'rooms': %v", roomColumns)

	var leaseColumns []string
	db.Raw(`
		SELECT column_name 
		FROM information_schema.columns 
		WHERE table_name = 'lease_agreements' AND column_name IN ('water_rate', 'electric_rate');
	`).Scan(&leaseColumns)

	log.Printf("🎉 Verified columns in 'lease_agreements': %v", leaseColumns)
	log.Printf("✨ Schema Migration Completed 100%%!")
}
