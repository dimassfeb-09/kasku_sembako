import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wholesale_price_entity.dart';
import '../../domain/repositories/wholesale_price_repository.dart';
import '../datasources/wholesale_price_local_datasource.dart';
import '../models/wholesale_price_model.dart';

class WholesalePriceRepositoryImpl implements WholesalePriceRepository {
  final WholesalePriceLocalDataSource localDataSource;

  WholesalePriceRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<WholesalePriceEntity>>>
  getWholesalePricesByProductId(String productId) async {
    try {
      final prices = await localDataSource.getWholesalePricesByProductId(
        productId,
      );
      return Right(prices);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil daftar harga grosir'));
    }
  }

  @override
  Future<Either<Failure, void>> insertWholesalePrice(
    WholesalePriceEntity price,
  ) async {
    try {
      final model = WholesalePriceModel(
        id: price.id,
        productId: price.productId,
        minQty: price.minQty,
        price: price.price,
      );
      await localDataSource.insertWholesalePrice(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menambahkan harga grosir'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWholesalePrice(String id) async {
    try {
      await localDataSource.deleteWholesalePrice(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghapus harga grosir'));
    }
  }
}
