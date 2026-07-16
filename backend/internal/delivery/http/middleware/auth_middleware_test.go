package middleware

import (
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/pkg/jwtutil"
)

const testSecret = "test-secret"

func newTestApp() *fiber.App {
	app := fiber.New()
	app.Get("/protected", RequireAuth(testSecret), func(c *fiber.Ctx) error {
		return c.SendString(UserID(c))
	})
	return app
}

func TestRequireAuth_MissingHeaderReturns401(t *testing.T) {
	app := newTestApp()
	req := httptest.NewRequest("GET", "/protected", nil)

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
}

func TestRequireAuth_MalformedHeaderReturns401(t *testing.T) {
	app := newTestApp()
	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "not-a-bearer-token")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
}

func TestRequireAuth_InvalidTokenReturns401(t *testing.T) {
	app := newTestApp()
	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "Bearer garbage-token")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
}

func TestRequireAuth_ExpiredTokenReturns401(t *testing.T) {
	app := newTestApp()
	token, err := jwtutil.Issue(testSecret, "user-1", "user1@example.com", "user", -time.Hour)
	if err != nil {
		t.Fatalf("Issue failed: %v", err)
	}

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != fiber.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.StatusCode)
	}
}

func TestRequireAuth_ValidTokenPassesThroughAndSetsUserID(t *testing.T) {
	app := newTestApp()
	token, err := jwtutil.Issue(testSecret, "user-42", "user42@example.com", "user", time.Hour)
	if err != nil {
		t.Fatalf("Issue failed: %v", err)
	}

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	if resp.StatusCode != fiber.StatusOK {
		t.Fatalf("expected 200, got %d", resp.StatusCode)
	}

	body := make([]byte, 32)
	n, _ := resp.Body.Read(body)
	if got := string(body[:n]); got != "user-42" {
		t.Fatalf("expected downstream handler to see userID user-42, got %q", got)
	}
}
