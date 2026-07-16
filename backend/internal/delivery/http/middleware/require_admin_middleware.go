package middleware

import (
	"github.com/gofiber/fiber/v2"
)

// RequireAdmin checks that the authenticated user has the "admin" role.
// Must run after RequireAuth (reads claims set by it).
func RequireAdmin() fiber.Handler {
	return func(c *fiber.Ctx) error {
		claims := Claims(c)
		if claims == nil || claims.Role != "admin" {
			return fiber.NewError(fiber.StatusForbidden, "admin access required")
		}
		return c.Next()
	}
}
