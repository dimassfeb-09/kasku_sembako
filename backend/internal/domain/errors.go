package domain

import (
	"errors"

	"github.com/gofiber/fiber/v2"
)

var (
	ErrNotFound            = errors.New("not found")
	ErrEmailTaken          = errors.New("email already taken")
	ErrInvalidCredentials  = errors.New("invalid email or password")
	ErrPurchaseTokenTaken  = errors.New("purchase token already used")
	ErrSubscriptionNotPro  = errors.New("user does not have an active pro subscription")
	ErrOTPInvalid          = errors.New("invalid or expired OTP")
	ErrOTPAlreadyUsed      = errors.New("OTP already used")
	ErrResetTokenInvalid   = errors.New("invalid or expired reset token")
	ErrRefreshTokenInvalid = errors.New("invalid, expired, or revoked refresh token")
)

// Error codes clients branch on instead of string-matching Message. Declared
// here rather than in the delivery layer so middleware can use them too: the
// http package imports middleware, so middleware importing http would cycle.
//
// Add a code only where a client must tell this failure apart from others at
// the same HTTP status; everything else is served by the status-derived
// defaults in the delivery layer.
const (
	CodeInternal             = "INTERNAL"
	CodeBadRequest           = "BAD_REQUEST"
	CodeUnauthorized         = "UNAUTHORIZED"
	CodeForbidden            = "FORBIDDEN"
	CodeNotFound             = "NOT_FOUND"
	CodeConflict             = "CONFLICT"
	CodeRateLimited          = "RATE_LIMITED"
	CodeValidationFailed     = "VALIDATION_FAILED"
	CodeEmailTaken           = "EMAIL_TAKEN"
	CodeInvalidCredentials   = "INVALID_CREDENTIALS"
	CodeTokenMissing         = "TOKEN_MISSING"
	CodeTokenInvalid         = "TOKEN_INVALID"
	CodeRefreshTokenInvalid  = "REFRESH_TOKEN_INVALID"
	CodeResetTokenInvalid    = "RESET_TOKEN_INVALID"
	CodeOTPInvalid           = "OTP_INVALID"
	CodeOTPAlreadyUsed       = "OTP_ALREADY_USED"
	CodePurchaseTokenTaken   = "PURCHASE_TOKEN_TAKEN"
	CodeProRequired          = "PRO_REQUIRED"
	CodeInvalidBackupPayload = "INVALID_BACKUP_PAYLOAD"
	CodeContentHashMismatch  = "CONTENT_HASH_MISMATCH"
)

// AppError carries a stable, machine-readable Code alongside the HTTP status.
// Clients switch on Code and render their own localized copy; Message is a
// developer/log detail and is not meant to be shown to end users verbatim
// (most are English, and the app's UI is Indonesian).
type AppError struct {
	Status  int
	Code    string
	Message string
}

func (e *AppError) Error() string { return e.Message }

// Unwrap yields an equivalent *fiber.Error so that an AppError still carries
// its status through anything that only understands Fiber's error type -
// including Fiber's own default handler. Without this, a router that hasn't
// wired JSONErrorHandler would render every AppError as a blank 500.
func (e *AppError) Unwrap() error {
	return &fiber.Error{Code: e.Status, Message: e.Message}
}

func NewAppError(status int, code, message string) *AppError {
	return &AppError{Status: status, Code: code, Message: message}
}
