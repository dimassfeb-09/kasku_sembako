import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/database/app_database.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/subscription/data/datasources/billing_local_datasource.dart';
import 'package:kasirku_sembako/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:kasirku_sembako/features/subscription/data/models/subscription_status_model.dart';
import 'package:kasirku_sembako/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:kasirku_sembako/features/subscription/domain/entities/subscription_status_entity.dart';

class MockBillingLocalDataSource extends Mock
    implements BillingLocalDataSource {}

class MockSubscriptionRemoteDataSource extends Mock
    implements SubscriptionRemoteDataSource {}

void main() {
  late MockBillingLocalDataSource billingLocalDataSource;
  late MockSubscriptionRemoteDataSource remoteDataSource;
  late AppDatabase db;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    billingLocalDataSource = MockBillingLocalDataSource();
    // The repository subscribes to purchaseStream in its constructor, so
    // this must be stubbed before construction or .listen() throws on null.
    when(
      () => billingLocalDataSource.purchaseStream,
    ).thenAnswer((_) => const Stream<List<PurchaseDetails>>.empty());
    remoteDataSource = MockSubscriptionRemoteDataSource();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SubscriptionRepositoryImpl(
      billingLocalDataSource: billingLocalDataSource,
      remoteDataSource: remoteDataSource,
      db: db,
    );
  });

  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  group('purchasePro', () {
    final product = ProductDetails(
      id: 'pro_monthly',
      title: 'Kasirku Pro',
      description: 'Pro subscription',
      price: 'Rp10.000',
      rawPrice: 10000,
      currencyCode: 'IDR',
    );

    test(
      'returns Right(null) when the purchase flow launches successfully',
      () async {
        when(
          () => billingLocalDataSource.queryProProduct(),
        ).thenAnswer((_) async => product);
        when(
          () => billingLocalDataSource.buyPro(product),
        ).thenAnswer((_) async {});

        final result = await repository.purchasePro();

        expect(result, const Right<Failure, void>(null));
      },
    );

    test('returns ServerFailure when querying the product fails', () async {
      when(
        () => billingLocalDataSource.queryProProduct(),
      ).thenThrow(const ServerException('Produk tidak ditemukan.'));

      final result = await repository.purchasePro();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('restorePurchases', () {
    test('returns Right(null) on success', () async {
      when(
        () => billingLocalDataSource.restorePurchases(),
      ).thenAnswer((_) async {});

      final result = await repository.restorePurchases();

      expect(result, const Right<Failure, void>(null));
    });

    test('returns ServerFailure when the platform call throws', () async {
      when(
        () => billingLocalDataSource.restorePurchases(),
      ).thenThrow(Exception('boom'));

      final result = await repository.restorePurchases();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });

  group('getCachedStatus', () {
    test('returns the free default when no cache row exists', () async {
      final result = await repository.getCachedStatus();

      result.fold((failure) => fail('expected a Right, got $failure'), (
        status,
      ) {
        expect(status.tier, SubscriptionTier.free);
      });
    });
  });

  group('refreshStatus', () {
    test(
      'writes the fetched status to the local cache and returns it',
      () async {
        final now = DateTime.now();
        final remoteStatus = SubscriptionStatusModel(
          tier: SubscriptionTier.pro,
          isActive: true,
          expiresAt: now.add(const Duration(days: 30)),
          lastVerifiedAt: now,
        );
        when(
          () => remoteDataSource.getStatus(),
        ).thenAnswer((_) async => remoteStatus);

        final result = await repository.refreshStatus();

        result.fold((failure) => fail('expected a Right, got $failure'), (
          status,
        ) {
          expect(status.tier, SubscriptionTier.pro);
          expect(status.isActive, isTrue);
        });

        // The write should be reflected by a subsequent cache read.
        final cached = await repository.getCachedStatus();
        cached.fold((failure) => fail('expected a Right, got $failure'), (
          status,
        ) {
          expect(status.tier, SubscriptionTier.pro);
        });
      },
    );

    test(
      'falls back to the cached status when the network is unreachable',
      () async {
        // Seed the cache first via a successful refresh...
        final now = DateTime.now();
        when(() => remoteDataSource.getStatus()).thenAnswer(
          (_) async => SubscriptionStatusModel(
            tier: SubscriptionTier.pro,
            isActive: true,
            expiresAt: now.add(const Duration(days: 30)),
            lastVerifiedAt: now,
          ),
        );
        await repository.refreshStatus();

        // ...then simulate an offline re-verification attempt.
        when(
          () => remoteDataSource.getStatus(),
        ).thenThrow(const NetworkException('Tidak dapat terhubung ke server.'));

        final result = await repository.refreshStatus();

        result.fold(
          (failure) => fail('expected a Right (cache fallback), got $failure'),
          (status) {
            expect(status.tier, SubscriptionTier.pro);
          },
        );
      },
    );

    test('returns ServerFailure on a server error', () async {
      when(() => remoteDataSource.getStatus()).thenThrow(
        const ServerException('Silakan masuk ke akun toko terlebih dahulu.'),
      );

      final result = await repository.refreshStatus();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected a Left'),
      );
    });
  });
}
