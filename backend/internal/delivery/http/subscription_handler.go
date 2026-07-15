package http

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type SubscriptionHandler struct {
	subs *usecase.SubscriptionUsecase
}

func NewSubscriptionHandler(subs *usecase.SubscriptionUsecase) *SubscriptionHandler {
	return &SubscriptionHandler{subs: subs}
}

type verifyRequest struct {
	ProductID     string `json:"productId"`
	PurchaseToken string `json:"purchaseToken"`
}

type subscriptionStatusResponse struct {
	Tier      string  `json:"tier"`
	IsActive  bool    `json:"isActive"`
	ExpiresAt *string `json:"expiresAt"`
}

func toStatusResponse(sub *domain.Subscription) subscriptionStatusResponse {
	resp := subscriptionStatusResponse{Tier: "free", IsActive: false}
	if sub == nil {
		return resp
	}
	if sub.IsActive(time.Now()) {
		resp.Tier = "pro"
		resp.IsActive = true
	}
	if sub.ExpiryTime != nil {
		s := sub.ExpiryTime.Format("2006-01-02T15:04:05Z07:00")
		resp.ExpiresAt = &s
	}
	return resp
}

func (h *SubscriptionHandler) Verify(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	var req verifyRequest
	if err := c.BodyParser(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid request body")
	}
	if req.ProductID == "" || req.PurchaseToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "productId and purchaseToken are required")
	}

	sub, err := h.subs.VerifyPurchase(c.Context(), userID, req.ProductID, req.PurchaseToken)
	if err != nil {
		if err == domain.ErrPurchaseTokenTaken {
			return fiber.NewError(fiber.StatusConflict, "purchase already registered to another account")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to verify purchase")
	}

	return c.JSON(toStatusResponse(sub))
}

func (h *SubscriptionHandler) Status(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	sub, err := h.subs.GetStatus(c.Context(), userID)
	if err != nil {
		if err == domain.ErrNotFound || errors.Is(err, domain.ErrSubscriptionNotPro) {
			return c.JSON(toStatusResponse(nil))
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to fetch subscription status")
	}

	return c.JSON(toStatusResponse(sub))
}
