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

func (r *fakeUserRepo) UpdatePassword(ctx context.Context, userID, newPasswordHash string) error {
	u, ok := r.byID[userID]
	if !ok {
		return domain.ErrNotFound
	}
	u.PasswordHash = newPasswordHash
	return nil
}

func (r *fakeUserRepo) Count(ctx context.Context) (int, error) {
	return len(r.byID), nil
}

// fakeRefreshTokenRepo is an in-memory stand-in for
// domain.RefreshTokenRepository, keyed by token hash like the real
// Postgres-backed one.
type fakeRefreshTokenRepo struct {
	byHash map[string]*domain.RefreshToken
	nextID int
}

func newFakeRefreshTokenRepo() *fakeRefreshTokenRepo {
	return &fakeRefreshTokenRepo{byHash: map[string]*domain.RefreshToken{}}
}

func (r *fakeRefreshTokenRepo) Create(ctx context.Context, rt *domain.RefreshToken) error {
	r.nextID++
	rt.ID = fmt.Sprintf("rt-%d", r.nextID)
	rt.CreatedAt = time.Now()
	r.byHash[rt.TokenHash] = rt
	return nil
}

func (r *fakeRefreshTokenRepo) FindByHash(ctx context.Context, tokenHash string) (*domain.RefreshToken, error) {
	rt, ok := r.byHash[tokenHash]
	if !ok {
		return nil, domain.ErrNotFound
	}
	return rt, nil
}

func (r *fakeRefreshTokenRepo) Revoke(ctx context.Context, id string) error {
	for _, rt := range r.byHash {
		if rt.ID == id {
			now := time.Now()
			rt.RevokedAt = &now
			return nil
		}
	}
	return nil
}

const testJWTSecret = "test-secret"

func newTestAuthUsecase(users domain.UserRepository, refreshTokens domain.RefreshTokenRepository, adminEmail string) *AuthUsecase {
	return NewAuthUsecase(users, refreshTokens, testJWTSecret, time.Hour, 30*24*time.Hour, adminEmail)
}

func TestRegister_SuccessHashesPasswordAndIssuesValidToken(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	accessToken, refreshToken, user, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "hunter22222", "08123456789")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}
	if user.Email != "owner@example.com" {
		t.Errorf("expected Email owner@example.com, got %s", user.Email)
	}
	if user.ID == "" {
		t.Error("expected a non-empty user ID")
	}
	if refreshToken == "" {
		t.Error("expected a non-empty refresh token")
	}

	// Password must never be stored in plaintext.
	if user.PasswordHash == "hunter22222" {
		t.Fatal("password hash equals the plaintext password — not hashed")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte("hunter22222")); err != nil {
		t.Fatalf("stored hash does not match the registered password: %v", err)
	}

	claims, err := jwtutil.Verify(testJWTSecret, accessToken)
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
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	if _, _, _, err := uc.Register(context.Background(), "Test", "dupe@example.com", "password1", "08123456789"); err != nil {
		t.Fatalf("first Register failed: %v", err)
	}

	_, _, _, err := uc.Register(context.Background(), "Test", "dupe@example.com", "differentpassword", "08123456789")
	if err != domain.ErrEmailTaken {
		t.Fatalf("expected ErrEmailTaken, got %v", err)
	}
}

func TestLogin_SuccessWithCorrectPassword(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	if _, _, _, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "correcthorse", "08123456789"); err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	accessToken, refreshToken, user, err := uc.Login(context.Background(), "owner@example.com", "correcthorse")
	if err != nil {
		t.Fatalf("Login failed: %v", err)
	}
	if user.Email != "owner@example.com" {
		t.Errorf("expected Email owner@example.com, got %s", user.Email)
	}
	if refreshToken == "" {
		t.Error("expected a non-empty refresh token")
	}
	if _, err := jwtutil.Verify(testJWTSecret, accessToken); err != nil {
		t.Fatalf("issued login token failed verification: %v", err)
	}
}

func TestLogin_WrongPasswordReturnsInvalidCredentials(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	if _, _, _, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "correcthorse", "08123456789"); err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	_, _, _, err := uc.Login(context.Background(), "owner@example.com", "wrongpassword")
	if err != domain.ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials, got %v", err)
	}
}

// Unknown emails must map to the same ErrInvalidCredentials as a wrong
// password, not the repository's ErrNotFound — otherwise a client could
// enumerate registered emails by comparing error responses.
func TestLogin_UnknownEmailReturnsInvalidCredentialsNotNotFound(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	_, _, _, err := uc.Login(context.Background(), "nobody@example.com", "whatever123")
	if err != domain.ErrInvalidCredentials {
		t.Fatalf("expected ErrInvalidCredentials (not ErrNotFound), got %v", err)
	}
}

