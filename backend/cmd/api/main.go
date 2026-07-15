package main

import (
	"context"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/config"
	httpDelivery "github.com/dimassfeb-09/kasku_sembako/backend/internal/delivery/http"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/platform/playdeveloper"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/repository/postgres"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/usecase"
)

func main() {
	ctx := context.Background()

	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config error: %v", err)
	}

	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("failed to connect to postgres: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("postgres ping failed: %v", err)
	}

	userRepo := postgres.NewUserRepository(pool)
	subscriptionRepo := postgres.NewSubscriptionRepository(pool)
	backupRepo := postgres.NewBackupRepository(pool)

	var playClient *playdeveloper.Client
	if cfg.GoogleServiceAccountJSONPath != "" && cfg.GooglePackageName != "" {
		playClient, err = playdeveloper.New(ctx, cfg.GoogleServiceAccountJSONPath, cfg.GooglePackageName)
		if err != nil {
			log.Fatalf("failed to init Play Developer API client: %v", err)
		}
	} else {
		log.Println("warning: GOOGLE_APPLICATION_CREDENTIALS/GOOGLE_PLAY_PACKAGE_NAME not set — /subscriptions endpoints will fail until configured")
	}

	authUC := usecase.NewAuthUsecase(userRepo, cfg.JWTSecret, cfg.JWTTTL)
	subscriptionUC := usecase.NewSubscriptionUsecase(subscriptionRepo, playClient, cfg.SubscriptionStalenessTTL)
	backupUC := usecase.NewBackupUsecase(backupRepo, cfg.BackupRetentionCount)

	app := httpDelivery.NewRouter(httpDelivery.Dependencies{
		Config:         cfg,
		AuthUsecase:    authUC,
		SubscriptionUC: subscriptionUC,
		BackupUC:       backupUC,
	})

	log.Printf("listening on :%s", cfg.Port)
	if err := app.Listen(":" + cfg.Port); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
