package http

import (
	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type StoreProfileHandler struct {
	uc *usecase.StoreProfileUsecase
}

func NewStoreProfileHandler(uc *usecase.StoreProfileUsecase) *StoreProfileHandler {
	return &StoreProfileHandler{uc: uc}
}

type saveProfileRequest struct {
	OwnerName        string `json:"ownerName"`
	BusinessName     string `json:"businessName"`
	BusinessCategory string `json:"businessCategory"`
	Phone            string `json:"phone"`
	Address          string `json:"address"`
}

func (h *StoreProfileHandler) Save(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	var req saveProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}

	err := h.uc.Save(c.Context(), userID, &domain.StoreProfile{
		OwnerName:        req.OwnerName,
		BusinessName:     req.BusinessName,
		BusinessCategory: req.BusinessCategory,
		Phone:            req.Phone,
		Address:          req.Address,
	})
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to save profile")
	}

	return c.JSON(fiber.Map{"message": "profile saved"})
}

func (h *StoreProfileHandler) Get(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	profile, err := h.uc.Get(c.Context(), userID)
	if err != nil {
		if err == domain.ErrNotFound {
			return c.JSON(fiber.Map{"profile": nil})
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to get profile")
	}

	return c.JSON(fiber.Map{
		"profile": profile,
	})
}
