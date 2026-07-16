package usecase

import (
	"context"
	"fmt"
	"testing"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

// fakeUserRepo is an in-memory stand-in for domain.UserRepository. Create
// mimics the real Postgres repository's unique-email-violation mapping
// (domain.ErrEmailTaken) so Register's error propagation is exercised the
// same way it would be against a real database.
type fakeUserRepo struct {
	byEmail map[string]*domain.User
	byID    map[string]*domain.User
}

func newFakeUserRepo() *fakeUserRepo {
	return &fakeUserRepo{byEmail: map[string]*domain.User{}, byID: map[string]*domain.User{}}
}

func (r *fakeUserRepo) Create(ctx context.Context, u *domain.User) error {
	if _, exists := r.byEmail[u.Email]; exists {
		return domain.ErrEmailTaken
	}
	u.ID = fmt.Sprintf("user-%d", len(r.byID)+1)
	u.CreatedAt = time.Now()
	r.byEmail[u.Email] = u
	r.byID[u.ID] = u
	return nil
}

func (r *fakeUserRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	u, ok := r.byEmail[email]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return u, nil
}

func (r *fakeUserRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	u, ok := r.byID[id]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return u, nil
}

func (r *fakeUserRepo) ListAll(ctx context.Context) ([]*domain.User, error) {
	users := make([]*domain.User, 0, len(r.byID))
	for _, u := range r.byID {
		users = append(users, u)
	}
	return users, nil
}

func (r *fakeUserRepo) Count(ctx context.Context) (int, error) {
	return len(r.byID), nil
}

const testJWTSecret = "test-secret"

func TestRegister_SuccessHashesPasswordAndIssuesValidToken(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	token, user, err := uc.Register(context.Background(), "owner@example.com", "hunter22222")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}
	if user.Email != "owner@example.com" {
		t.Errorf("expected Email owner@example.com, got %s", user.Email)
	}
	if user.ID == "" {
		t.Error("expected a non-empty user ID")
	}

	// Password must never be stored in plaintext.
	if user.PasswordHash == "hunter22222" {
		t.Fatal("password hash equals the plaintext password — not hashed")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte("hunter22222")); err != nil {
		t.Fatalf("stored hash does not match the registered password: %v", err)
	}

	claims, err := jwtutil.Verify(testJWTSecret, token)
	if err != nil {
		t.Fatalf("issued token failed verification: %v", err)
	}
	if claims.UserID != user.ID || claims.Email != user.Email {
		t.Fatalf("token claims (%s, %s) don't match the registered user (%s, %s)",
			claims.UserID, claims.Email, user.ID, user.Email)
	}
}

func TestRegister_DuplicateEmailReturnsErrEmailTaken(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	if _, _, err := uc.Register(context.Background(), "dupe@example.com", "password1"); err != nil {
		t.Fatalf("first Register failed: %v", err)
	}

	_, _, err := uc.Register(context.Background(), "dupe@example.com", "differentpassword")
	if err != domain.ErrEmailTaken {
		t.Fatalf("expected ErrEmailTaken, got %v", err)
	}
}

func TestLogin_SuccessWithCorrectPassword(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	if _, _, err := uc.Register(context.Background(), "owner@example.com", "correcthorse"); err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	token, user, err := uc.Login(context.Background(), "owner@example.com", "correcthorse")
	if err != nil {
		t.Fatalf("Login failed: %v", err)
	}
	if user.Email != "owner@example.com" {
		t.Errorf("expected Email owner@example.com, got %s", user.Email)
	}
	if _, err := jwtutil.Verify(testJWTSecret, token); err != nil {
		t.Fatalf("issued login token failed verification: %v", err)
	}
}

func TestLogin_WrongPasswordReturnsInvalidCredentials(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	if _, _, err := uc.Register(context.Background(), "owner@example.com", "correcthorse"); err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	_, _, err := uc.Login(context.Background(), "owner@example.com", "wrongpassword")
	if err != domain.ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials, got %v", err)
	}
}

// Unknown emails must map to the same ErrInvalidCredentials as a wrong
// password, not the repository's ErrNotFound — otherwise a client could
// enumerate registered emails by comparing error responses.
func TestLogin_UnknownEmailReturnsInvalidCredentialsNotNotFound(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	_, _, err := uc.Login(context.Background(), "nobody@example.com", "whatever123")
	if err != domain.ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials (not ErrNotFound), got %v", err)
	}
}

func TestMe_ReturnsUserByID(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	_, registered, err := uc.Register(context.Background(), "owner@example.com", "password123")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	user, err := uc.Me(context.Background(), registered.ID)
	if err != nil {
		t.Fatalf("Me failed: %v", err)
	}
	if user.Email != "owner@example.com" {
		t.Fatalf("expected Email owner@example.com, got %s", user.Email)
	}
}

func TestMe_UnknownIDReturnsNotFound(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "")

	_, err := uc.Me(context.Background(), "does-not-exist")
	if err != domain.ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
}

func TestRegister_AutoPromotesAdminEmail(t *testing.T) {
	repo := newFakeUserRepo()
	uc := NewAuthUsecase(repo, testJWTSecret, time.Hour, "admin@example.com")

	_, user, err := uc.Register(context.Background(), "admin@example.com", "password123")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}
	if user.Role != "admin" {
		t.Fatalf("expected role admin for admin email, got %s", user.Role)
	}

	token, _, err := uc.Login(context.Background(), "admin@example.com", "password123")
	if err != nil {
		t.Fatalf("Login failed: %v", err)
	}
	claims, err := jwtutil.Verify(testJWTSecret, token)
	if err != nil {
		t.Fatalf("token verification failed: %v", err)
	}
	if claims.Role != "admin" {
		t.Fatalf("expected claims.Role admin, got %s", claims.Role)
	}
}
