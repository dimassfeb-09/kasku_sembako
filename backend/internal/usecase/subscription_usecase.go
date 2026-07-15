package usecase

import (
	"context"
	"time"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/platform/playdeveloper"
)

// PlayClient is the subset of playdeveloper.Client this usecase depends on,
// defined here (consumer side) so tests can substitute a fake without
// hitting the real Play Developer API.
type PlayClient interface {
	GetSubscription(ctx context.Context, subscriptionID, purchaseToken string) (*playdeveloper.SubscriptionPurchase, error)
	AcknowledgeSubscription(ctx context.Context, subscriptionID, purchaseToken string) error
}

type SubscriptionUsecase struct {
	subscriptions domain.SubscriptionRepository
	playClient    PlayClient
	stalenessTTL  time.Duration
}

func NewSubscriptionUsecase(
	subscriptions domain.SubscriptionRepository,
	playClient PlayClient,
	stalenessTTL time.Duration,
) *SubscriptionUsecase {
	return &SubscriptionUsecase{
		subscriptions: subscriptions,
		playClient:    playClient,
		stalenessTTL:  stalenessTTL,
	}
}

// VerifyPurchase validates a purchase token against the Play Developer API,
// acknowledges it if this is the first time we've seen it (required within
// Google's 3-day window or the purchase auto-refunds), and persists the
// resulting subscription state.
func (u *SubscriptionUsecase) VerifyPurchase(ctx context.Context, userID, productID, purchaseToken string) (*domain.Subscription, error) {
	// A purchase token permanently belongs to whichever account verified it
	// first — reject attempts to re-register it under a different account.
	if existing, err := u.subscriptions.FindByPurchaseToken(ctx, purchaseToken); err == nil {
		if existing.UserID != userID {
			return nil, domain.ErrPurchaseTokenTaken
		}
	} else if err != domain.ErrNotFound {
		return nil, err
	}

	purchase, err := u.playClient.GetSubscription(ctx, productID, purchaseToken)
	if err != nil {
		return nil, err
	}

	if purchase.AcknowledgementState == 0 {
		if err := u.playClient.AcknowledgeSubscription(ctx, productID, purchaseToken); err != nil {
			return nil, err
		}
	}

	expiry := playdeveloper.ExpiryTime(purchase.ExpiryTimeMillis)
	status := deriveStatus(purchase, expiry)

	sub := &domain.Subscription{
		UserID:        userID,
		ProductID:     productID,
		PurchaseToken: purchaseToken,
		Status:        status,
		ExpiryTime:    &expiry,
		Acknowledged:  true,
	}
	if err := u.subscriptions.Upsert(ctx, sub); err != nil {
		return nil, err
	}
	return sub, nil
}

// GetStatus returns the cached DB-derived status, only re-verifying live
// against Play if the cache is stale — avoids hammering Play's API quota
// on every app open (see plan B.4).
func (u *SubscriptionUsecase) GetStatus(ctx context.Context, userID string) (*domain.Subscription, error) {
	sub, err := u.subscriptions.FindLatestByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	if sub.StatusStaleness(time.Now()) < u.stalenessTTL {
		return sub, nil
	}

	purchase, err := u.playClient.GetSubscription(ctx, sub.ProductID, sub.PurchaseToken)
	if err != nil {
		// Play API unreachable or errored: serve the stale cache rather than
		// failing the request outright, so a transient Play outage doesn't
		// lock out an actually-still-paying subscriber.
		return sub, nil
	}

	expiry := playdeveloper.ExpiryTime(purchase.ExpiryTimeMillis)
	sub.Status = deriveStatus(purchase, expiry)
	sub.ExpiryTime = &expiry
	if err := u.subscriptions.Upsert(ctx, sub); err != nil {
		return nil, err
	}
	return sub, nil
}

func deriveStatus(p *playdeveloper.SubscriptionPurchase, expiry time.Time) domain.SubscriptionStatus {
	if expiry.Before(time.Now()) {
		if p.AutoRenewing {
			// Expired but still auto-renewing: Play is retrying a failed
			// payment (grace period) rather than the subscriber cancelling.
			return domain.SubscriptionStatusGracePeriod
		}
		return domain.SubscriptionStatusExpired
	}
	if p.PaymentState != nil && *p.PaymentState == 0 {
		return domain.SubscriptionStatusOnHold
	}
	return domain.SubscriptionStatusActive
}
