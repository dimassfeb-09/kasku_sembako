import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock_history_entity.dart';
import '../repositories/stock_repository.dart';

class GetStockHistoryUseCase {
  final StockRepository repository;
  GetStockHistoryUseCase(this.repository);
  Future<Either<Failure, List<StockHistoryEntity>>> call(
    String productId,
  ) async {
    return await repository.getStockHistory(productId);
  }
}

class AdjustStockUseCase {
  final StockRepository repository;
  AdjustStockUseCase(this.repository);
  Future<Either<Failure, void>> call(
    String productId,
    String type,
    int quantity,
    String notes,
  ) async {
    return await repository.adjustStock(productId, type, quantity, notes);
  }
}
