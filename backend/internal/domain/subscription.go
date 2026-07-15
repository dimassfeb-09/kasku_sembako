package domain

import "time"

type SubscriptionStatus string

const (
	SubscriptionStatusActive      SubscriptionStatus = "active"
	SubscriptionStatusCanceled    SubscriptionStatus = "canceled"
	SubscriptionStatusExpired     SubscriptionStatus = "expired"
	SubscriptionStatusGracePeriod SubscriptionStatus = "grace_period"
	SubscriptionStatusOnHold      SubscriptionStatus = "on_hold"
)

type Subscription struct {
	ID             string
	UserID         string
	ProductID      string
	PurchaseToken  string
	Status         SubscriptionStatus
	ExpiryTime     *time.Time
	Acknowledged   bool
	LastVerifiedAt time.Time
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

// IsActive derives client-facing entitlement from stored status/expiry.
func (s Subscription) IsActive(now time.Time) bool {
	if s.Status != SubscriptionStatusActive && s.Status != SubscriptionStatusGracePeriod {
		return false
	}
	if s.ExpiryTime != nil && s.ExpiryTime.Before(now) {
		return false
	}
	return true
}

// StatusStaleness returns how long ago this subscription was last verified against Play.
func (s Subscription) StatusStaleness(now time.Time) time.Duration {
	return now.Sub(s.LastVerifiedAt)
}
