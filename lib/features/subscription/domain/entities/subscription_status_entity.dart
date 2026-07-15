import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, pro }

class SubscriptionStatusEntity extends Equatable {
  final SubscriptionTier tier;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime lastVerifiedAt;

  const SubscriptionStatusEntity({
    required this.tier,
    required this.isActive,
    required this.expiresAt,
    required this.lastVerifiedAt,
  });

  static SubscriptionStatusEntity free() => SubscriptionStatusEntity(
    tier: SubscriptionTier.free,
    isActive: false,
    expiresAt: null,
    lastVerifiedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Client-side UX gate only — the backend re-derives this independently
  /// before allowing any Pro-only action (see backend requirePro
  /// middleware). Includes a short offline grace window: if the cached
  /// expiry has passed but we verified against the server recently, assume
  /// it's just an unconfirmed renewal rather than locking out a paying,
  /// offline shop owner mid-shift.
  bool get isEntitled {
    if (tier != SubscriptionTier.pro) return false;
    final now = DateTime.now();
    if (expiresAt == null || expiresAt!.isAfter(now)) return true;
    const graceWindow = Duration(days: 3);
    return now.difference(lastVerifiedAt) <= graceWindow;
  }

  @override
  List<Object?> get props => [tier, isActive, expiresAt, lastVerifiedAt];
}
