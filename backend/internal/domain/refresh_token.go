package domain

import "time"

// RefreshToken persists the hash of a long-lived opaque refresh token used
// to reissue short-lived access tokens without forcing the user to log in
// again. The raw token itself is never stored - only TokenHash (sha256).
type RefreshToken struct {
	ID        string
	UserID    string
	TokenHash string
	ExpiresAt time.Time
	RevokedAt *time.Time
	CreatedAt time.Time
}
