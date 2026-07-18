package domain

import "time"

type StoreProfile struct {
	ID               string    `json:"id"`
	UserID           string    `json:"userID"`
	OwnerName        string    `json:"ownerName"`
	BusinessName     string    `json:"businessName"`
	BusinessCategory string    `json:"businessCategory"`
	Phone            string    `json:"phone"`
	Address          string    `json:"address"`
	BusinessEmail    string    `json:"businessEmail"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
}
