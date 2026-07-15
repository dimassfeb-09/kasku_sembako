import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_history_entity.dart';

abstract class StockRepository {
  Future<Either<Failure, List<StockHistoryEntity>>> getStockHistory(
    String productId,
  );
  Future<Either<Failure, void>> adjustStock(
    String productId,
    String type,
    int quantity,
    String notes,
  );
}
