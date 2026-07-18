package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/config"
	appmiddleware "github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http/middleware"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/repository/postgres"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

type Dependencies struct {
	Config           *config.Config
	AuthUsecase      *usecase.AuthUsecase
	SubscriptionUC   *usecase.SubscriptionUsecase
	BackupUC         *usecase.BackupUsecase
	StoreProfileUC   *usecase.StoreProfileUsecase
	PasswordResetUC  *usecase.PasswordResetUsecase
	UserRepo         *postgres.UserRepository
	SubscriptionRepo *postgres.SubscriptionRepository
	BackupRepo       *postgres.BackupRepository
	StoreProfileRepo *postgres.StoreProfileRepository
}

func NewRouter(deps Dependencies) *fiber.App {
	fiberConfig := fiber.Config{
		BodyLimit:    int(deps.Config.BackupMaxSizeBytes),
		ErrorHandler: JSONErrorHandler,
	}
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
	storeProfileHandler := NewStoreProfileHandler(deps.StoreProfileUC)
	passwordResetHandler := NewPasswordResetHandler(deps.PasswordResetUC)
	adminHandler := NewAdminHandler(deps.UserRepo, deps.SubscriptionRepo, deps.BackupRepo, deps.StoreProfileRepo)

	requireAuth := appmiddleware.RequireAuth(deps.Config.JWTSecret)
	requirePro := appmiddleware.RequirePro(deps.SubscriptionUC)
	requireAdmin := appmiddleware.RequireAdmin()

	// LimitReached is required: the limiter writes its 429 directly rather
	// than returning an error, so without this it bypasses JSONErrorHandler
	// and replies text/plain - the exact contract break this router fixes.
	loginLimiter := limiter.New(limiter.Config{
		Max:        10,
		Expiration: 1 * time.Minute,
		LimitReached: func(c *fiber.Ctx) error {
			return domain.NewAppError(
				fiber.StatusTooManyRequests,
				domain.CodeRateLimited,
				"too many attempts, please try again later",
			)
		},
	})

	app.Get("/healthz", func(c *fiber.Ctx) error {
		return c.SendString("ok")
	})

	auth := app.Group("/auth")
	auth.Post("/register", loginLimiter, authHandler.Register)
	auth.Post("/login", loginLimiter, authHandler.Login)
	auth.Post("/refresh", loginLimiter, authHandler.Refresh)
	auth.Post("/logout", loginLimiter, authHandler.Logout)
	auth.Get("/me", requireAuth, authHandler.Me)
	auth.Post("/change-password", requireAuth, authHandler.ChangePassword)
	auth.Post("/forgot-password", loginLimiter, passwordResetHandler.RequestOTP)
	auth.Post("/verify-otp", loginLimiter, passwordResetHandler.VerifyOTP)
	auth.Post("/reset-password", loginLimiter, passwordResetHandler.ResetPassword)

	subscriptions := app.Group("/subscriptions", requireAuth)
	subscriptions.Post("/verify", subscriptionHandler.Verify)
	subscriptions.Get("/status", subscriptionHandler.Status)

	storeProfile := app.Group("/api/store-profile", requireAuth)
	storeProfile.Put("", storeProfileHandler.Save)
	storeProfile.Get("", storeProfileHandler.Get)

	backups := app.Group("/backups", requireAuth, requirePro)
	backups.Post("/", backupHandler.Upload)
	backups.Get("/", backupHandler.List)
	backups.Get("/latest", backupHandler.GetLatest)
	backups.Get("/:id", backupHandler.GetByID)
	backups.Delete("/:id", backupHandler.Delete)

	admin := app.Group("/api/admin", requireAuth, requireAdmin)
	admin.Get("/stats", adminHandler.Stats)
	admin.Get("/users", adminHandler.ListUsers)
	admin.Get("/subscriptions", adminHandler.ListSubscriptions)
	admin.Get("/subscriptions/summary", adminHandler.SubscriptionSummary)
	admin.Get("/stores", adminHandler.ListStores)

	return app
}
