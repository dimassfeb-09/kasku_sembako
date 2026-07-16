package domain

import "time"

type StoreProfile struct {
	ID               string
	UserID           string
	OwnerName        string
	BusinessName     string
	BusinessCategory string
	Phone            string
	Address          string
	CreatedAt        time.Time
	UpdatedAt        time.Time
}
