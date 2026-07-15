package domain

import "errors"

var (
	ErrNotFound           = errors.New("not found")
	ErrEmailTaken         = errors.New("email already registered")
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrPurchaseTokenTaken = errors.New("purchase token already registered to another account")
	ErrSubscriptionNotPro = errors.New("subscription is not active pro")
)