func TestMe_ReturnsUserByID(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	_, _, registered, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "password123", "08123456789")
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
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "")

	_, err := uc.Me(context.Background(), "does-not-exist")
	if err != domain.ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
}

func TestRegister_AutoPromotesAdminEmail(t *testing.T) {
	repo := newFakeUserRepo()
	uc := newTestAuthUsecase(repo, newFakeRefreshTokenRepo(), "admin@example.com")

	_, _, user, err := uc.Register(context.Background(), "Admin User", "admin@example.com", "password123", "08123456789")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}
	if user.Role != "admin" {
		t.Fatalf("expected role admin for admin email, got %s", user.Role)
	}

	accessToken, _, _, err := uc.Login(context.Background(), "admin@example.com", "password123")
	if err != nil {
		t.Fatalf("Login failed: %v", err)
	}
	claims, err := jwtutil.Verify(testJWTSecret, accessToken)
	if err != nil {
		t.Fatalf("token verification failed: %v", err)
	}
	if claims.Role != "admin" {
		t.Fatalf("expected claims.Role admin, got %s", claims.Role)
	}
}

func TestRefreshToken_SuccessRotatesAndIssuesNewPair(t *testing.T) {
	repo := newFakeUserRepo()
	refreshRepo := newFakeRefreshTokenRepo()
	uc := newTestAuthUsecase(repo, refreshRepo, "")

	_, refreshToken, user, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "correcthorse", "08123456789")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	newAccess, newRefresh, err := uc.RefreshToken(context.Background(), refreshToken)
	if err != nil {
		t.Fatalf("RefreshToken failed: %v", err)
	}
	if newRefresh == "" || newRefresh == refreshToken {
		t.Fatalf("expected a fresh, different refresh token, got %q", newRefresh)
	}

	claims, err := jwtutil.Verify(testJWTSecret, newAccess)
	if err != nil {
		t.Fatalf("new access token failed verification: %v", err)
	}
	if claims.UserID != user.ID {
		t.Fatalf("expected claims for user %s, got %s", user.ID, claims.UserID)
	}

	// The old refresh token must be rotated out - reusing it is a replay.
	if _, _, err := uc.RefreshToken(context.Background(), refreshToken); err != domain.ErrRefreshTokenInvalid {
		t.Fatalf("expected ErrRefreshTokenInvalid reusing a rotated token, got %v", err)
	}
}

func TestRefreshToken_UnknownTokenReturnsInvalid(t *testing.T) {
	uc := newTestAuthUsecase(newFakeUserRepo(), newFakeRefreshTokenRepo(), "")

	_, _, err := uc.RefreshToken(context.Background(), "not-a-real-token")
	if err != domain.ErrRefreshTokenInvalid {
		t.Fatalf("expected ErrRefreshTokenInvalid, got %v", err)
	}
}

func TestRefreshToken_ExpiredTokenReturnsInvalid(t *testing.T) {
	repo := newFakeUserRepo()
	refreshRepo := newFakeRefreshTokenRepo()
	uc := newTestAuthUsecase(repo, refreshRepo, "")

	_, refreshToken, _, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "correcthorse", "08123456789")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	// Force the stored token into the past to simulate expiry.
	for _, rt := range refreshRepo.byHash {
		rt.ExpiresAt = time.Now().Add(-time.Minute)
	}

	if _, _, err := uc.RefreshToken(context.Background(), refreshToken); err != domain.ErrRefreshTokenInvalid {
		t.Fatalf("expected ErrRefreshTokenInvalid for an expired token, got %v", err)
	}
}

func TestLogout_RevokesRefreshToken(t *testing.T) {
	repo := newFakeUserRepo()
	refreshRepo := newFakeRefreshTokenRepo()
	uc := newTestAuthUsecase(repo, refreshRepo, "")

	_, refreshToken, _, err := uc.Register(context.Background(), "Test Owner", "owner@example.com", "correcthorse", "08123456789")
	if err != nil {
		t.Fatalf("Register failed: %v", err)
	}

	if err := uc.Logout(context.Background(), refreshToken); err != nil {
		t.Fatalf("Logout failed: %v", err)
	}

	if _, _, err := uc.RefreshToken(context.Background(), refreshToken); err != domain.ErrRefreshTokenInvalid {
		t.Fatalf("expected a logged-out refresh token to be rejected, got %v", err)
	}
}

func TestLogout_UnknownTokenIsNotAnError(t *testing.T) {
	uc := newTestAuthUsecase(newFakeUserRepo(), newFakeRefreshTokenRepo(), "")

	if err := uc.Logout(context.Background(), "never-issued"); err != nil {
		t.Fatalf("expected Logout of an unknown token to be a no-op, got %v", err)
	}
}
