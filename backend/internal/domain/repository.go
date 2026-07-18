package domain

import "context"

// UserRepository persists cloud store-owner accounts (separate from the
// app's local per-cashier PIN users).
type UserRepository interface {
	Create(ctx context.Context, u *User) error
	FindByEmail(ctx context.Context, email string) (*User, error)
	FindByID(ctx context.Context, id string) (*User, error)
	UpdatePassword(ctx context.Context, userID, newPasswordHash string) error
	ListAll(ctx context.Context) ([]*User, error)
	Count(ctx context.Context) (int, error)
}

// PasswordResetRepository persists OTP codes for password reset flows.
type PasswordResetRepository interface {
	Create(ctx context.Context, pr *PasswordReset) error
	FindLatestByEmail(ctx context.Context, email string) (*PasswordReset, error)
	MarkUsed(ctx context.Context, id string) error
}

// RefreshTokenRepository persists hashed refresh tokens backing the
// short-lived-access-token / long-lived-refresh-token login flow.
type RefreshTokenRepository interface {
	Create(ctx context.Context, rt *RefreshToken) error
	// FindByHash returns ErrNotFound if no row matches tokenHash - it does
	// not distinguish "never existed" from "revoked/expired" so callers
	// must check RevokedAt/ExpiresAt themselves.
	FindByHash(ctx context.Context, tokenHash string) (*RefreshToken, error)
	Revoke(ctx context.Context, id string) error
}

// SubscriptionRepository persists Play Billing subscription state.
type SubscriptionRepository interface {
	// Upsert inserts a new subscription or updates the existing row for the
	// same PurchaseToken (ON CONFLICT (purchase_token) DO UPDATE).
	Upsert(ctx context.Context, s *Subscription) error
	FindLatestByUserID(ctx context.Context, userID string) (*Subscription, error)
	FindByPurchaseToken(ctx context.Context, token string) (*Subscription, error)
}

// StoreProfileRepository persists store profile data per user.
type StoreProfileRepository interface {
	Upsert(ctx context.Context, p *StoreProfile) error
	FindByUserID(ctx context.Context, userID string) (*StoreProfile, error)
}

// BackupRepository persists backup snapshots directly in Postgres
// (payload BYTEA column, usually gzip-compressed) — no on-disk file storage.
type BackupRepository interface {
	Create(ctx context.Context, b *Backup) error
	FindLatestByUserID(ctx context.Context, userID string) (*Backup, error)
	// FindByUserIDAndHash backs upload idempotency: a client retry after a
	// timed-out-but-actually-succeeded request re-sends the same content
	// hash, and this lets Upload return the existing row instead of
	// creating a duplicate. Returns ErrNotFound if no match.
	FindByUserIDAndHash(ctx context.Context, userID, contentHash string) (*Backup, error)
	// FindByID and Delete are ownership-scoped at the SQL level
	// (WHERE id = $1 AND user_id = $2): a non-owner's request returns
	// ErrNotFound rather than a distinct forbidden error, so it never
	// confirms a backup exists for someone else.
	FindByID(ctx context.Context, id, userID string) (*Backup, error)
	ListByUserID(ctx context.Context, userID string) ([]*BackupSummary, error)
	// ListOlderThanNewestNIDs returns the IDs of backups beyond the N most
	// recent for a user, for retention pruning (IDs only — the caller never
	// needs the payload of a row it's about to delete).
	ListOlderThanNewestNIDs(ctx context.Context, userID string, keepNewest int) ([]string, error)
	Delete(ctx context.Context, id, userID string) error
}
