package http

import (
	"net/mail"
	"time"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type AuthHandler struct {
	auth *usecase.AuthUsecase
}

func NewAuthHandler(auth *usecase.AuthUsecase) *AuthHandler {
	return &AuthHandler{auth: auth}
}

type registerRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
	WhatsApp string `json:"whatsapp"`
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type authResponse struct {
	Token        string  `json:"token"`
	RefreshToken string  `json:"refreshToken"`
	User         userDTO `json:"user"`
}

type userDTO struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Email     string `json:"email"`
	WhatsApp  string `json:"whatsapp"`
	Role      string `json:"role"`
	CreatedAt string `json:"createdAt"`
}

func toUserDTO(u *domain.User) userDTO {
	return userDTO{
		ID:        u.ID,
		Name:      u.Name,
		Email:     u.Email,
		WhatsApp:  u.WhatsApp,
		Role:      u.Role,
		CreatedAt: u.CreatedAt.Format(time.RFC3339),
	}
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var req registerRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.Name == "" {
		return domain.NewAppError(fiber.StatusBadRequest, domain.CodeValidationFailed, "name is required")
	}
	if req.Email == "" || len(req.Password) < 8 {
		return domain.NewAppError(fiber.StatusBadRequest, domain.CodeValidationFailed, "email is required and password must be at least 8 characters")
	}
	if _, err := mail.ParseAddress(req.Email); err != nil {
		return domain.NewAppError(fiber.StatusBadRequest, domain.CodeValidationFailed, "email is not a valid address")
	}
	if req.WhatsApp == "" {
		return domain.NewAppError(fiber.StatusBadRequest, domain.CodeValidationFailed, "whatsapp is required")
	}

	token, refreshToken, user, err := h.auth.Register(c.Context(), req.Name, req.Email, req.Password, req.WhatsApp)
	if err != nil {
		if err == domain.ErrEmailTaken {
			return domain.NewAppError(fiber.StatusConflict, domain.CodeEmailTaken, "email already registered")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to register")
	}

	return c.Status(fiber.StatusCreated).JSON(authResponse{
		Token:        token,
		RefreshToken: refreshToken,
		User:         toUserDTO(user),
	})
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req loginRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}

	token, refreshToken, user, err := h.auth.Login(c.Context(), req.Email, req.Password)
	if err != nil {
		if err == domain.ErrInvalidCredentials {
			return domain.NewAppError(fiber.StatusUnauthorized, domain.CodeInvalidCredentials, "invalid email or password")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to login")
	}

	return c.JSON(authResponse{
		Token:        token,
		RefreshToken: refreshToken,
		User:         toUserDTO(user),
	})
}

type refreshTokenRequest struct {
	RefreshToken string `json:"refreshToken"`
}

// Refresh exchanges a valid refresh token for a new access/refresh pair.
// Deliberately not behind requireAuth: the whole point is to work when the
// access token has already expired - only the refresh token is a credential
// here.
func (h *AuthHandler) Refresh(c *fiber.Ctx) error {
	var req refreshTokenRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.RefreshToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refreshToken is required")
	}

	token, refreshToken, err := h.auth.RefreshToken(c.Context(), req.RefreshToken)
	if err != nil {
		if err == domain.ErrRefreshTokenInvalid {
			return domain.NewAppError(fiber.StatusUnauthorized, domain.CodeRefreshTokenInvalid, "invalid or expired refresh token")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to refresh token")
	}

	return c.JSON(fiber.Map{"token": token, "refreshToken": refreshToken})
}

// Logout revokes the refresh token backing the caller's session. Also not
// behind requireAuth, for the same reason as Refresh - a client whose
// access token already expired must still be able to end its session.
func (h *AuthHandler) Logout(c *fiber.Ctx) error {
	var req refreshTokenRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.RefreshToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refreshToken is required")
	}

	if err := h.auth.Logout(c.Context(), req.RefreshToken); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to logout")
	}

	return c.JSON(fiber.Map{"message": "Berhasil keluar"})
}

func (h *AuthHandler) Me(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	user, err := h.auth.Me(c.Context(), userID)
	if err != nil {
		return fiber.NewError(fiber.StatusNotFound, "user not found")
	}
	return c.JSON(toUserDTO(user))
}

type changePasswordRequest struct {
	CurrentPassword string `json:"currentPassword"`
	NewPassword     string `json:"newPassword"`
}

func (h *AuthHandler) ChangePassword(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	var req changePasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}

	if len(req.NewPassword) < 8 {
		return domain.NewAppError(fiber.StatusBadRequest, domain.CodeValidationFailed, "password must be at least 8 characters")
	}

	if err := h.auth.ChangePassword(c.Context(), userID, req.CurrentPassword, req.NewPassword); err != nil {
		if err == domain.ErrInvalidCredentials {
			return domain.NewAppError(fiber.StatusUnauthorized, domain.CodeInvalidCredentials, "Current password is wrong")
		}
		// Anything else here is a storage/bcrypt failure - echoing err.Error()
		// would leak internals now that message is part of the wire contract.
		return fiber.NewError(fiber.StatusInternalServerError, "failed to change password")
	}

	return c.JSON(fiber.Map{"message": "Password berhasil diubah"})
}
