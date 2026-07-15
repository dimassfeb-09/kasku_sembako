import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/features/subscription/domain/entities/subscription_status_entity.dart';

void main() {
  group('SubscriptionStatusEntity.isEntitled', () {
    test('free tier is never entitled, regardless of other fields', () {
      final status = SubscriptionStatusEntity(
        tier: SubscriptionTier.free,
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        lastVerifiedAt: DateTime.now(),
      );
      expect(status.isEntitled, isFalse);
    });

    test('SubscriptionStatusEntity.free() factory is never entitled', () {
      expect(SubscriptionStatusEntity.free().isEntitled, isFalse);
    });

    test('pro tier with a future expiry is entitled', () {
      final status = SubscriptionStatusEntity(
        tier: SubscriptionTier.pro,
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        lastVerifiedAt: DateTime.now(),
      );
      expect(status.isEntitled, isTrue);
    });

    test('pro tier with a null expiry (no expiry tracked) is entitled', () {
      final status = SubscriptionStatusEntity(
        tier: SubscriptionTier.pro,
        isActive: true,
        expiresAt: null,
        lastVerifiedAt: DateTime.now(),
      );
      expect(status.isEntitled, isTrue);
    });

    test(
      'pro tier with a past expiry but verified recently (within 3-day grace) is still entitled',
      () {
        final now = DateTime.now();
        final status = SubscriptionStatusEntity(
          tier: SubscriptionTier.pro,
          isActive: true,
          expiresAt: now.subtract(const Duration(hours: 1)),
          lastVerifiedAt: now.subtract(const Duration(hours: 2)),
        );
        expect(status.isEntitled, isTrue);
      },
    );

    test(
      'pro tier with a past expiry and stale verification (beyond 3-day grace) is not entitled',
      () {
        final now = DateTime.now();
        final status = SubscriptionStatusEntity(
          tier: SubscriptionTier.pro,
          isActive: false,
          expiresAt: now.subtract(const Duration(days: 5)),
          lastVerifiedAt: now.subtract(const Duration(days: 4)),
        );
        expect(status.isEntitled, isFalse);
      },
    );

    test(
      'grace window boundary: just under 3 days since last verification is still entitled',
      () {
        // Deliberately not testing the exact 3-day instant: isEntitled calls
        // DateTime.now() internally, which is always fractionally later than
        // this test's own `now`, so an exact-boundary comparison is racy by
        // construction rather than a real production concern.
        final now = DateTime.now();
        final status = SubscriptionStatusEntity(
          tier: SubscriptionTier.pro,
          isActive: false,
          expiresAt: now.subtract(const Duration(days: 1)),
          lastVerifiedAt: now.subtract(
            const Duration(days: 2, hours: 23, minutes: 59),
          ),
        );
        expect(status.isEntitled, isTrue);
      },
    );
  });
}
