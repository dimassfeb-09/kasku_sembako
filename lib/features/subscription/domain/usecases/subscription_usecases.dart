import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription_status_entity.dart';
import '../repositories/subscription_repository.dart';

class PurchaseProUseCase {
  final SubscriptionRepository repository;

  PurchaseProUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.purchasePro();
  }
}

class RestorePurchasesUseCase {
  final SubscriptionRepository repository;

  RestorePurchasesUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.restorePurchases();
  }
}

class GetCachedSubscriptionStatusUseCase {
  final SubscriptionRepository repository;

  GetCachedSubscriptionStatusUseCase(this.repository);

  Future<Either<Failure, SubscriptionStatusEntity>> call() async {
    return await repository.getCachedStatus();
  }
}

class RefreshSubscriptionStatusUseCase {
  final SubscriptionRepository repository;

  RefreshSubscriptionStatusUseCase(this.repository);

  Future<Either<Failure, SubscriptionStatusEntity>> call() async {
    return await repository.refreshStatus();
  }
}
