import '../../../../core/database/app_database.dart';
import '../../domain/entities/stock_history_entity.dart';

class StockHistoryModel extends StockHistoryEntity {
  const StockHistoryModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.notes,
    required super.createdAt,
  });

  factory StockHistoryModel.fromDrift(StockHistory history) {
    return StockHistoryModel(
      id: history.id,
      productId: history.productId,
      type: history.type,
      quantity: history.qty,
      notes: history.notes ?? '',
      createdAt: history.createdAt,
    );
  }
}
