package usecase

import (
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

// ErrInvalidBackupPayload wraps every validateBackupPayload/decode failure
// so the HTTP handler can safely echo its message back to the client (it
// never contains anything beyond "your JSON/gzip is malformed"), while any
// other error from Upload (e.g. a Postgres/pgx failure from the Create
// call) does NOT match this sentinel and must get a generic message
// instead - unlike a validation error, a raw storage-layer error could leak
// SQL/internal details to the client.
var ErrInvalidBackupPayload = errors.New("invalid backup payload")

// ErrContentHashMismatch means the client's declared Idempotency-Key/hash
// doesn't match what the payload actually hashes to - the upload is
// rejected rather than silently trusting the client's claim, since the hash
// is also what upload idempotency and integrity verification rely on.
var ErrContentHashMismatch = errors.New("content hash does not match payload")

// UploadInput carries a raw upload request. Payload is stored and forwarded
// verbatim - ContentEncoding only tells the usecase how to transiently
// decode it for shape validation.
type UploadInput struct {
	Payload         []byte
	ContentEncoding string // "gzip" or "identity" ("" defaults to "identity")
	ContentHash     string // client-declared sha256 hex of the *uncompressed* JSON; "" skips the mismatch check
	DeviceID        string
}

type BackupUsecase struct {
	backups        domain.BackupRepository
	retentionCount int
}

func NewBackupUsecase(backups domain.BackupRepository, retentionCount int) *BackupUsecase {
	return &BackupUsecase{backups: backups, retentionCount: retentionCount}
}

// Upload validates the payload's shape and persists it as a new immutable
// backup snapshot, unless a backup with the same (userID, contentHash)
// already exists - in which case the existing row is returned instead of
// creating a duplicate. This makes retries after a timed-out-but-actually-
// successful request safe to repeat. Pro-tier enforcement happens in the
// HTTP middleware layer before this is ever called - this method assumes
// the caller is already authorized.
func (u *BackupUsecase) Upload(ctx context.Context, userID string, in UploadInput) (*domain.Backup, error) {
	encoding := in.ContentEncoding
	if encoding == "" {
		encoding = "identity"
	}
	if encoding != "gzip" && encoding != "identity" {
		return nil, fmt.Errorf("%w: unsupported content encoding %q", ErrInvalidBackupPayload, encoding)
	}

	decoded, err := decodeBackupPayload(in.Payload, encoding)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrInvalidBackupPayload, err)
	}
	if err := validateBackupPayload(decoded); err != nil {
		return nil, err
	}

	sum := sha256.Sum256(decoded)
	computedHash := hex.EncodeToString(sum[:])
	if in.ContentHash != "" && in.ContentHash != computedHash {
		return nil, fmt.Errorf("%w: declared %s, computed %s", ErrContentHashMismatch, in.ContentHash, computedHash)
	}

	if existing, err := u.backups.FindByUserIDAndHash(ctx, userID, computedHash); err == nil {
		return existing, nil
	} else if !errors.Is(err, domain.ErrNotFound) {
		return nil, err
	}

	backup := &domain.Backup{
		UserID:          userID,
		Payload:         in.Payload,
		ContentHash:     computedHash,
		ContentEncoding: encoding,
		SizeBytes:       int64(len(in.Payload)),
		DeviceID:        in.DeviceID,
	}
	if err := u.backups.Create(ctx, backup); err != nil {
		return nil, err
	}

	u.pruneOld(ctx, userID)

	return backup, nil
}

// decodeBackupPayload returns payload as plain JSON bytes, decompressing it
// first if encoding is "gzip".
func decodeBackupPayload(payload []byte, encoding string) ([]byte, error) {
	if encoding != "gzip" {
		return payload, nil
	}
	r, err := gzip.NewReader(bytes.NewReader(payload))
	if err != nil {
		return nil, fmt.Errorf("payload is not valid gzip: %w", err)
	}
	defer r.Close()
	decoded, err := io.ReadAll(r)
	if err != nil {
		return nil, fmt.Errorf("failed to decompress payload: %w", err)
	}
	return decoded, nil
}

// validateBackupPayload checks the JSON parses and has a non-empty "tables"
// object, without unmarshaling individual field values (see domain.Backup's
// doc comment for why the payload is otherwise treated as opaque bytes).
func validateBackupPayload(payload []byte) error {
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
