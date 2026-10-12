package config

import (
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

type Config struct {
	Port            string
	Env             string
	SupabaseURL     string
	SupabaseAnonKey string
	DatabaseURL     string
	DBPassword      string
	JWTSecret       string
}

var AppConfig *Config

func LoadConfig() *Config {
	err := godotenv.Load(".env")
	if err != nil {
		log.Println("Note: .env file not found, loading from environment variables")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "dorm_saas_default_secret_key_2026"
	}

	dbURL := os.Getenv("DATABASE_URL")
	dbPassword := os.Getenv("DB_PASSWORD")

	if dbPassword != "" {
		encodedPass := url.QueryEscape(dbPassword)
		if strings.Contains(dbURL, "[YOUR-PASSWORD]") {
			dbURL = strings.Replace(dbURL, "[YOUR-PASSWORD]", encodedPass, 1)
		} else if dbURL == "" || strings.Contains(dbURL, "YOUR_PASSWORD_HERE") {
			dbURL = "postgres://postgres.jexqgxqawcgdrnvrgovl:" + encodedPass + "@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?sslmode=require"
		}
	}

	AppConfig = &Config{
		Port:            port,
		Env:             os.Getenv("ENV"),
		SupabaseURL:     os.Getenv("SUPABASE_URL"),
		SupabaseAnonKey: os.Getenv("SUPABASE_ANON_KEY"),
		DatabaseURL:     dbURL,
		DBPassword:      dbPassword,
		JWTSecret:       jwtSecret,
	}

	return AppConfig
}
