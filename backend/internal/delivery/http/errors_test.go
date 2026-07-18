package http

import (
	"encoding/json"
	"errors"
	"io"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

// The clients parse every error body as a JSON object and switch on "code".
// Fiber's default handler sends text/plain, which silently disabled that path,
// so these assertions are the contract that keeps it working.
func TestJSONErrorHandler(t *testing.T) {
	tests := []struct {
		name        string
		handler     fiber.Handler
		wantStatus  int
		wantCode    string
		wantMessage string
	}{
		{
			name:        "AppError carries its explicit code",
			handler:     func(c *fiber.Ctx) error { return domain.NewAppError(fiber.StatusConflict, domain.CodeEmailTaken, "email already registered") },
			wantStatus:  fiber.StatusConflict,
			wantCode:    domain.CodeEmailTaken,
			wantMessage: "email already registered",
		},
		{
			name:        "plain fiber.NewError gets a status-derived code",
			handler:     func(c *fiber.Ctx) error { return fiber.NewError(fiber.StatusBadRequest, "invalid request body") },
			wantStatus:  fiber.StatusBadRequest,
			wantCode:    domain.CodeBadRequest,
			wantMessage: "invalid request body",
		},
		{
			name:        "402 defaults to PRO_REQUIRED",
			handler:     func(c *fiber.Ctx) error { return fiber.NewError(fiber.StatusPaymentRequired, "no active Pro subscription") },
			wantStatus:  fiber.StatusPaymentRequired,
			wantCode:    domain.CodeProRequired,
			wantMessage: "no active Pro subscription",
		},
		{
			name:        "unwrapped domain sentinel still gets its code",
			handler:     func(c *fiber.Ctx) error { return domain.ErrEmailTaken },
			wantStatus:  fiber.StatusConflict,
			wantCode:    domain.CodeEmailTaken,
			wantMessage: domain.ErrEmailTaken.Error(),
		},
		{
			name:        "unknown error never leaks internals",
			handler:     func(c *fiber.Ctx) error { return errors.New("pq: password authentication failed for user") },
			wantStatus:  fiber.StatusInternalServerError,
			wantCode:    domain.CodeInternal,
			wantMessage: "internal server error",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			app := fiber.New(fiber.Config{ErrorHandler: JSONErrorHandler})
			app.Get("/x", tt.handler)

			resp, err := app.Test(httptest.NewRequest("GET", "/x", nil))
			if err != nil {
				t.Fatal(err)
			}

			if resp.StatusCode != tt.wantStatus {
				t.Errorf("status: got %d, want %d", resp.StatusCode, tt.wantStatus)
			}
			if ct := resp.Header.Get("Content-Type"); ct != "application/json" {
				t.Errorf("content-type: got %q, want application/json", ct)
			}

			body, _ := io.ReadAll(resp.Body)
			var got struct {
				Message string `json:"message"`
				Code    string `json:"code"`
			}
			if err := json.Unmarshal(body, &got); err != nil {
				t.Fatalf("body is not JSON (%q): %v", string(body), err)
			}
			if got.Code != tt.wantCode {
				t.Errorf("code: got %q, want %q", got.Code, tt.wantCode)
			}
			if got.Message != tt.wantMessage {
				t.Errorf("message: got %q, want %q", got.Message, tt.wantMessage)
			}
		})
	}
}

// AppError must keep working under a router that never wired JSONErrorHandler:
// Unwrap() exposes an equivalent *fiber.Error, so the status survives.
func TestAppErrorDegradesToFiberError(t *testing.T) {
	app := fiber.New()
	app.Get("/x", func(c *fiber.Ctx) error {
		return domain.NewAppError(fiber.StatusUnauthorized, domain.CodeTokenInvalid, "invalid or expired token")
	})

	resp, err := app.Test(httptest.NewRequest("GET", "/x", nil))
	if err != nil {
		t.Fatal(err)
	}
	if resp.StatusCode != fiber.StatusUnauthorized {
		t.Errorf("status: got %d, want 401", resp.StatusCode)
	}
}
