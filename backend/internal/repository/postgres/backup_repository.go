package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

type BackupRepository struct {
	pool *pgxpool.Pool
}

func NewBackupRepository(pool *pgxpool.Pool) *BackupRepository {
	return &BackupRepository{pool: pool}
}

func (r *BackupRepository) CountAll(ctx context.Context) (int, error) {
	const q = `SELECT COUNT(*) FROM backups`
	var count int
	err := r.pool.QueryRow(ctx, q).Scan(&count)
	return count, err
}

func (r *BackupRepository) Create(ctx context.Context, b *domain.Backup) error {
	const q = `
		INSERT INTO backups (user_id, payload, content_hash, content_encoding, size_bytes, device_id)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at`
	return r.pool.QueryRow(ctx, q, b.UserID, b.Payload, b.ContentHash, b.ContentEncoding, b.SizeBytes, nullIfEmpty(b.DeviceID)).
		Scan(&b.ID, &b.CreatedAt)
}

func (r *BackupRepository) FindLatestByUserID(ctx context.Context, userID string) (*domain.Backup, error) {
	const q = `
		SELECT id, user_id, payload, content_hash, content_encoding, size_bytes, COALESCE(device_id, ''), created_at
		FROM backups
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1`
	return r.scanOne(ctx, q, userID)
}

func (r *BackupRepository) FindByUserIDAndHash(ctx context.Context, userID, contentHash string) (*domain.Backup, error) {
	const q = `
		SELECT id, user_id, payload, content_hash, content_encoding, size_bytes, COALESCE(device_id, ''), created_at
		FROM backups
		WHERE user_id = $1 AND content_hash = $2`
	return r.scanOne(ctx, q, userID, contentHash)
}

func (r *BackupRepository) FindByID(ctx context.Context, id, userID string) (*domain.Backup, error) {
	const q = `
		SELECT id, user_id, payload, content_hash, content_encoding, size_bytes, COALESCE(device_id, ''), created_at
		FROM backups
		WHERE id = $1 AND user_id = $2`
	return r.scanOne(ctx, q, id, userID)
}

func (r *BackupRepository) scanOne(ctx context.Context, q string, args ...any) (*domain.Backup, error) {
	b := &domain.Backup{}
	err := r.pool.QueryRow(ctx, q, args...).Scan(
		&b.ID, &b.UserID, &b.Payload, &b.ContentHash, &b.ContentEncoding, &b.SizeBytes, &b.DeviceID, &b.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return b, nil
}

func (r *BackupRepository) ListByUserID(ctx context.Context, userID string) ([]*domain.BackupSummary, error) {
	const q = `
		SELECT id, created_at, size_bytes, COALESCE(device_id, '')
		FROM backups
		WHERE user_id = $1
		ORDER BY created_at DESC`
	rows, err := r.pool.Query(ctx, q, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []*domain.BackupSummary
	for rows.Next() {
		s := &domain.BackupSummary{}
		if err := rows.Scan(&s.ID, &s.CreatedAt, &s.SizeBytes, &s.DeviceID); err != nil {
			return nil, err
		}
		result = append(result, s)
	}
	return result, rows.Err()
}

func (r *BackupRepository) ListOlderThanNewestNIDs(ctx context.Context, userID string, keepNewest int) ([]string, error) {
	const q = `
		SELECT id
		FROM backups
		WHERE user_id = $1
		ORDER BY created_at DESC
		OFFSET $2`
	rows, err := r.pool.Query(ctx, q, userID, keepNewest)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (r *BackupRepository) Delete(ctx context.Context, id, userID string) error {
	const q = `DELETE FROM backups WHERE id = $1 AND user_id = $2`
	tag, err := r.pool.Exec(ctx, q, id, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func nullIfEmpty(s string) any {
	if s == "" {
		return nil
	}
	return s
}
