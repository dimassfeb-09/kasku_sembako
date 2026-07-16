package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

const UserIDLocalsKey = "userID"

// RequireAuth verifies the Authorization: Bearer <jwt> header and stores
// the authenticated user id and claims in Fiber locals for downstream
// handlers.
func RequireAuth(jwtSecret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		header := c.Get("Authorization")
		if header == "" || !strings.HasPrefix(header, "Bearer ") {
			return fiber.NewError(fiber.StatusUnauthorized, "missing bearer token")
		}
		tokenString := strings.TrimPrefix(header, "Bearer ")

		claims, err := jwtutil.Verify(jwtSecret, tokenString)
		if err != nil {
			return fiber.NewError(fiber.StatusUnauthorized, "invalid or expired token")
		}

		c.Locals(UserIDLocalsKey, claims.UserID)
		c.Locals(jwtutil.ClaimsLocalsKey, claims)
		return c.Next()
	}
}

func UserID(c *fiber.Ctx) string {
	id, _ := c.Locals(UserIDLocalsKey).(string)
	return id
}

func Claims(c *fiber.Ctx) *jwtutil.Claims {
	cl, _ := c.Locals(jwtutil.ClaimsLocalsKey).(*jwtutil.Claims)
	return cl
}
