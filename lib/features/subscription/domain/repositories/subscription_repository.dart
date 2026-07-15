import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription_status_entity.dart';

/// Platform-neutral by design: no Play Billing types (PurchaseDetails etc.)
/// leak past the data layer's billing_local_datasource.dart. If Apple IAP
/// is added later, only that datasource (or a second one behind a platform
/// switch) needs to change — this interface and everything above it stays
/// the same.
abstract class SubscriptionRepository {
  Future<Either<Failure, void>> purchasePro();
  Future<Either<Failure, void>> restorePurchases();

  /// Cached local entitlement (SubscriptionCaches table) — no network call.
  Future<Either<Failure, SubscriptionStatusEntity>> getCachedStatus();

  /// Refreshes the cache from the backend's GET /subscriptions/status.
  Future<Either<Failure, SubscriptionStatusEntity>> refreshStatus();
}
