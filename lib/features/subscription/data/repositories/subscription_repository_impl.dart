import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_status_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/billing_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_status_model.dart';

const String _cacheRowId = 'current';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final BillingLocalDataSource billingLocalDataSource;
  final SubscriptionRemoteDataSource remoteDataSource;
  final AppDatabase db;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  SubscriptionRepositoryImpl({
    required this.billingLocalDataSource,
    required this.remoteDataSource,
    required this.db,
  }) {
    // Subscribed once, for the lifetime of the app (this repository is a
    // lazy singleton) — so purchases completed while backgrounded/killed
    // are still caught the next time the app opens and this is resolved.
    _purchaseSubscription = billingLocalDataSource.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          final status = await remoteDataSource.verifyPurchase(
            productId: purchase.productID,
            purchaseToken: purchase.verificationData.serverVerificationData,
          );
          await _writeCache(status);
          // Only mark complete with Google once the backend has confirmed
          // and acknowledged the purchase — skipping this call causes
          // Google to auto-refund after a few days.
          await billingLocalDataSource.completePurchase(purchase);
        } catch (_) {
          // Verification failed (e.g. not signed into a cloud account yet,
          // or offline). Deliberately do NOT complete the purchase — Play
          // will keep it pending and redeliver it on the next app open via
          // this same stream, so it's retried once the account/connection
          // issue is resolved.
        }
      } else if (purchase.status == PurchaseStatus.error) {
        // Nothing actionable client-side beyond leaving it uncompleted.
      }
    }
  }

  @override
  Future<Either<Failure, void>> purchasePro() async {
    try {
      final product = await billingLocalDataSource.queryProProduct();
      await billingLocalDataSource.buyPro(product);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memulai pembelian: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases() async {
    try {
      await billingLocalDataSource.restorePurchases();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Gagal memulihkan pembelian: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatusEntity>> getCachedStatus() async {
    try {
      final row = await (db.select(
        db.subscriptionCaches,
      )..where((t) => t.id.equals(_cacheRowId))).getSingleOrNull();

      if (row == null) {
        return Right(SubscriptionStatusEntity.free());
      }

      return Right(
        SubscriptionStatusEntity(
          tier: row.tier == 'pro'
              ? SubscriptionTier.pro
              : SubscriptionTier.free,
          isActive: row.isActive,
          expiresAt: row.expiresAt,
          lastVerifiedAt: row.lastVerifiedAt,
        ),
      );
    } catch (e) {
      return const Left(CacheFailure('Gagal membaca status langganan lokal.'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatusEntity>> refreshStatus() async {
    try {
      final status = await remoteDataSource.getStatus();
      await _writeCache(status);
      return Right(status);
    } on NetworkException {
      // Offline: fall back to whatever is cached rather than failing —
      // the entity's own isEntitled grace window handles staleness.
      return getCachedStatus();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Gagal memperbarui status langganan: ${e.toString()}'),
      );
    }
  }

  Future<void> _writeCache(SubscriptionStatusModel status) async {
    await db
        .into(db.subscriptionCaches)
        .insertOnConflictUpdate(
          SubscriptionCachesCompanion(
            id: const drift.Value(_cacheRowId),
            tier: drift.Value(
              status.tier == SubscriptionTier.pro ? 'pro' : 'free',
            ),
            isActive: drift.Value(status.isActive),
            expiresAt: drift.Value(status.expiresAt),
            lastVerifiedAt: drift.Value(status.lastVerifiedAt),
          ),
        );
  }

  void dispose() {
    _purchaseSubscription?.cancel();
  }
}
