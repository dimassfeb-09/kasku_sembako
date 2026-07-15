package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/platform/playdeveloper"
)

// staleFallbackCeiling bounds how long GetStatus will keep serving a cached
// subscription row when live re-verification against Play keeps failing.
// Without this, a subscription that's actually lapsed (or a sustained Play
// outage/misconfiguration) would grant Pro access forever, since every
// failed re-verification attempt would just re-trigger the same fallback
// indefinitely. This is independent of and larger than the normal
// stalenessTTL (which governs how often re-verification is even attempted)
// — it's a hard ceiling on the fallback itself, not the retry cadence.
const staleFallbackCeiling = 7 * 24 * time.Hour

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
		// lock out an actually-still-paying subscriber — but only up to
		// staleFallbackCeiling. Beyond that, fail closed instead of granting
		// indefinite access on a status we haven't been able to confirm in
		// over a week.
		if sub.StatusStaleness(time.Now()) > staleFallbackCeiling {
			return nil, fmt.Errorf("%w: could not re-verify and cached status is too stale to trust: %v", domain.ErrSubscriptionNotPro, err)
		}
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
