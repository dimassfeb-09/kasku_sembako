import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subscription_status_entity.dart';
import '../../domain/usecases/subscription_usecases.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final PurchaseProUseCase purchaseProUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final GetCachedSubscriptionStatusUseCase getCachedSubscriptionStatusUseCase;
  final RefreshSubscriptionStatusUseCase refreshSubscriptionStatusUseCase;

  SubscriptionCubit({
    required this.purchaseProUseCase,
    required this.restorePurchasesUseCase,
    required this.getCachedSubscriptionStatusUseCase,
    required this.refreshSubscriptionStatusUseCase,
  }) : super(SubscriptionInitial());

  /// Loads the cached entitlement immediately (works offline, used for
  /// gating UI like the cloud backup buttons), then refreshes from the
  /// backend in the background.
  Future<void> loadStatus() async {
    final cachedResult = await getCachedSubscriptionStatusUseCase();
    cachedResult.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (status) => emit(SubscriptionStatusLoaded(status)),
    );

    final refreshResult = await refreshSubscriptionStatusUseCase();
    refreshResult.fold((failure) {
      // Keep whatever was already loaded (cached or previous) rather than
      // clobbering a working UI state with a transient refresh error.
    }, (status) => emit(SubscriptionStatusLoaded(status)));
  }

  /// Debug-only: emit status from local cache without hitting backend.
  /// Called from the debug panel after toggling the local Pro row, so the
  /// refresh (which returns the real backend status) doesn't override it.
  Future<void> loadCachedOnly() async {
    final result = await getCachedSubscriptionStatusUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (status) => emit(SubscriptionStatusLoaded(status)),
    );
  }

  Future<void> purchasePro() async {
    final current = state is SubscriptionStatusLoaded
        ? (state as SubscriptionStatusLoaded).status
        : SubscriptionStatusEntity.free();
    emit(SubscriptionPurchaseInProgress(current));

    final result = await purchaseProUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message, previous: current)),
      (_) {
        // Purchase flow launched (Play's own UI takes over). The
        // subscription repository's purchaseStream listener verifies with
        // the backend and updates the local cache once Google reports it
        // purchased — refresh here to reflect that once it lands.
        emit(SubscriptionStatusLoaded(current));
      },
    );
  }

  Future<void> restorePurchases() async {
    final result = await restorePurchasesUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => loadStatus(),
    );
  }
}
