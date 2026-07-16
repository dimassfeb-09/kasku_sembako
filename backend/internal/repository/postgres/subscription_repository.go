package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

type SubscriptionRepository struct {
	pool *pgxpool.Pool
}

func NewSubscriptionRepository(pool *pgxpool.Pool) *SubscriptionRepository {
	return &SubscriptionRepository{pool: pool}
}

// Upsert inserts a subscription or, if the purchase_token already exists,
// updates its status/expiry/acknowledgement in place. purchase_token is
// UNIQUE so this is the single write path for both first-time verification
// and later re-verification of the same purchase.
func (r *SubscriptionRepository) Upsert(ctx context.Context, s *domain.Subscription) error {
	const q = `
		INSERT INTO subscriptions
			(user_id, product_id, purchase_token, status, expiry_time, acknowledged, last_verified_at)
		VALUES ($1, $2, $3, $4, $5, $6, now())
		ON CONFLICT (purchase_token) DO UPDATE SET
			status = EXCLUDED.status,
			expiry_time = EXCLUDED.expiry_time,
			acknowledged = EXCLUDED.acknowledged,
			last_verified_at = now(),
			updated_at = now()
		RETURNING id, user_id, product_id, purchase_token, status, expiry_time,
			acknowledged, last_verified_at, created_at, updated_at`
	row := r.pool.QueryRow(ctx, q,
		s.UserID, s.ProductID, s.PurchaseToken, s.Status, s.ExpiryTime, s.Acknowledged,
	)
	return row.Scan(
		&s.ID, &s.UserID, &s.ProductID, &s.PurchaseToken, &s.Status, &s.ExpiryTime,
		&s.Acknowledged, &s.LastVerifiedAt, &s.CreatedAt, &s.UpdatedAt,
	)
}

func (r *SubscriptionRepository) FindLatestByUserID(ctx context.Context, userID string) (*domain.Subscription, error) {
	const q = `
		SELECT id, user_id, product_id, purchase_token, status, expiry_time,
			acknowledged, last_verified_at, created_at, updated_at
		FROM subscriptions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1`
	s := &domain.Subscription{}
	err := r.pool.QueryRow(ctx, q, userID).Scan(
		&s.ID, &s.UserID, &s.ProductID, &s.PurchaseToken, &s.Status, &s.ExpiryTime,
		&s.Acknowledged, &s.LastVerifiedAt, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return s, nil
}

func (r *SubscriptionRepository) ListAll(ctx context.Context) ([]*domain.Subscription, error) {
	const q = `
		SELECT s.id, s.user_id, s.product_id, s.purchase_token, s.status,
			s.expiry_time, s.acknowledged, s.last_verified_at, s.created_at, s.updated_at
		FROM subscriptions s
		ORDER BY s.created_at DESC`
	rows, err := r.pool.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subs []*domain.Subscription
	for rows.Next() {
		s := &domain.Subscription{}
		if err := rows.Scan(
			&s.ID, &s.UserID, &s.ProductID, &s.PurchaseToken, &s.Status,
			&s.ExpiryTime, &s.Acknowledged, &s.LastVerifiedAt, &s.CreatedAt, &s.UpdatedAt,
		); err != nil {
			return nil, err
		}
		subs = append(subs, s)
	}
	return subs, rows.Err()
}

func (r *SubscriptionRepository) CountActive(ctx context.Context) (int, error) {
	const q = `SELECT COUNT(*) FROM subscriptions WHERE status = 'active'`
	var count int
	err := r.pool.QueryRow(ctx, q).Scan(&count)
	return count, err
}

func (r *SubscriptionRepository) CountByStatus(ctx context.Context) (map[string]int, error) {
	const q = `SELECT status, COUNT(*) FROM subscriptions GROUP BY status`
	rows, err := r.pool.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := map[string]int{}
	for rows.Next() {
		var status string
		var count int
		if err := rows.Scan(&status, &count); err != nil {
			return nil, err
		}
		result[status] = count
	}
	return result, rows.Err()
}

func (r *SubscriptionRepository) FindByPurchaseToken(ctx context.Context, token string) (*domain.Subscription, error) {
	const q = `
		SELECT id, user_id, product_id, purchase_token, status, expiry_time,
			acknowledged, last_verified_at, created_at, updated_at
		FROM subscriptions
		WHERE purchase_token = $1`
	s := &domain.Subscription{}
	err := r.pool.QueryRow(ctx, q, token).Scan(
		&s.ID, &s.UserID, &s.ProductID, &s.PurchaseToken, &s.Status, &s.ExpiryTime,
		&s.Acknowledged, &s.LastVerifiedAt, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return s, nil
}
