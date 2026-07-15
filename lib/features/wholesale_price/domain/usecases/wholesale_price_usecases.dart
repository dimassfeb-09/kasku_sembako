import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wholesale_price_entity.dart';
import '../repositories/wholesale_price_repository.dart';

class GetWholesalePricesUseCase {
  final WholesalePriceRepository repository;
  GetWholesalePricesUseCase(this.repository);
  Future<Either<Failure, List<WholesalePriceEntity>>> call(
    String productId,
  ) async {
    return await repository.getWholesalePricesByProductId(productId);
  }
}

class InsertWholesalePriceUseCase {
  final WholesalePriceRepository repository;
  InsertWholesalePriceUseCase(this.repository);
  Future<Either<Failure, void>> call(WholesalePriceEntity price) async {
    return await repository.insertWholesalePrice(price);
  }
}

class DeleteWholesalePriceUseCase {
  final WholesalePriceRepository repository;
  DeleteWholesalePriceUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteWholesalePrice(id);
  }
}
