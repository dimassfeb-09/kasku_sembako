package usecase

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

// fakeBackupRepo is an in-memory stand-in for domain.BackupRepository.
type fakeBackupRepo struct {
	byID        map[string]*domain.Backup
	createCalls int
}

func newFakeBackupRepo() *fakeBackupRepo {
	return &fakeBackupRepo{byID: map[string]*domain.Backup{}}
}

func (r *fakeBackupRepo) Create(ctx context.Context, b *domain.Backup) error {
	r.createCalls++
	b.ID = fmt.Sprintf("backup-%d", len(r.byID)+1)
	b.CreatedAt = time.Now()
	r.byID[b.ID] = b
	return nil
}

func (r *fakeBackupRepo) FindLatestByUserID(ctx context.Context, userID string) (*domain.Backup, error) {
	var latest *domain.Backup
	for _, b := range r.byID {
		if b.UserID == userID && (latest == nil || b.CreatedAt.After(latest.CreatedAt)) {
			latest = b
		}
	}
	if latest == nil {
		return nil, domain.ErrNotFound
	}
	return latest, nil
}

func (r *fakeBackupRepo) FindByID(ctx context.Context, id, userID string) (*domain.Backup, error) {
	b, ok := r.byID[id]
	if !ok || b.UserID != userID {
		return nil, domain.ErrNotFound
	}
	return b, nil
}

func (r *fakeBackupRepo) ListByUserID(ctx context.Context, userID string) ([]*domain.BackupSummary, error) {
	var result []*domain.BackupSummary
	for _, b := range r.byID {
		if b.UserID == userID {
			result = append(result, &domain.BackupSummary{
				ID:        b.ID,
				CreatedAt: b.CreatedAt,
				SizeBytes: int64(len(b.Payload)),
			})
		}
	}
	return result, nil
}

func (r *fakeBackupRepo) ListOlderThanNewestNIDs(ctx context.Context, userID string, keepNewest int) ([]string, error) {
	return nil, nil
}

func (r *fakeBackupRepo) Delete(ctx context.Context, id, userID string) error {
	b, ok := r.byID[id]
	if !ok || b.UserID != userID {
		return domain.ErrNotFound
	}
	delete(r.byID, id)
	return nil
}

func TestUpload_ValidPayloadSucceedsAndCallsCreateOnce(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	payload := []byte(`{"tables":{"users":[{"id":"u1"}]}}`)
	backup, err := uc.Upload(context.Background(), "user-1", payload)
	if err != nil {
		t.Fatalf("Upload failed: %v", err)
	}
	if backup.UserID != "user-1" {
		t.Fatalf("expected UserID user-1, got %s", backup.UserID)
	}
	if repo.createCalls != 1 {
		t.Fatalf("expected Create to be called exactly once, got %d", repo.createCalls)
	}
}

func TestUpload_MalformedJSONFailsAndNeverCallsCreate(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	_, err := uc.Upload(context.Background(), "user-1", []byte(`not json`))
	if err == nil {
		t.Fatal("expected an error for malformed JSON, got nil")
	}
	if repo.createCalls != 0 {
		t.Fatalf("expected Create not to be called, got %d calls", repo.createCalls)
	}
}

func TestUpload_MissingTablesKeyFails(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	_, err := uc.Upload(context.Background(), "user-1", []byte(`{"schemaVersion":4}`))
	if err == nil {
		t.Fatal("expected an error for missing 'tables' key, got nil")
	}
	if repo.createCalls != 0 {
		t.Fatalf("expected Create not to be called, got %d calls", repo.createCalls)
	}
}

func TestUpload_EmptyTablesObjectFails(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	_, err := uc.Upload(context.Background(), "user-1", []byte(`{"tables":{}}`))
	if err == nil {
		t.Fatal("expected an error for empty 'tables' object, got nil")
	}
	if repo.createCalls != 0 {
		t.Fatalf("expected Create not to be called, got %d calls", repo.createCalls)
	}
}

func TestDelete_ByNonOwnerReturnsNotFoundAndLeavesRowUntouched(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	payload := []byte(`{"tables":{"users":[{"id":"u1"}]}}`)
	backup, err := uc.Upload(context.Background(), "owner", payload)
	if err != nil {
		t.Fatalf("Upload failed: %v", err)
	}

	err = uc.Delete(context.Background(), "someone-else", backup.ID)
	if err != domain.ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
	if _, ok := repo.byID[backup.ID]; !ok {
		t.Fatal("expected backup row to remain untouched after a non-owner delete attempt")
	}
}

func TestGetByID_ByNonOwnerReturnsNotFound(t *testing.T) {
	repo := newFakeBackupRepo()
	uc := NewBackupUsecase(repo, 3)

	payload := []byte(`{"tables":{"users":[{"id":"u1"}]}}`)
	backup, err := uc.Upload(context.Background(), "owner", payload)
	if err != nil {
		t.Fatalf("Upload failed: %v", err)
	}

	_, err = uc.GetByID(context.Background(), "someone-else", backup.ID)
	if err != domain.ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
}
