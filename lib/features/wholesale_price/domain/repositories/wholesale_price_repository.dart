import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wholesale_price_entity.dart';

abstract class WholesalePriceRepository {
  Future<Either<Failure, List<WholesalePriceEntity>>>
  getWholesalePricesByProductId(String productId);
  Future<Either<Failure, void>> insertWholesalePrice(
    WholesalePriceEntity price,
  );
  Future<Either<Failure, void>> deleteWholesalePrice(String id);
}
