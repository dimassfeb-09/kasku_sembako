package usecase

import (
	"context"
	"testing"
	"time"

	"github.com/dimassfeb-09/kasku_sembako/backend/internal/domain"
	"github.com/dimassfeb-09/kasku_sembako/backend/internal/platform/playdeveloper"
)

// fakePlayClient records how many times Acknowledge was called per token,
// so the "acknowledge exactly once" invariant can be asserted directly.
type fakePlayClient struct {
	purchase         *playdeveloper.SubscriptionPurchase
	acknowledgeCalls map[string]int
}

func newFakePlayClient(p *playdeveloper.SubscriptionPurchase) *fakePlayClient {
	return &fakePlayClient{purchase: p, acknowledgeCalls: map[string]int{}}
}

func (f *fakePlayClient) GetSubscription(ctx context.Context, subscriptionID, purchaseToken string) (*playdeveloper.SubscriptionPurchase, error) {
	return f.purchase, nil
}

func (f *fakePlayClient) AcknowledgeSubscription(ctx context.Context, subscriptionID, purchaseToken string) error {
	f.acknowledgeCalls[purchaseToken]++
	return nil
}

// fakeSubscriptionRepo is an in-memory stand-in for domain.SubscriptionRepository.
type fakeSubscriptionRepo struct {
	byToken map[string]*domain.Subscription
}

func newFakeSubscriptionRepo() *fakeSubscriptionRepo {
	return &fakeSubscriptionRepo{byToken: map[string]*domain.Subscription{}}
}

func (r *fakeSubscriptionRepo) Upsert(ctx context.Context, s *domain.Subscription) error {
	if existing, ok := r.byToken[s.PurchaseToken]; ok {
		s.ID = existing.ID
		s.CreatedAt = existing.CreatedAt
	} else {
		s.ID = s.PurchaseToken // good enough uniqueness for tests
		s.CreatedAt = time.Now()
	}
	s.LastVerifiedAt = time.Now()
	s.UpdatedAt = time.Now()
	r.byToken[s.PurchaseToken] = s
	return nil
}

func (r *fakeSubscriptionRepo) FindLatestByUserID(ctx context.Context, userID string) (*domain.Subscription, error) {
	for _, s := range r.byToken {
		if s.UserID == userID {
			return s, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (r *fakeSubscriptionRepo) FindByPurchaseToken(ctx context.Context, token string) (*domain.Subscription, error) {
	if s, ok := r.byToken[token]; ok {
		return s, nil
	}
	return nil, domain.ErrNotFound
}

func activePurchase() *playdeveloper.SubscriptionPurchase {
	return &playdeveloper.SubscriptionPurchase{
		ExpiryTimeMillis:     time.Now().Add(30 * 24 * time.Hour).UnixMilli(),
		AutoRenewing:         true,
		AcknowledgementState: 0, // fresh, unacknowledged purchase
	}
}

func TestVerifyPurchase_AcknowledgesFreshPurchaseExactlyOnce(t *testing.T) {
	play := newFakePlayClient(activePurchase())
	repo := newFakeSubscriptionRepo()
	uc := NewSubscriptionUsecase(repo, play, 24*time.Hour)

	const token = "token-abc"
	if _, err := uc.VerifyPurchase(context.Background(), "user-1", "pro_monthly", token); err != nil {
		t.Fatalf("VerifyPurchase failed: %v", err)
	}

	if got := play.acknowledgeCalls[token]; got != 1 {
		t.Fatalf("expected acknowledge to be called exactly once, got %d", got)
	}
}

func TestVerifyPurchase_DoesNotReacknowledgeAlreadyAcknowledgedPurchase(t *testing.T) {
	purchase := activePurchase()
	purchase.AcknowledgementState = 1 // already acknowledged by a prior call
	play := newFakePlayClient(purchase)
	repo := newFakeSubscriptionRepo()
	uc := NewSubscriptionUsecase(repo, play, 24*time.Hour)

	const token = "token-already-ack"
	if _, err := uc.VerifyPurchase(context.Background(), "user-1", "pro_monthly", token); err != nil {
		t.Fatalf("VerifyPurchase failed: %v", err)
	}

	if got := play.acknowledgeCalls[token]; got != 0 {
		t.Fatalf("expected acknowledge NOT to be called for an already-acknowledged purchase, got %d calls", got)
	}
}

func TestVerifyPurchase_RejectsTokenClaimedByAnotherUser(t *testing.T) {
	play := newFakePlayClient(activePurchase())
	repo := newFakeSubscriptionRepo()
	uc := NewSubscriptionUsecase(repo, play, 24*time.Hour)

	const token = "token-shared"
	if _, err := uc.VerifyPurchase(context.Background(), "user-1", "pro_monthly", token); err != nil {
		t.Fatalf("first VerifyPurchase failed: %v", err)
	}

	_, err := uc.VerifyPurchase(context.Background(), "user-2", "pro_monthly", token)
	if err != domain.ErrPurchaseTokenTaken {
		t.Fatalf("expected ErrPurchaseTokenTaken, got %v", err)
	}
}

func TestDeriveStatus_ExpiredWithoutAutoRenewIsExpired(t *testing.T) {
	p := &playdeveloper.SubscriptionPurchase{
		ExpiryTimeMillis: time.Now().Add(-time.Hour).UnixMilli(),
		AutoRenewing:     false,
	}
	got := deriveStatus(p, playdeveloper.ExpiryTime(p.ExpiryTimeMillis))
	if got != domain.SubscriptionStatusExpired {
		t.Fatalf("expected expired, got %s", got)
	}
}

func TestDeriveStatus_ExpiredWithAutoRenewIsGracePeriod(t *testing.T) {
	p := &playdeveloper.SubscriptionPurchase{
		ExpiryTimeMillis: time.Now().Add(-time.Hour).UnixMilli(),
		AutoRenewing:     true,
	}
	got := deriveStatus(p, playdeveloper.ExpiryTime(p.ExpiryTimeMillis))
	if got != domain.SubscriptionStatusGracePeriod {
		t.Fatalf("expected grace_period, got %s", got)
	}
}

func TestDeriveStatus_FutureExpiryIsActive(t *testing.T) {
	p := activePurchase()
	got := deriveStatus(p, playdeveloper.ExpiryTime(p.ExpiryTimeMillis))
	if got != domain.SubscriptionStatusActive {
		t.Fatalf("expected active, got %s", got)
	}
}
