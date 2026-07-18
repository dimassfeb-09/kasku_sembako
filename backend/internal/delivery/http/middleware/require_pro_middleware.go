package middleware

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

// RequirePro re-derives Pro entitlement server-side before allowing a
// request through. This is the actual enforcement point for backup
// upload/download — the client-side greyed-out button (see backup_page.dart
// plan) is UX only, since a modified client could otherwise call these
// endpoints directly. Must run after RequireAuth.
func RequirePro(subs *usecase.SubscriptionUsecase) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userID := UserID(c)

		sub, err := subs.GetStatus(c.Context(), userID)
		if err != nil {
			if err == domain.ErrNotFound || errors.Is(err, domain.ErrSubscriptionNotPro) {
				return domain.NewAppError(fiber.StatusPaymentRequired, domain.CodeProRequired, "no active Pro subscription")
			}
			return fiber.NewError(fiber.StatusInternalServerError, "failed to verify subscription status")
		}

		if !sub.IsActive(time.Now()) {
			return domain.NewAppError(fiber.StatusPaymentRequired, domain.CodeProRequired, "no active Pro subscription")
		}

		return c.Next()
	}
}
