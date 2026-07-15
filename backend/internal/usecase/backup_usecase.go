package usecase

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

// ErrInvalidBackupPayload wraps every validateBackupPayload failure so the
// HTTP handler can safely echo its message back to the client (it never
// contains anything beyond "your JSON is malformed"), while any other
// error from Upload (e.g. a Postgres/pgx failure from the Create call)
// does NOT match this sentinel and must get a generic message instead -
// unlike a validation error, a raw storage-layer error could leak
// SQL/internal details to the client.
var ErrInvalidBackupPayload = errors.New("invalid backup payload")

type BackupUsecase struct {
	backups        domain.BackupRepository
	retentionCount int
}

func NewBackupUsecase(backups domain.BackupRepository, retentionCount int) *BackupUsecase {
	return &BackupUsecase{backups: backups, retentionCount: retentionCount}
}

// Upload validates the JSON payload's shape and persists it as a new
// immutable backup snapshot. Pro-tier enforcement happens in the HTTP
// middleware layer before this is ever called — this method assumes the
// caller is already authorized.
func (u *BackupUsecase) Upload(ctx context.Context, userID string, payload json.RawMessage) (*domain.Backup, error) {
	if err := validateBackupPayload(payload); err != nil {
		return nil, err
	}

	backup := &domain.Backup{UserID: userID, Payload: payload}
	if err := u.backups.Create(ctx, backup); err != nil {
		return nil, err
	}

	u.pruneOld(ctx, userID)

	return backup, nil
}

// validateBackupPayload checks the JSON parses and has a non-empty "tables"
// object, without unmarshaling individual field values (see domain.Backup's
// doc comment for why the payload is otherwise treated as opaque bytes).
func validateBackupPayload(payload json.RawMessage) error {
	var shape struct {
		Tables map[string]json.RawMessage `json:"tables"`
	}
	if err := json.Unmarshal(payload, &shape); err != nil {
		return fmt.Errorf("%w: payload is not valid JSON: %v", ErrInvalidBackupPayload, err)
	}
	if len(shape.Tables) == 0 {
		return fmt.Errorf("%w: payload missing a non-empty 'tables' object", ErrInvalidBackupPayload)
	}
	return nil
}

func (u *BackupUsecase) pruneOld(ctx context.Context, userID string) {
	ids, err := u.backups.ListOlderThanNewestNIDs(ctx, userID, u.retentionCount)
	if err != nil {
		return
	}
	for _, id := range ids {
		_ = u.backups.Delete(ctx, id, userID)
	}
}

func (u *BackupUsecase) List(ctx context.Context, userID string) ([]*domain.BackupSummary, error) {
	return u.backups.ListByUserID(ctx, userID)
}

func (u *BackupUsecase) GetLatest(ctx context.Context, userID string) (*domain.Backup, error) {
	return u.backups.FindLatestByUserID(ctx, userID)
}

func (u *BackupUsecase) GetByID(ctx context.Context, userID, id string) (*domain.Backup, error) {
	return u.backups.FindByID(ctx, id, userID)
}

func (u *BackupUsecase) Delete(ctx context.Context, userID, id string) error {
	return u.backups.Delete(ctx, id, userID)
}
