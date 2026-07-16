package jwtutil

import (
	"testing"
	"time"
)

func TestIssueAndVerify_RoundTripPreservesClaims(t *testing.T) {
	token, err := Issue("secret-a", "user-1", "user1@example.com", "user", time.Hour)
	if err != nil {
		t.Fatalf("Issue failed: %v", err)
	}

	claims, err := Verify("secret-a", token)
	if err != nil {
		t.Fatalf("Verify failed: %v", err)
	}
	if claims.UserID != "user-1" {
		t.Errorf("expected UserID user-1, got %s", claims.UserID)
	}
	if claims.Email != "user1@example.com" {
		t.Errorf("expected Email user1@example.com, got %s", claims.Email)
	}
}

func TestVerify_WrongSecretFails(t *testing.T) {
	token, err := Issue("secret-a", "user-1", "user1@example.com", "user", time.Hour)
	if err != nil {
		t.Fatalf("Issue failed: %v", err)
	}

	if _, err := Verify("secret-b", token); err != ErrInvalidToken {
		t.Fatalf("expected ErrInvalidToken for a token signed with a different secret, got %v", err)
	}
}

func TestVerify_ExpiredTokenFails(t *testing.T) {
	// Negative TTL puts ExpiresAt in the past immediately.
	token, err := Issue("secret-a", "user-1", "user1@example.com", "user", -time.Hour)
	if err != nil {
		t.Fatalf("Issue failed: %v", err)
	}

	if _, err := Verify("secret-a", token); err != ErrInvalidToken {
		t.Fatalf("expected ErrInvalidToken for an expired token, got %v", err)
	}
}

func TestVerify_MalformedTokenFails(t *testing.T) {
	if _, err := Verify("secret-a", "not-a-jwt"); err != ErrInvalidToken {
		t.Fatalf("expected ErrInvalidToken for a malformed token string, got %v", err)
	}
}

func TestVerify_EmptyTokenFails(t *testing.T) {
	if _, err := Verify("secret-a", ""); err != ErrInvalidToken {
		t.Fatalf("expected ErrInvalidToken for an empty token string, got %v", err)
	}
}
