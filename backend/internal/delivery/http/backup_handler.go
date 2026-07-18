package http

import (
	"errors"

	"github.com/gofiber/fiber/v2"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

// X-Content-Encoding (not the standard Content-Encoding) marks whether the
// body is gzip-compressed. A custom header name is used deliberately: the
// standard Content-Encoding header is transport-level metadata that HTTP
// clients/proxies may transparently decompress on their own, which would
// silently break this app-level compression contract. Idempotency-Key
// doubles as the client-declared content hash, checked against the
// server-computed hash in the usecase.
const (
	headerContentEncoding = "X-Content-Encoding"
	headerIdempotencyKey  = "Idempotency-Key"
	headerDeviceID        = "X-Device-Id"
)

type BackupHandler struct {
	backups *usecase.BackupUsecase
}

func NewBackupHandler(backups *usecase.BackupUsecase) *BackupHandler {
	return &BackupHandler{backups: backups}
}

// Upload reads the raw request body rather than using Fiber's BodyParser
// (a typed-struct-binding API): the whole point of storing/forwarding the
// payload verbatim is byte-for-byte passthrough with no intermediate struct.
func (h *BackupHandler) Upload(c *fiber.Ctx) error {
	userID := middleware.UserID(c)

	body := c.Body()
	if len(body) == 0 {
		return fiber.NewError(fiber.StatusBadRequest, "request body is empty")
	}

	in := usecase.UploadInput{
		Payload:         body,
		ContentEncoding: c.Get(headerContentEncoding),
		ContentHash:     c.Get(headerIdempotencyKey),
		DeviceID:        c.Get(headerDeviceID),
	}

	backup, err := h.backups.Upload(c.Context(), userID, in)
	if err != nil {
		// Only validation/hash-mismatch errors are safe to echo back
		// verbatim - anything else (e.g. a storage-layer failure) could
		// leak internal details.
		if errors.Is(err, usecase.ErrInvalidBackupPayload) {
			return domain.NewAppError(fiber.StatusBadRequest, domain.CodeInvalidBackupPayload, err.Error())
		}
		if errors.Is(err, usecase.ErrContentHashMismatch) {
			return domain.NewAppError(fiber.StatusBadRequest, domain.CodeContentHashMismatch, err.Error())
		}
		return fiber.NewError(fiber.StatusInternalServerError, "failed to upload backup")
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
			"deviceId":  s.DeviceID,
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
	return sendBackupPayload(c, backup)
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
	return sendBackupPayload(c, backup)
}

// sendBackupPayload forwards the stored bytes as-is (still compressed, if
// they were stored compressed) - the client is responsible for decoding
// using the X-Content-Encoding header, keeping the download itself as
// bandwidth-cheap as the original upload.
func sendBackupPayload(c *fiber.Ctx, backup *domain.Backup) error {
	c.Set(fiber.HeaderContentType, "application/octet-stream")
	c.Set(headerContentEncoding, backup.ContentEncoding)
	c.Set(headerIdempotencyKey, backup.ContentHash)
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
