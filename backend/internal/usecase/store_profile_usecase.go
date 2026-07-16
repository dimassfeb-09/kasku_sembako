package usecase

import (
	"context"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
)

type StoreProfileUsecase struct {
	profiles domain.StoreProfileRepository
}

func NewStoreProfileUsecase(profiles domain.StoreProfileRepository) *StoreProfileUsecase {
	return &StoreProfileUsecase{profiles: profiles}
}

func (u *StoreProfileUsecase) Save(ctx context.Context, userID string, p *domain.StoreProfile) error {
	p.UserID = userID
	return u.profiles.Upsert(ctx, p)
}

func (u *StoreProfileUsecase) Get(ctx context.Context, userID string) (*domain.StoreProfile, error) {
	return u.profiles.FindByUserID(ctx, userID)
}
