package domain

import "time"

type User struct {
	ID           string
	Name         string
	Email        string
	PasswordHash string
	WhatsApp     string
	Role         string
	CreatedAt    time.Time
}

func (u *User) IsAdmin() bool {
	return u.Role == "admin"
}
