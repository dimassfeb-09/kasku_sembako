package domain

import "context"

// UserRepository persists cloud store-owner accounts (separate from the
// app's local per-cashier PIN users).
type UserRepository interface {
	Create(ctx context.Context, u *User) error
	FindByEmail(ctx context.Context, email string) (*User, error)
	FindByID(ctx context.Context, id string) (*User, error)
}

// SubscriptionRepository persists Play Billing subscription state.
type SubscriptionRepository interface {
	// Upsert inserts a new subscription or updates the existing row for the
	// same PurchaseToken (ON CONFLICT (purchase_token) DO UPDATE).
	Upsert(ctx context.Context, s *Subscription) error
	FindLatestByUserID(ctx context.Context, userID string) (*Subscription, error)
	FindByPurchaseToken(ctx context.Context, token string) (*Subscription, error)
}

// BackupRepository persists JSON backup snapshots directly in Postgres
// (payload JSONB column) — no on-disk file storage.
type BackupRepository interface {
	Create(ctx context.Context, b *Backup) error
	FindLatestByUserID(ctx context.Context, userID string) (*Backup, error)
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
