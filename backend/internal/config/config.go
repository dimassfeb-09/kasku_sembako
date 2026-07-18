package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

// minJWTSecretLength guards against a trivially weak or placeholder
// JWT_SECRET (e.g. left as ".env.example"'s sample value) being used
// directly as the HMAC-SHA256 signing key, which would let an attacker
// brute-force it and forge arbitrary tokens.
const minJWTSecretLength = 32

// Config holds all runtime configuration, sourced from environment
// variables. No .env file is loaded implicitly in production; use
// something like `godotenv` or your process manager to inject env vars.
// See .env.example for the full list of keys.
type Config struct {
	Port        string
	DatabaseURL string
	JWTSecret   string
	// AccessTokenTTL is how long an issued JWT access token stays valid
	// before a client must exchange its refresh token for a new one.
	// Short on purpose - RefreshTokenTTL is what keeps the user logged in.
	AccessTokenTTL time.Duration
	// RefreshTokenTTL is how long a refresh token (and thus a logged-in
	// session) stays valid before the user must log in again.
	RefreshTokenTTL              time.Duration
	AdminEmail                   string
	GooglePackageName            string
	GoogleServiceAccountJSONPath string
	BackupMaxSizeBytes           int64
	BackupRetentionCount         int
	SubscriptionStalenessTTL     time.Duration
	// TrustedProxies is a list of CIDRs for reverse proxies allowed to set
	// X-Forwarded-For. Empty (default) means don't trust any proxy header —
	// c.IP() falls back to the direct TCP peer, which is the safe default
	// for a backend not yet deployed behind a known proxy. Set this only to
	// the actual reverse proxy's address once one is in front of this
	// service, or rate limiting collapses every client behind an unconfigured
	// proxy into a single shared bucket (or, if misconfigured, becomes spoofable).
	TrustedProxies []string

	// SMTP config for sending transactional emails (OTP, etc.).
	// If SMTPHost is empty, emails are logged instead of sent.
	SMTPHost     string
	SMTPPort     int
	SMTPUser     string
	SMTPPass     string
	SMTPFrom     string
	SMTPFromName string
}

func Load() (*Config, error) {
	cfg := &Config{
		Port:                         getEnv("PORT", "8080"),
		DatabaseURL:                  os.Getenv("DATABASE_URL"),
		JWTSecret:                    os.Getenv("JWT_SECRET"),
		AdminEmail:                   os.Getenv("ADMIN_EMAIL"),
		GooglePackageName:            os.Getenv("GOOGLE_PLAY_PACKAGE_NAME"),
		GoogleServiceAccountJSONPath: os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}
	if cfg.JWTSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}
	if len(cfg.JWTSecret) < minJWTSecretLength {
		return nil, fmt.Errorf("JWT_SECRET must be at least %d characters (got %d) - generate a real random secret, e.g. `openssl rand -base64 32`", minJWTSecretLength, len(cfg.JWTSecret))
	}

	if raw := os.Getenv("TRUSTED_PROXIES"); raw != "" {
		for _, cidr := range strings.Split(raw, ",") {
			if trimmed := strings.TrimSpace(cidr); trimmed != "" {
				cfg.TrustedProxies = append(cfg.TrustedProxies, trimmed)
			}
		}
	}

	ttlDays, err := strconv.Atoi(getEnv("JWT_TTL_DAYS", "30"))
	if err != nil {
		return nil, fmt.Errorf("invalid JWT_TTL_DAYS: %w", err)
	}
	cfg.RefreshTokenTTL = time.Duration(ttlDays) * 24 * time.Hour

	accessTTLMinutes, err := strconv.Atoi(getEnv("ACCESS_TOKEN_TTL_MINUTES", "15"))
	if err != nil {
		return nil, fmt.Errorf("invalid ACCESS_TOKEN_TTL_MINUTES: %w", err)
	}
	cfg.AccessTokenTTL = time.Duration(accessTTLMinutes) * time.Minute

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

	smtpPort, err := strconv.Atoi(getEnv("SMTP_PORT", "587"))
	if err != nil {
		return nil, fmt.Errorf("invalid SMTP_PORT: %w", err)
	}
	cfg.SMTPPort = smtpPort
	cfg.SMTPHost = os.Getenv("SMTP_HOST")
	cfg.SMTPUser = os.Getenv("SMTP_USER")
	cfg.SMTPPass = os.Getenv("SMTP_PASS")
	cfg.SMTPFrom = getEnv("SMTP_FROM", "noreply@kasirku.app")
	cfg.SMTPFromName = getEnv("SMTP_FROM_NAME", "KasirKu")

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
