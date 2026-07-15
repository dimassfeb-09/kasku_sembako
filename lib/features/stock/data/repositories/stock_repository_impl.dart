import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock_history_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDataSource localDataSource;

  StockRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<StockHistoryEntity>>> getStockHistory(
    String productId,
  ) async {
    try {
      final histories = await localDataSource.getStockHistory(productId);
      return Right(histories);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil riwayat stok'));
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock(
    String productId,
    String type,
    int quantity,
    String notes,
  ) async {
    try {
      await localDataSource.adjustStock(productId, type, quantity, notes);
      return const Right(null);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return Left(
        DatabaseFailure(
          msg.isNotEmpty ? msg : 'Gagal melakukan penyesuaian stok',
        ),
      );
    }
  }
}
