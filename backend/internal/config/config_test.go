package config

import (
	"testing"
	"time"
)

func setRequiredEnv(t *testing.T) {
	t.Helper()
	t.Setenv("DATABASE_URL", "postgres://user:pass@localhost:5432/db")
	t.Setenv("JWT_SECRET", "this-is-a-sufficiently-long-test-secret-value")
}

func TestLoad_MissingDatabaseURLReturnsError(t *testing.T) {
	t.Setenv("DATABASE_URL", "")
	t.Setenv("JWT_SECRET", "this-is-a-sufficiently-long-test-secret-value")

	if _, err := Load(); err == nil {
		t.Fatal("expected an error when DATABASE_URL is missing")
	}
}

func TestLoad_MissingJWTSecretReturnsError(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://user:pass@localhost:5432/db")
	t.Setenv("JWT_SECRET", "")

	if _, err := Load(); err == nil {
		t.Fatal("expected an error when JWT_SECRET is missing")
	}
}

func TestLoad_DefaultsAppliedWhenOptionalVarsUnset(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("PORT", "")
	t.Setenv("JWT_TTL_DAYS", "")
	t.Setenv("BACKUP_MAX_SIZE_MB", "")
	t.Setenv("BACKUP_RETENTION_COUNT", "")
	t.Setenv("SUBSCRIPTION_STALENESS_HOURS", "")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}

	if cfg.Port != "8080" {
		t.Errorf("expected default Port 8080, got %s", cfg.Port)
	}
	if cfg.RefreshTokenTTL != 30*24*time.Hour {
		t.Errorf("expected default RefreshTokenTTL of 30 days, got %v", cfg.RefreshTokenTTL)
	}
	if cfg.AccessTokenTTL != 15*time.Minute {
		t.Errorf("expected default AccessTokenTTL of 15 minutes, got %v", cfg.AccessTokenTTL)
	}
	if cfg.BackupMaxSizeBytes != 50*1024*1024 {
		t.Errorf("expected default BackupMaxSizeBytes of 50MB, got %d", cfg.BackupMaxSizeBytes)
	}
	if cfg.BackupRetentionCount != 3 {
		t.Errorf("expected default BackupRetentionCount of 3, got %d", cfg.BackupRetentionCount)
	}
	if cfg.SubscriptionStalenessTTL != 24*time.Hour {
		t.Errorf("expected default SubscriptionStalenessTTL of 24h, got %v", cfg.SubscriptionStalenessTTL)
	}
}

func TestLoad_CustomValuesOverrideDefaults(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("PORT", "9090")
	t.Setenv("JWT_TTL_DAYS", "7")
	t.Setenv("ACCESS_TOKEN_TTL_MINUTES", "5")
	t.Setenv("BACKUP_MAX_SIZE_MB", "10")
	t.Setenv("BACKUP_RETENTION_COUNT", "5")
	t.Setenv("SUBSCRIPTION_STALENESS_HOURS", "1")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}

	if cfg.Port != "9090" {
		t.Errorf("expected Port 9090, got %s", cfg.Port)
	}
	if cfg.RefreshTokenTTL != 7*24*time.Hour {
		t.Errorf("expected RefreshTokenTTL of 7 days, got %v", cfg.RefreshTokenTTL)
	}
	if cfg.AccessTokenTTL != 5*time.Minute {
		t.Errorf("expected AccessTokenTTL of 5 minutes, got %v", cfg.AccessTokenTTL)
	}
	if cfg.BackupMaxSizeBytes != 10*1024*1024 {
		t.Errorf("expected BackupMaxSizeBytes of 10MB, got %d", cfg.BackupMaxSizeBytes)
	}
	if cfg.BackupRetentionCount != 5 {
		t.Errorf("expected BackupRetentionCount of 5, got %d", cfg.BackupRetentionCount)
	}
	if cfg.SubscriptionStalenessTTL != time.Hour {
		t.Errorf("expected SubscriptionStalenessTTL of 1h, got %v", cfg.SubscriptionStalenessTTL)
	}
}

func TestLoad_InvalidJWTTTLDaysReturnsError(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("JWT_TTL_DAYS", "not-a-number")

	if _, err := Load(); err == nil {
		t.Fatal("expected an error for a non-numeric JWT_TTL_DAYS")
	}
}

func TestLoad_InvalidBackupMaxSizeMBReturnsError(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("BACKUP_MAX_SIZE_MB", "not-a-number")

	if _, err := Load(); err == nil {
		t.Fatal("expected an error for a non-numeric BACKUP_MAX_SIZE_MB")
	}
}

func TestLoad_TooShortJWTSecretReturnsError(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://user:pass@localhost:5432/db")
	t.Setenv("JWT_SECRET", "too-short")

	if _, err := Load(); err == nil {
		t.Fatal("expected an error for a JWT_SECRET shorter than the minimum length")
	}
}

func TestLoad_TrustedProxiesUnsetByDefault(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("TRUSTED_PROXIES", "")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}
	if len(cfg.TrustedProxies) != 0 {
		t.Errorf("expected no trusted proxies by default, got %v", cfg.TrustedProxies)
	}
}

func TestLoad_TrustedProxiesParsedFromCommaSeparatedList(t *testing.T) {
	setRequiredEnv(t)
	t.Setenv("TRUSTED_PROXIES", "10.0.0.1/32, 172.16.0.0/12,192.168.1.1/32")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load failed: %v", err)
	}
	want := []string{"10.0.0.1/32", "172.16.0.0/12", "192.168.1.1/32"}
	if len(cfg.TrustedProxies) != len(want) {
		t.Fatalf("expected %v, got %v", want, cfg.TrustedProxies)
	}
	for i, w := range want {
		if cfg.TrustedProxies[i] != w {
			t.Errorf("expected TrustedProxies[%d] = %q, got %q", i, w, cfg.TrustedProxies[i])
		}
	}
}
