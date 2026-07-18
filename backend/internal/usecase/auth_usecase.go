package usecase

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

type AuthUsecase struct {
	users           domain.UserRepository
	refreshTokens   domain.RefreshTokenRepository
	jwtSecret       string
	accessTokenTTL  time.Duration
	refreshTokenTTL time.Duration
	adminEmail      string
}

// dummyPasswordHash is compared against on every "email not found" login
// attempt so that path costs the same as a real "wrong password" check
// (which always runs bcrypt). Without this, an attacker can enumerate
// registered emails purely by response-time, even though both cases return
// the identical error/message. See auth_usecase_test.go for a regression
// test asserting the two paths take comparable time.
var dummyPasswordHash = func() string {
	hash, err := bcrypt.GenerateFromPassword([]byte("timing-attack-mitigation"), bcrypt.DefaultCost)
	if err != nil {
		// Only fails on a bcrypt cost misconfiguration - a programming
		// error, not a runtime condition worth handling gracefully.
		panic(err)
	}
	return string(hash)
}()

func NewAuthUsecase(users domain.UserRepository, refreshTokens domain.RefreshTokenRepository, jwtSecret string, accessTokenTTL, refreshTokenTTL time.Duration, adminEmail string) *AuthUsecase {
	return &AuthUsecase{
		users:           users,
		refreshTokens:   refreshTokens,
		jwtSecret:       jwtSecret,
		accessTokenTTL:  accessTokenTTL,
		refreshTokenTTL: refreshTokenTTL,
		adminEmail:      adminEmail,
	}
}

func (u *AuthUsecase) Register(ctx context.Context, name, email, password, whatsapp string) (accessToken, refreshToken string, user *domain.User, err error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", "", nil, err
	}

	role := "user"
	if normalizeEmail(email) == normalizeEmail(u.adminEmail) {
		role = "admin"
	}

	newUser := &domain.User{
		Name:         strings.TrimSpace(name),
		Email:        normalizeEmail(email),
		PasswordHash: string(hash),
		WhatsApp:     strings.TrimSpace(whatsapp),
		Role:         role,
	}
	if err := u.users.Create(ctx, newUser); err != nil {
		return "", "", nil, err
	}

	accessToken, refreshToken, err = u.issueTokenPair(ctx, newUser)
	if err != nil {
		return "", "", nil, err
	}
	return accessToken, refreshToken, newUser, nil
}

func (u *AuthUsecase) Login(ctx context.Context, email, password string) (accessToken, refreshToken string, user *domain.User, err error) {
	existing, err := u.users.FindByEmail(ctx, normalizeEmail(email))
	if err != nil {
		if err == domain.ErrNotFound {
			// Dummy bcrypt compare to equalize timing with the real
			// "wrong password" path below - see dummyPasswordHash's doc.
			_ = bcrypt.CompareHashAndPassword([]byte(dummyPasswordHash), []byte(password))
			return "", "", nil, domain.ErrInvalidCredentials
		}
		return "", "", nil, err
	}

	if bcryptErr := bcrypt.CompareHashAndPassword([]byte(existing.PasswordHash), []byte(password)); bcryptErr != nil {
		return "", "", nil, domain.ErrInvalidCredentials
	}

	accessToken, refreshToken, err = u.issueTokenPair(ctx, existing)
	if err != nil {
		return "", "", nil, err
	}
	return accessToken, refreshToken, existing, nil
}

// RefreshToken exchanges a valid, unexpired, unrevoked refresh token for a
// new access/refresh pair. The presented refresh token is revoked in the
// same call (rotation) so it cannot be replayed even if it leaks later.
func (u *AuthUsecase) RefreshToken(ctx context.Context, rawRefreshToken string) (accessToken, newRefreshToken string, err error) {
	hash := hashRefreshToken(rawRefreshToken)
	rt, err := u.refreshTokens.FindByHash(ctx, hash)
	if err != nil {
		if err == domain.ErrNotFound {
			return "", "", domain.ErrRefreshTokenInvalid
		}
		return "", "", err
	}
	if rt.RevokedAt != nil || time.Now().After(rt.ExpiresAt) {
		return "", "", domain.ErrRefreshTokenInvalid
	}

	user, err := u.users.FindByID(ctx, rt.UserID)
	if err != nil {
		if err == domain.ErrNotFound {
			return "", "", domain.ErrRefreshTokenInvalid
		}
		return "", "", err
	}

	if err := u.refreshTokens.Revoke(ctx, rt.ID); err != nil {
		return "", "", err
	}

	return u.issueTokenPair(ctx, user)
}

// Logout revokes the refresh token backing the caller's session. It is
// idempotent - an already-revoked or unknown token is not an error, since
// the end state (this token no longer works) already holds.
func (u *AuthUsecase) Logout(ctx context.Context, rawRefreshToken string) error {
	hash := hashRefreshToken(rawRefreshToken)
	rt, err := u.refreshTokens.FindByHash(ctx, hash)
	if err != nil {
		if err == domain.ErrNotFound {
			return nil
		}
		return err
	}
	return u.refreshTokens.Revoke(ctx, rt.ID)
}

func (u *AuthUsecase) issueTokenPair(ctx context.Context, user *domain.User) (accessToken, refreshToken string, err error) {
	accessToken, err = jwtutil.Issue(u.jwtSecret, user.ID, user.Email, user.Role, u.accessTokenTTL)
	if err != nil {
		return "", "", err
	}

	refreshToken, err = generateRefreshToken()
	if err != nil {
		return "", "", err
	}

	rt := &domain.RefreshToken{
		UserID:    user.ID,
		TokenHash: hashRefreshToken(refreshToken),
		ExpiresAt: time.Now().Add(u.refreshTokenTTL),
	}
	if err := u.refreshTokens.Create(ctx, rt); err != nil {
		return "", "", err
	}

	return accessToken, refreshToken, nil
}

// generateRefreshToken returns a URL-safe, 256-bit-entropy opaque token.
// It is never a JWT: nothing needs to be readable off it, and keeping it
// opaque means the only way to use it is the hash lookup in the DB, which
// is also what makes revocation and rotation possible.
func generateRefreshToken() (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

func hashRefreshToken(raw string) string {
	sum := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(sum[:])
}

// normalizeEmail lowercases and trims an email before it's ever stored or
// looked up, so "Owner@Example.com" and "owner@example.com" can't register
// as two distinct accounts against Postgres's case-sensitive TEXT UNIQUE
// constraint.
func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func (u *AuthUsecase) Me(ctx context.Context, userID string) (*domain.User, error) {
	return u.users.FindByID(ctx, userID)
}

func (u *AuthUsecase) ChangePassword(ctx context.Context, userID, currentPassword, newPassword string) error {
	if len(newPassword) < 8 {
		return fmt.Errorf("password must be at least 8 characters")
	}

	user, err := u.users.FindByID(ctx, userID)
	if err != nil {
		return err
	}

	if bcryptErr := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(currentPassword)); bcryptErr != nil {
		return domain.ErrInvalidCredentials
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	return u.users.UpdatePassword(ctx, userID, string(hash))
}
