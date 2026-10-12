package main

import (
	"log"

	"dorm_backend_api/config"
	"dorm_backend_api/database"
	"dorm_backend_api/routes"
)

func main() {
	// 1. Load configuration (Reads Supabase URL & Anon Key)
	cfg := config.LoadConfig()
	log.Printf("🚀 Starting Dormitory SaaS API Server on port %s...", cfg.Port)

	// 2. Initialize Direct Supabase Client (No password needed, uses Anon Key directly)
	database.InitSupabaseClient()
	log.Println("✅ Connected to Supabase REST API via Anon Key successfully!")

	// 3. Setup Gin Router
	r := routes.SetupRouter()

	// 4. Run HTTP Server
	err := r.Run(":" + cfg.Port)
	if err != nil {
		log.Fatalf("❌ Failed to start server: %v\n", err)
	}
}
