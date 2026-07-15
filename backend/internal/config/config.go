package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config holds all runtime configuration, sourced from environment
// variables. No .env file is loaded implicitly in production; use
// something like `godotenv` or your process manager to inject env vars.
// See .env.example for the full list of keys.
type Config struct {
	Port                         string
	DatabaseURL                  string
	JWTSecret                    string
	JWTTTL                       time.Duration
	GooglePackageName            string
	GoogleServiceAccountJSONPath string
	BackupMaxSizeBytes           int64
	BackupRetentionCount         int
	SubscriptionStalenessTTL     time.Duration
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:                         getEnv("PORT", "8080"),
		DatabaseURL:                  os.Getenv("DATABASE_URL"),
		JWTSecret:                    os.Getenv("JWT_SECRET"),
		GooglePackageName:            os.Getenv("GOOGLE_PLAY_PACKAGE_NAME"),
		GoogleServiceAccountJSONPath: os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}

	ttlDays, err := strconv.Atoi(getEnv("JWT_TTL_DAYS", "30"))
	if err != nil {
		return nil, fmt.Errorf("invalid JWT_TTL_DAYS: %w", err)
	}
	cfg.JWTTTL = time.Duration(ttlDays) * 24 * time.Hour

	maxMB, err := strconv.ParseInt(getEnv("BACKUP_MAX_SIZE_MB", "50"), 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid BACKUP_MAX_SIZE_MB: %w", err)
	}
	cfg.BackupMaxSizeBytes = maxMB * 1024 * 1024

	retention, err := strconv.Atoi(getEnv("BACKUP_RETENTION_COUNT", "3"))
	if err != nil {
		return nil, fmt.Errorf("invalid BACKUP_RETENTION_COUNT: %w", err)
	}
	cfg.BackupRetentionCount = retention

	stalenessHours, err := strconv.Atoi(getEnv("SUBSCRIPTION_STALENESS_HOURS", "24"))
	if err != nil {
		return nil, fmt.Errorf("invalid SUBSCRIPTION_STALENESS_HOURS: %w", err)
	}
	cfg.SubscriptionStalenessTTL = time.Duration(stalenessHours) * time.Hour

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
