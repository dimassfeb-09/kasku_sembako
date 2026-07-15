import '../../domain/entities/subscription_status_entity.dart';

class SubscriptionStatusModel extends SubscriptionStatusEntity {
  const SubscriptionStatusModel({
    required super.tier,
    required super.isActive,
    required super.expiresAt,
    required super.lastVerifiedAt,
  });

  /// [verifiedAt] is the client's own clock at the moment this response was
  /// received — the backend's /subscriptions/status response doesn't carry
  /// a lastVerifiedAt field itself, only tier/isActive/expiresAt.
  factory SubscriptionStatusModel.fromJson(
    Map<String, dynamic> json, {
    required DateTime verifiedAt,
  }) {
    final tierStr = json['tier'] as String? ?? 'free';
    final expiresAtStr = json['expiresAt'] as String?;
    return SubscriptionStatusModel(
      tier: tierStr == 'pro' ? SubscriptionTier.pro : SubscriptionTier.free,
      isActive: json['isActive'] as bool? ?? false,
      expiresAt: expiresAtStr != null ? DateTime.parse(expiresAtStr) : null,
      lastVerifiedAt: verifiedAt,
    );
  }
}
