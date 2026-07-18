package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

type PasswordResetRepository struct {
	pool *pgxpool.Pool
}

func NewPasswordResetRepository(pool *pgxpool.Pool) *PasswordResetRepository {
	return &PasswordResetRepository{pool: pool}
}

func (r *PasswordResetRepository) Create(ctx context.Context, pr *domain.PasswordReset) error {
	const q = `
		INSERT INTO password_resets (user_id, email, otp_code, expires_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at`
	return r.pool.QueryRow(ctx, q, pr.UserID, pr.Email, pr.OTPCode, pr.ExpiresAt).Scan(&pr.ID, &pr.CreatedAt)
}

func (r *PasswordResetRepository) FindLatestByEmail(ctx context.Context, email string) (*domain.PasswordReset, error) {
	const q = `SELECT id, user_id, email, otp_code, expires_at, used, created_at FROM password_resets WHERE email = $1 ORDER BY created_at DESC LIMIT 1`
	pr := &domain.PasswordReset{}
	err := r.pool.QueryRow(ctx, q, email).Scan(&pr.ID, &pr.UserID, &pr.Email, &pr.OTPCode, &pr.ExpiresAt, &pr.Used, &pr.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return pr, nil
}

func (r *PasswordResetRepository) MarkUsed(ctx context.Context, id string) error {
	const q = `UPDATE password_resets SET used = true WHERE id = $1`
	_, err := r.pool.Exec(ctx, q, id)
	return err
}
