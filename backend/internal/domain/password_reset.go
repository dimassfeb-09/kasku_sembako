package domain

import "time"

type PasswordReset struct {
	ID        string
	UserID    string
	Email     string
	OTPCode   string
	ExpiresAt time.Time
	Used      bool
	CreatedAt time.Time
}
