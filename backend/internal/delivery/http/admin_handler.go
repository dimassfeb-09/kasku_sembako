package http

import (
	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/repository/postgres"
)

type AdminHandler struct {
	userRepo         *postgres.UserRepository
	subscriptionRepo *postgres.SubscriptionRepository
	backupRepo       *postgres.BackupRepository
	storeProfileRepo *postgres.StoreProfileRepository
}

func NewAdminHandler(
	userRepo *postgres.UserRepository,
	subscriptionRepo *postgres.SubscriptionRepository,
	backupRepo *postgres.BackupRepository,
	storeProfileRepo *postgres.StoreProfileRepository,
) *AdminHandler {
	return &AdminHandler{
		userRepo:         userRepo,
		subscriptionRepo: subscriptionRepo,
		backupRepo:       backupRepo,
		storeProfileRepo: storeProfileRepo,
	}
}

type statsResponse struct {
	TotalUsers            int            `json:"totalUsers"`
	TotalActiveSubs       int            `json:"totalActiveSubscriptions"`
	TotalBackups          int            `json:"totalBackups"`
	TotalStores           int            `json:"totalStores"`
	SubscriptionsByStatus map[string]int `json:"subscriptionsByStatus"`
}

func (h *AdminHandler) Stats(c *fiber.Ctx) error {
	ctx := c.Context()

	totalUsers, err := h.userRepo.Count(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count users")
	}

	activeSubs, err := h.subscriptionRepo.CountActive(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count active subscriptions")
	}

	totalBackups, err := h.backupRepo.CountAll(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count backups")
	}

	totalStores, err := h.storeProfileRepo.CountAll(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count stores")
	}

	subsByStatus, err := h.subscriptionRepo.CountByStatus(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count subscriptions by status")
	}

	return c.JSON(statsResponse{
		TotalUsers:            totalUsers,
		TotalActiveSubs:       activeSubs,
		TotalBackups:          totalBackups,
		TotalStores:           totalStores,
		SubscriptionsByStatus: subsByStatus,
	})
}

type userRow struct {
	ID                 string `json:"id"`
	Name               string `json:"name"`
	Email              string `json:"email"`
	WhatsApp           string `json:"whatsapp"`
	Role               string `json:"role"`
	CreatedAt          string `json:"createdAt"`
	SubscriptionStatus string `json:"subscriptionStatus"`
	SubscriptionExpiry string `json:"subscriptionExpiry,omitempty"`
	BackupCount        int    `json:"backupCount"`
}

func (h *AdminHandler) ListUsers(c *fiber.Ctx) error {
	ctx := c.Context()

	users, err := h.userRepo.ListAll(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to list users")
	}

	rows := make([]userRow, 0, len(users))
	for _, u := range users {
		row := userRow{
			ID:        u.ID,
			Name:      u.Name,
			Email:     u.Email,
			WhatsApp:  u.WhatsApp,
			Role:      u.Role,
			CreatedAt: u.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}

		if sub, err := h.subscriptionRepo.FindLatestByUserID(ctx, u.ID); err == nil {
			row.SubscriptionStatus = string(sub.Status)
			if sub.ExpiryTime != nil {
				row.SubscriptionExpiry = sub.ExpiryTime.Format("2006-01-02T15:04:05Z07:00")
			}
		}

		if summaries, err := h.backupRepo.ListByUserID(ctx, u.ID); err == nil {
			row.BackupCount = len(summaries)
		}

		rows = append(rows, row)
	}

	return c.JSON(rows)
}

type subscriptionRow struct {
	ID           string  `json:"id"`
	UserID       string  `json:"userId"`
	ProductID    string  `json:"productId"`
	Status       string  `json:"status"`
	ExpiryTime   *string `json:"expiryTime,omitempty"`
	Acknowledged bool    `json:"acknowledged"`
	CreatedAt    string  `json:"createdAt"`
	UpdatedAt    string  `json:"updatedAt"`
}

func (h *AdminHandler) ListSubscriptions(c *fiber.Ctx) error {
	ctx := c.Context()

	subs, err := h.subscriptionRepo.ListAll(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to list subscriptions")
	}

	rows := make([]subscriptionRow, 0, len(subs))
	for _, s := range subs {
		row := subscriptionRow{
			ID:           s.ID,
			UserID:       s.UserID,
			ProductID:    s.ProductID,
			Status:       string(s.Status),
			Acknowledged: s.Acknowledged,
			CreatedAt:    s.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt:    s.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
		if s.ExpiryTime != nil {
			t := s.ExpiryTime.Format("2006-01-02T15:04:05Z07:00")
			row.ExpiryTime = &t
		}
		rows = append(rows, row)
	}

	return c.JSON(rows)
}

type subscriptionSummaryRow struct {
	Status string `json:"status"`
	Count  int    `json:"count"`
}

func (h *AdminHandler) SubscriptionSummary(c *fiber.Ctx) error {
	ctx := c.Context()

	byStatus, err := h.subscriptionRepo.CountByStatus(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to count subscriptions")
	}

	rows := make([]subscriptionSummaryRow, 0, len(byStatus))
	for status, count := range byStatus {
		rows = append(rows, subscriptionSummaryRow{Status: status, Count: count})
	}

	return c.JSON(rows)
}

type storeRow struct {
	ID               string `json:"id"`
	UserID           string `json:"userId"`
	OwnerName        string `json:"ownerName"`
	BusinessName     string `json:"businessName"`
	BusinessCategory string `json:"businessCategory"`
	Phone            string `json:"phone"`
	Address          string `json:"address"`
	BusinessEmail    string `json:"businessEmail"`
	CreatedAt        string `json:"createdAt"`
	UpdatedAt        string `json:"updatedAt"`
}

func (h *AdminHandler) ListStores(c *fiber.Ctx) error {
	ctx := c.Context()

	profiles, err := h.storeProfileRepo.ListAll(ctx)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to list stores")
	}

	rows := make([]storeRow, 0, len(profiles))
	for _, p := range profiles {
		rows = append(rows, storeRow{
			ID:               p.ID,
			UserID:           p.UserID,
			OwnerName:        p.OwnerName,
			BusinessName:     p.BusinessName,
			BusinessCategory: p.BusinessCategory,
			Phone:            p.Phone,
			Address:          p.Address,
			BusinessEmail:    p.BusinessEmail,
			CreatedAt:        p.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt:        p.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	return c.JSON(rows)
}
