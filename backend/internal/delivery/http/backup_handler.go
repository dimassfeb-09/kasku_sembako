package http

import (
	"encoding/json"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type BackupHandler struct {
	backups *usecase.BackupUsecase
}

func NewBackupHandler(backups *usecase.BackupUsecase) *BackupHandler {
	return &BackupHandler{backups: backups}
}

// Upload reads the raw request body rather than using Fiber's BodyParser
// (a typed-struct-binding API): the whole point of storing/forwarding
// json.RawMessage is byte-for-byte passthrough with no intermediate struct.
func (h *BackupHandler) Upload(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	body := c.Body()
	if len(body) == 0 {
		return fiber.NewError(fiber.StatusBadRequest, "request body is empty")
	}

	backup, err := h.backups.Upload(c.Context(), userID, json.RawMessage(body))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"id":        backup.ID,
		"createdAt": backup.CreatedAt,
	})
}

func (h *BackupHandler) List(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	summaries, err := h.backups.List(c.Context(), userID)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "failed to list backups")
	}

	resp := make([]fiber.Map, 0, len(summaries))
	for _, s := range summaries {
		resp = append(resp, fiber.Map{
			"id":        s.ID,
			"createdAt": s.CreatedAt,
			"sizeBytes": s.SizeBytes,
		})
	}
	return c.JSON(resp)
}

func (h *BackupHandler) GetLatest(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	backup, err := h.backups.GetLatest(c.Context(), userID)
	if err != nil {
		if err == domain.ErrNotFound {
			return fiber.NewError(fiber.StatusNotFound, "no backup found")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to fetch backup")
	}

	c.Set(fiber.HeaderContentType, "application/json")
	return c.Send(backup.Payload)
}

func (h *BackupHandler) GetByID(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	id := c.Params("id")

	backup, err := h.backups.GetByID(c.Context(), userID, id)
	if err != nil {
		if err == domain.ErrNotFound {
			return fiber.NewError(fiber.StatusNotFound, "backup not found")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to fetch backup")
	}

	c.Set(fiber.HeaderContentType, "application/json")
	return c.Send(backup.Payload)
}

func (h *BackupHandler) Delete(c *fiber.Ctx) error {
	userID := middleware.UserID(c)
	id := c.Params("id")

	if err := h.backups.Delete(c.Context(), userID, id); err != nil {
		if err == domain.ErrNotFound {
			return fiber.NewError(fiber.StatusNotFound, "backup not found")
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to delete backup")
	}

	return c.SendStatus(fiber.StatusNoContent)
}
