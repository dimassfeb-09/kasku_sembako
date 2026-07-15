import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/error/failures.dart';
import 'package:kasirku_sembako/features/subscription/domain/entities/subscription_status_entity.dart';
import 'package:kasirku_sembako/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:kasirku_sembako/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:kasirku_sembako/features/subscription/presentation/cubit/subscription_state.dart';

class MockPurchaseProUseCase extends Mock implements PurchaseProUseCase {}

class MockRestorePurchasesUseCase extends Mock
    implements RestorePurchasesUseCase {}

class MockGetCachedSubscriptionStatusUseCase extends Mock
    implements GetCachedSubscriptionStatusUseCase {}

class MockRefreshSubscriptionStatusUseCase extends Mock
    implements RefreshSubscriptionStatusUseCase {}

void main() {
  late MockPurchaseProUseCase purchaseProUseCase;
  late MockRestorePurchasesUseCase restorePurchasesUseCase;
  late MockGetCachedSubscriptionStatusUseCase getCachedStatusUseCase;
  late MockRefreshSubscriptionStatusUseCase refreshStatusUseCase;

  final freeStatus = SubscriptionStatusEntity.free();
  final proStatus = SubscriptionStatusEntity(
    tier: SubscriptionTier.pro,
    isActive: true,
    expiresAt: DateTime.now().add(const Duration(days: 30)),
    lastVerifiedAt: DateTime.now(),
  );

  SubscriptionCubit buildCubit() => SubscriptionCubit(
    purchaseProUseCase: purchaseProUseCase,
    restorePurchasesUseCase: restorePurchasesUseCase,
    getCachedSubscriptionStatusUseCase: getCachedStatusUseCase,
    refreshSubscriptionStatusUseCase: refreshStatusUseCase,
  );

  setUp(() {
    purchaseProUseCase = MockPurchaseProUseCase();
    restorePurchasesUseCase = MockRestorePurchasesUseCase();
    getCachedStatusUseCase = MockGetCachedSubscriptionStatusUseCase();
    refreshStatusUseCase = MockRefreshSubscriptionStatusUseCase();
  });

  group('loadStatus', () {
    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits cached status first, then the refreshed status',
      build: () {
        when(
          () => getCachedStatusUseCase(),
        ).thenAnswer((_) async => Right(freeStatus));
        when(
          () => refreshStatusUseCase(),
        ).thenAnswer((_) async => Right(proStatus));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStatus(),
      expect: () => [
        SubscriptionStatusLoaded(freeStatus),
        SubscriptionStatusLoaded(proStatus),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'keeps the cached status if the refresh fails (does not clobber a working UI state)',
      build: () {
        when(
          () => getCachedStatusUseCase(),
        ).thenAnswer((_) async => Right(freeStatus));
        when(
          () => refreshStatusUseCase(),
        ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStatus(),
      expect: () => [SubscriptionStatusLoaded(freeStatus)],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits an error for the cache failure, then still applies a successful refresh after it',
      build: () {
        when(
          () => getCachedStatusUseCase(),
        ).thenAnswer((_) async => const Left(CacheFailure('corrupt cache')));
        when(
          () => refreshStatusUseCase(),
        ).thenAnswer((_) async => Right(freeStatus));
        return buildCubit();
      },
      act: (cubit) => cubit.loadStatus(),
      expect: () => [
        const SubscriptionError('corrupt cache'),
        SubscriptionStatusLoaded(freeStatus),
      ],
    );
  });

  group('purchasePro', () {
    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits [PurchaseInProgress, StatusLoaded] when the purchase flow launches successfully',
      build: () {
        when(
          () => purchaseProUseCase(),
        ).thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.purchasePro(),
      expect: () => [
        isA<SubscriptionPurchaseInProgress>(),
        isA<SubscriptionStatusLoaded>(),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits [PurchaseInProgress, Error] when the purchase flow fails to launch',
      build: () {
        when(() => purchaseProUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Billing tidak tersedia.')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.purchasePro(),
      expect: () => [
        isA<SubscriptionPurchaseInProgress>(),
        isA<SubscriptionError>(),
      ],
    );
  });

  group('restorePurchases', () {
    blocTest<SubscriptionCubit, SubscriptionState>(
      'reloads status after a successful restore',
      build: () {
        // Distinguishable cached-vs-refreshed values: Bloc's emit() dedupes
        // consecutive equal states, so re-using the same value for both
        // would only actually emit once.
        final refreshedProStatus = SubscriptionStatusEntity(
          tier: proStatus.tier,
          isActive: proStatus.isActive,
          expiresAt: proStatus.expiresAt,
          lastVerifiedAt: proStatus.lastVerifiedAt.add(
            const Duration(seconds: 1),
          ),
        );
        when(
          () => restorePurchasesUseCase(),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => getCachedStatusUseCase(),
        ).thenAnswer((_) async => Right(proStatus));
        when(
          () => refreshStatusUseCase(),
        ).thenAnswer((_) async => Right(refreshedProStatus));
        return buildCubit();
      },
      act: (cubit) => cubit.restorePurchases(),
      expect: () => [
        isA<SubscriptionStatusLoaded>(),
        isA<SubscriptionStatusLoaded>(),
      ],
    );

    blocTest<SubscriptionCubit, SubscriptionState>(
      'emits an error when restore itself fails',
      build: () {
        when(() => restorePurchasesUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Gagal memulihkan pembelian.')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.restorePurchases(),
      expect: () => [isA<SubscriptionError>()],
    );
  });
}
