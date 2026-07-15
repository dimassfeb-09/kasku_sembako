package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/config"
	appmiddleware "github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type Dependencies struct {
	Config         *config.Config
	AuthUsecase    *usecase.AuthUsecase
	SubscriptionUC *usecase.SubscriptionUsecase
	BackupUC       *usecase.BackupUsecase
}

func NewRouter(deps Dependencies) *fiber.App {
	fiberConfig := fiber.Config{
		BodyLimit: int(deps.Config.BackupMaxSizeBytes),
	}
	// Only trust X-Forwarded-For from an explicitly configured reverse
	// proxy. Left unset (the default), c.IP()/the rate limiter's key
	// function fall back to the direct TCP peer - safe, but means every
	// request behind an unconfigured reverse proxy collapses onto the
	// proxy's own IP for rate-limiting purposes. Set TRUSTED_PROXIES once
	// this is actually deployed behind one.
	if len(deps.Config.TrustedProxies) > 0 {
		fiberConfig.EnableTrustedProxyCheck = true
		fiberConfig.TrustedProxies = deps.Config.TrustedProxies
		fiberConfig.ProxyHeader = fiber.HeaderXForwardedFor
	}
	app := fiber.New(fiberConfig)

	app.Use(recover.New())
	app.Use(logger.New())

	authHandler := NewAuthHandler(deps.AuthUsecase)
	subscriptionHandler := NewSubscriptionHandler(deps.SubscriptionUC)
	backupHandler := NewBackupHandler(deps.BackupUC)

	requireAuth := appmiddleware.RequireAuth(deps.Config.JWTSecret)
	requirePro := appmiddleware.RequirePro(deps.SubscriptionUC)

	loginLimiter := limiter.New(limiter.Config{
		Max:        10,
		Expiration: 1 * time.Minute,
	})

	app.Get("/healthz", func(c *fiber.Ctx) error {
		return c.SendString("ok")
	})

	auth := app.Group("/auth")
	auth.Post("/register", loginLimiter, authHandler.Register)
	auth.Post("/login", loginLimiter, authHandler.Login)
	auth.Get("/me", requireAuth, authHandler.Me)

	subscriptions := app.Group("/subscriptions", requireAuth)
	subscriptions.Post("/verify", subscriptionHandler.Verify)
	subscriptions.Get("/status", subscriptionHandler.Status)

	backups := app.Group("/backups", requireAuth, requirePro)
	backups.Post("/", backupHandler.Upload)
	backups.Get("/", backupHandler.List)
	backups.Get("/latest", backupHandler.GetLatest)
	backups.Get("/:id", backupHandler.GetByID)
	backups.Delete("/:id", backupHandler.Delete)

	return app
}
