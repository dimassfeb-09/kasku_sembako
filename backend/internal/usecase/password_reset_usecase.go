package usecase

import (
	"context"
	"crypto/rand"
	"fmt"
	"math/big"
	"os"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	emailPkg "github.com/dimassfeb-09/kasku_sembako/backend/internal/platform/email"
	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

type PasswordResetUsecase struct {
	usersRepo     domain.UserRepository
	resetRepo     domain.PasswordResetRepository
	emailCfg      emailPkg.Config
	jwtSecret     string
	resetTokenTTL time.Duration
	otpTTL        time.Duration
}

func NewPasswordResetUsecase(
	usersRepo domain.UserRepository,
	resetRepo domain.PasswordResetRepository,
	emailCfg emailPkg.Config,
	jwtSecret string,
	resetTokenTTL time.Duration,
	otpTTL time.Duration,
) *PasswordResetUsecase {
	return &PasswordResetUsecase{
		usersRepo:     usersRepo,
		resetRepo:     resetRepo,
		emailCfg:      emailCfg,
		jwtSecret:     jwtSecret,
		resetTokenTTL: resetTokenTTL,
		otpTTL:        otpTTL,
	}
}

func generateOTP() (string, error) {
	const digits = "0123456789"
	code := make([]byte, 6)
	for i := range code {
		n, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			return "", err
		}
		code[i] = digits[n.Int64()]
	}
	return string(code), nil
}

func isDevMode() bool {
	return os.Getenv("APP_ENV") == "development"
}

func (u *PasswordResetUsecase) RequestOTP(ctx context.Context, email string) error {
	user, err := u.usersRepo.FindByEmail(ctx, email)
	if err != nil {
		if err == domain.ErrNotFound {
			return nil
		}
		return err
	}

	otp, err := generateOTP()
	if err != nil {
		return fmt.Errorf("failed to generate OTP: %w", err)
	}

	expiresAt := time.Now().Add(u.otpTTL)
	pr := &domain.PasswordReset{
		UserID:    user.ID,
		Email:     email,
		OTPCode:   otp,
		ExpiresAt: expiresAt,
	}
	if err := u.resetRepo.Create(ctx, pr); err != nil {
		return err
	}

	emailPkg.SendOTP(u.emailCfg, email, otp, expiresAt)

	return nil
}

func (u *PasswordResetUsecase) VerifyOTP(ctx context.Context, email, otpCode string) (resetToken string, err error) {
	latest, err := u.resetRepo.FindLatestByEmail(ctx, email)
	if err != nil {
		if err == domain.ErrNotFound {
			return "", domain.ErrOTPInvalid
		}
		return "", err
	}

	if latest.Used {
		return "", domain.ErrOTPAlreadyUsed
	}
	if time.Now().After(latest.ExpiresAt) {
		return "", domain.ErrOTPInvalid
	}
	if latest.OTPCode != otpCode {
		return "", domain.ErrOTPInvalid
	}

	if err := u.resetRepo.MarkUsed(ctx, latest.ID); err != nil {
		return "", err
	}

	token, err := jwtutil.IssueResetToken(u.jwtSecret, latest.UserID, latest.Email, u.resetTokenTTL)
	if err != nil {
		return "", err
	}
	return token, nil
}

func (u *PasswordResetUsecase) ResetPassword(ctx context.Context, resetToken, newPassword string) error {
	if len(newPassword) < 8 {
		return fmt.Errorf("password must be at least 8 characters")
	}

	claims, err := jwtutil.VerifyResetToken(u.jwtSecret, resetToken)
	if err != nil {
		return domain.ErrResetTokenInvalid
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	return u.usersRepo.UpdatePassword(ctx, claims.UserID, string(hash))
}

func (u *PasswordResetUsecase) GetOTPForEmail(ctx context.Context, email string) (string, error) {
	if !isDevMode() {
		return "", fmt.Errorf("only available in development mode")
	}
	latest, err := u.resetRepo.FindLatestByEmail(ctx, email)
	if err != nil {
		return "", err
	}
	return latest.OTPCode, nil
}
