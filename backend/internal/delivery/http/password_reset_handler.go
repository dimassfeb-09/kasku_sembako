package http

import (
	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type PasswordResetHandler struct {
	uc *usecase.PasswordResetUsecase
}

func NewPasswordResetHandler(uc *usecase.PasswordResetUsecase) *PasswordResetHandler {
	return &PasswordResetHandler{uc: uc}
}

func (h *PasswordResetHandler) RequestOTP(c *fiber.Ctx) error {
	var req struct {
		Email string `json:"email"`
	}
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.Email == "" {
		return fiber.NewError(fiber.StatusBadRequest, "email is required")
	}

	if err := h.uc.RequestOTP(c.Context(), req.Email); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to send OTP")
	}

	resp := fiber.Map{"message": "Kode OTP telah dikirim ke email Anda jika terdaftar"}

	otp, err := h.uc.GetOTPForEmail(c.Context(), req.Email)
	if err == nil && otp != "" {
		resp["otpCode"] = otp
	}

	return c.Status(fiber.StatusCreated).JSON(resp)
}

type verifyOTPRequest struct {
	Email   string `json:"email"`
	OTPCode string `json:"otpCode"`
}

func (h *PasswordResetHandler) VerifyOTP(c *fiber.Ctx) error {
	var req verifyOTPRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.Email == "" || req.OTPCode == "" {
		return fiber.NewError(fiber.StatusBadRequest, "email and otpCode are required")
	}

	token, err := h.uc.VerifyOTP(c.Context(), req.Email, req.OTPCode)
	if err != nil {
		switch err {
		case domain.ErrOTPInvalid:
			return domain.NewAppError(fiber.StatusBadRequest, domain.CodeOTPInvalid, "Kode OTP tidak valid atau kadaluwarsa")
		case domain.ErrOTPAlreadyUsed:
			return domain.NewAppError(fiber.StatusBadRequest, domain.CodeOTPAlreadyUsed, "Kode OTP sudah digunakan")
		default:
			return fiber.NewError(fiber.StatusInternalServerError, "failed to verify OTP")
		}
	}

	return c.JSON(fiber.Map{"resetToken": token})
}

type resetPasswordRequest struct {
	ResetToken  string `json:"resetToken"`
	NewPassword string `json:"newPassword"`
}

func (h *PasswordResetHandler) ResetPassword(c *fiber.Ctx) error {
	var req resetPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.ResetToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "resetToken is required")
	}
	if len(req.NewPassword) < 8 {
		return fiber.NewError(fiber.StatusBadRequest, "password must be at least 8 characters")
	}

	if err := h.uc.ResetPassword(c.Context(), req.ResetToken, req.NewPassword); err != nil {
		if err == domain.ErrResetTokenInvalid {
			return domain.NewAppError(fiber.StatusUnauthorized, domain.CodeResetTokenInvalid, "Token reset tidak valid atau kadaluwarsa")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to reset password")
	}

	return c.JSON(fiber.Map{"message": "Password berhasil diubah"})
}
