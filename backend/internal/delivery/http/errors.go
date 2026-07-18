package http

import (
	"errors"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

// defaultCodeForStatus keeps the ~60 plain fiber.NewError callsites working
// without a per-callsite code: they get a coarse code derived from status.
// 402 maps to PRO_REQUIRED because RequirePro is the only thing returning it.
func defaultCodeForStatus(status int) string {
	switch status {
	case fiber.StatusBadRequest:
		return domain.CodeBadRequest
	case fiber.StatusUnauthorized:
		return domain.CodeUnauthorized
	case fiber.StatusPaymentRequired:
		return domain.CodeProRequired
	case fiber.StatusForbidden:
		return domain.CodeForbidden
	case fiber.StatusNotFound:
		return domain.CodeNotFound
	case fiber.StatusConflict:
		return domain.CodeConflict
	case fiber.StatusTooManyRequests:
		return domain.CodeRateLimited
	default:
		return domain.CodeInternal
	}
}

// sentinelCodes is defence in depth for domain errors that reach the handler
// unwrapped (e.g. a handler that returns err.Error() verbatim). Handlers
// normally map these themselves; this stops an unmapped one from degrading to
// a bare INTERNAL.
var sentinelCodes = map[error]struct {
	status int
	code   string
}{
	domain.ErrEmailTaken:          {fiber.StatusConflict, domain.CodeEmailTaken},
	domain.ErrInvalidCredentials:  {fiber.StatusUnauthorized, domain.CodeInvalidCredentials},
	domain.ErrRefreshTokenInvalid: {fiber.StatusUnauthorized, domain.CodeRefreshTokenInvalid},
	domain.ErrResetTokenInvalid:   {fiber.StatusUnauthorized, domain.CodeResetTokenInvalid},
	domain.ErrOTPInvalid:          {fiber.StatusBadRequest, domain.CodeOTPInvalid},
	domain.ErrOTPAlreadyUsed:      {fiber.StatusBadRequest, domain.CodeOTPAlreadyUsed},
	domain.ErrPurchaseTokenTaken:  {fiber.StatusConflict, domain.CodePurchaseTokenTaken},
	domain.ErrSubscriptionNotPro:  {fiber.StatusPaymentRequired, domain.CodeProRequired},
	domain.ErrNotFound:            {fiber.StatusNotFound, domain.CodeNotFound},
}

// JSONErrorHandler renders every handler error as JSON. Fiber's default
// handler sends text/plain, which silently broke the clients: they parse the
// body as a JSON object, so the branch reading the server's message was dead
// and every 4xx surfaced Dio's generic English text instead. This is the
// single choke point that makes 4xx/5xx match the JSON shape 2xx already uses.
//
// Message is a developer/log detail — most are English while the app UI is
// Indonesian, so clients switch on Code and render their own copy.
func JSONErrorHandler(c *fiber.Ctx, err error) error {
	var appErr *domain.AppError
	if errors.As(err, &appErr) {
		return c.Status(appErr.Status).JSON(fiber.Map{
			"message": appErr.Message,
			"code":    appErr.Code,
		})
	}

	for sentinel, m := range sentinelCodes {
		if errors.Is(err, sentinel) {
			return c.Status(m.status).JSON(fiber.Map{
				"message": sentinel.Error(),
				"code":    m.code,
			})
		}
	}

	var fiberErr *fiber.Error
	if errors.As(err, &fiberErr) {
		return c.Status(fiberErr.Code).JSON(fiber.Map{
			"message": fiberErr.Message,
			"code":    defaultCodeForStatus(fiberErr.Code),
		})
	}

	// Unknown error (e.g. a recovered panic): never leak internals.
	return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
		"message": "internal server error",
		"code":    domain.CodeInternal,
	})
}
