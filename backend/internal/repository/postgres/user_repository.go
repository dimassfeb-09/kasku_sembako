package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

const pgUniqueViolation = "23505"

type UserRepository struct {
	pool *pgxpool.Pool
}

func NewUserRepository(pool *pgxpool.Pool) *UserRepository {
	return &UserRepository{pool: pool}
}

func (r *UserRepository) Create(ctx context.Context, u *domain.User) error {
	const q = `
		INSERT INTO users (email, password_hash, role)
		VALUES ($1, $2, $3)
		RETURNING id, created_at`
	err := r.pool.QueryRow(ctx, q, u.Email, u.PasswordHash, u.Role).Scan(&u.ID, &u.CreatedAt)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == pgUniqueViolation {
			return domain.ErrEmailTaken
		}
		return err
	}
	return nil
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	const q = `SELECT id, email, password_hash, role, created_at FROM users WHERE email = $1`
	u := &domain.User{}
	err := r.pool.QueryRow(ctx, q, email).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.Role, &u.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return u, nil
}

func (r *UserRepository) FindByID(ctx context.Context, id string) (*domain.User, error) {
	const q = `SELECT id, email, password_hash, role, created_at FROM users WHERE id = $1`
	u := &domain.User{}
	err := r.pool.QueryRow(ctx, q, id).Scan(&u.ID, &u.Email, &u.PasswordHash, &u.Role, &u.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return u, nil
}

func (r *UserRepository) ListAll(ctx context.Context) ([]*domain.User, error) {
	const q = `SELECT id, email, role, created_at FROM users ORDER BY created_at DESC`
	rows, err := r.pool.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*domain.User
	for rows.Next() {
		u := &domain.User{}
		if err := rows.Scan(&u.ID, &u.Email, &u.Role, &u.CreatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

func (r *UserRepository) Count(ctx context.Context) (int, error) {
	const q = `SELECT COUNT(*) FROM users`
	var count int
	err := r.pool.QueryRow(ctx, q).Scan(&count)
	return count, err
}
