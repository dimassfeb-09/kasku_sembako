package playdeveloper

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/api/androidpublisher/v3"
	"google.golang.org/api/option"
)

// Client wraps the official Android Publisher API client for server-side
// Play Billing purchase verification. Auth is via a Google Cloud service
// account JSON key (see Play Console > Setup > API access for how to link
// one) referenced by GOOGLE_APPLICATION_CREDENTIALS.
type Client struct {
	svc         *androidpublisher.Service
	packageName string
}

func New(ctx context.Context, credentialsFile, packageName string) (*Client, error) {
	svc, err := androidpublisher.NewService(ctx, option.WithCredentialsFile(credentialsFile))
	if err != nil {
		return nil, fmt.Errorf("creating androidpublisher client: %w", err)
	}
	return &Client{svc: svc, packageName: packageName}, nil
}

// SubscriptionPurchase mirrors just the fields this backend needs from
// Google's response, mapped to our own domain vocabulary at the call site.
//
// Deliberately omits CancelReason: in this API it's a plain int64 (not a
// pointer), so its zero value is indistinguishable between "not set" and
// "User canceled" (reason code 0) — using it to detect cancellation would
// be a silent correctness bug. AutoRenewing + ExpiryTimeMillis are enough
// to derive status without that ambiguity.
type SubscriptionPurchase struct {
	ExpiryTimeMillis     int64
	AutoRenewing         bool
	PaymentState         *int64
	AcknowledgementState int64 // 0 = not yet acknowledged, 1 = acknowledged
}

func (c *Client) GetSubscription(ctx context.Context, subscriptionID, purchaseToken string) (*SubscriptionPurchase, error) {
	call := c.svc.Purchases.Subscriptions.Get(c.packageName, subscriptionID, purchaseToken)
	resp, err := call.Context(ctx).Do()
	if err != nil {
		return nil, fmt.Errorf("androidpublisher get subscription: %w", err)
	}
	return &SubscriptionPurchase{
		ExpiryTimeMillis:     resp.ExpiryTimeMillis,
		AutoRenewing:         resp.AutoRenewing,
		PaymentState:         resp.PaymentState,
		AcknowledgementState: resp.AcknowledgementState,
	}, nil
}

// AcknowledgeSubscription MUST be called within 3 days of a first-time
// purchase or Google auto-refunds it. Call this immediately after a
// successful GetSubscription for any purchase with AcknowledgementState==0.
func (c *Client) AcknowledgeSubscription(ctx context.Context, subscriptionID, purchaseToken string) error {
	req := &androidpublisher.SubscriptionPurchasesAcknowledgeRequest{}
	call := c.svc.Purchases.Subscriptions.Acknowledge(c.packageName, subscriptionID, purchaseToken, req)
	return call.Context(ctx).Do()
}

// ExpiryTime converts the API's millisecond epoch to time.Time.
func ExpiryTime(millis int64) time.Time {
	return time.UnixMilli(millis)
}
