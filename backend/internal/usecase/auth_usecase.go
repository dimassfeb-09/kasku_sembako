package usecase

import (
	"context"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

type AuthUsecase struct {
	users      domain.UserRepository
	jwtSecret  string
	jwtTTL     time.Duration
	adminEmail string
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

func NewAuthUsecase(users domain.UserRepository, jwtSecret string, jwtTTL time.Duration, adminEmail string) *AuthUsecase {
	return &AuthUsecase{users: users, jwtSecret: jwtSecret, jwtTTL: jwtTTL, adminEmail: adminEmail}
}

func (u *AuthUsecase) Register(ctx context.Context, email, password string) (token string, user *domain.User, err error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", nil, err
	}

	role := "user"
	if normalizeEmail(email) == normalizeEmail(u.adminEmail) {
		role = "admin"
	}

	newUser := &domain.User{Email: normalizeEmail(email), PasswordHash: string(hash), Role: role}
	if err := u.users.Create(ctx, newUser); err != nil {
		return "", nil, err
	}

	token, err = jwtutil.Issue(u.jwtSecret, newUser.ID, newUser.Email, newUser.Role, u.jwtTTL)
	if err != nil {
		return "", nil, err
	}
	return token, newUser, nil
}

func (u *AuthUsecase) Login(ctx context.Context, email, password string) (token string, user *domain.User, err error) {
	existing, err := u.users.FindByEmail(ctx, normalizeEmail(email))
	if err != nil {
		if err == domain.ErrNotFound {
			// Dummy bcrypt compare to equalize timing with the real
			// "wrong password" path below - see dummyPasswordHash's doc.
			_ = bcrypt.CompareHashAndPassword([]byte(dummyPasswordHash), []byte(password))
			return "", nil, domain.ErrInvalidCredentials
		}
		return "", nil, err
	}

	if bcryptErr := bcrypt.CompareHashAndPassword([]byte(existing.PasswordHash), []byte(password)); bcryptErr != nil {
		return "", nil, domain.ErrInvalidCredentials
	}

	token, err = jwtutil.Issue(u.jwtSecret, existing.ID, existing.Email, existing.Role, u.jwtTTL)
	if err != nil {
		return "", nil, err
	}
	return token, existing, nil
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
