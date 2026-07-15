package usecase

import (
	"context"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

type AuthUsecase struct {
	users     domain.UserRepository
	jwtSecret string
	jwtTTL    time.Duration
}

func NewAuthUsecase(users domain.UserRepository, jwtSecret string, jwtTTL time.Duration) *AuthUsecase {
	return &AuthUsecase{users: users, jwtSecret: jwtSecret, jwtTTL: jwtTTL}
}

func (u *AuthUsecase) Register(ctx context.Context, email, password string) (token string, user *domain.User, err error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", nil, err
	}

	newUser := &domain.User{Email: email, PasswordHash: string(hash)}
	if err := u.users.Create(ctx, newUser); err != nil {
		return "", nil, err
	}

	token, err = jwtutil.Issue(u.jwtSecret, newUser.ID, newUser.Email, u.jwtTTL)
	if err != nil {
		return "", nil, err
	}
	return token, newUser, nil
}

func (u *AuthUsecase) Login(ctx context.Context, email, password string) (token string, user *domain.User, err error) {
	existing, err := u.users.FindByEmail(ctx, email)
	if err != nil {
		if err == domain.ErrNotFound {
			return "", nil, domain.ErrInvalidCredentials
		}
		return "", nil, err
	}

	if bcryptErr := bcrypt.CompareHashAndPassword([]byte(existing.PasswordHash), []byte(password)); bcryptErr != nil {
		return "", nil, domain.ErrInvalidCredentials
	}

	token, err = jwtutil.Issue(u.jwtSecret, existing.ID, existing.Email, u.jwtTTL)
	if err != nil {
		return "", nil, err
	}
	return token, existing, nil
}

func (u *AuthUsecase) Me(ctx context.Context, userID string) (*domain.User, error) {
	return u.users.FindByID(ctx, userID)
}
