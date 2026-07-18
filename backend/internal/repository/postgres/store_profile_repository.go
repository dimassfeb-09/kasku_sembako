package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

type StoreProfileRepository struct {
	pool *pgxpool.Pool
}

func NewStoreProfileRepository(pool *pgxpool.Pool) *StoreProfileRepository {
	return &StoreProfileRepository{pool: pool}
}

func (r *StoreProfileRepository) Upsert(ctx context.Context, p *domain.StoreProfile) error {
	const q = `
		INSERT INTO store_profiles (user_id, owner_name, business_name, business_category, phone, address, business_email, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (user_id) DO UPDATE SET
			owner_name = EXCLUDED.owner_name,
			business_name = EXCLUDED.business_name,
			business_category = EXCLUDED.business_category,
			phone = EXCLUDED.phone,
			address = EXCLUDED.address,
			business_email = EXCLUDED.business_email,
			updated_at = EXCLUDED.updated_at
		RETURNING id, created_at`
	p.UpdatedAt = time.Now()
	err := r.pool.QueryRow(ctx, q,
		p.UserID, p.OwnerName, p.BusinessName,
		p.BusinessCategory, p.Phone, p.Address, p.BusinessEmail, p.UpdatedAt,
	).Scan(&p.ID, &p.CreatedAt)
	if err != nil {
		return err
	}
	return nil
}

func (r *StoreProfileRepository) ListAll(ctx context.Context) ([]*domain.StoreProfile, error) {
	const q = `SELECT id, user_id, owner_name, business_name, business_category, phone, address, business_email, created_at, updated_at FROM store_profiles ORDER BY created_at DESC`
	rows, err := r.pool.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var profiles []*domain.StoreProfile
	for rows.Next() {
		p := &domain.StoreProfile{}
		if err := rows.Scan(
			&p.ID, &p.UserID, &p.OwnerName, &p.BusinessName,
			&p.BusinessCategory, &p.Phone, &p.Address, &p.BusinessEmail, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		profiles = append(profiles, p)
	}
	return profiles, rows.Err()
}

func (r *StoreProfileRepository) CountAll(ctx context.Context) (int, error) {
	const q = `SELECT COUNT(*) FROM store_profiles`
	var count int
	err := r.pool.QueryRow(ctx, q).Scan(&count)
	return count, err
}

func (r *StoreProfileRepository) FindByUserID(ctx context.Context, userID string) (*domain.StoreProfile, error) {
	const q = `SELECT id, user_id, owner_name, business_name, business_category, phone, address, business_email, created_at, updated_at FROM store_profiles WHERE user_id = $1`
	p := &domain.StoreProfile{}
	err := r.pool.QueryRow(ctx, q, userID).Scan(
		&p.ID, &p.UserID, &p.OwnerName, &p.BusinessName,
		&p.BusinessCategory, &p.Phone, &p.Address, &p.BusinessEmail, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return p, nil
}
