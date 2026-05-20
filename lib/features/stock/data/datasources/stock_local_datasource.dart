import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/stock_history_model.dart';

abstract class StockLocalDataSource {
  Future<List<StockHistoryModel>> getStockHistory(String productId);
  Future<void> adjustStock(String productId, String type, int quantity, String notes);
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  final AppDatabase db;
  final FlutterSecureStorage secureStorage;
  final ActivityLogService logService;

  StockLocalDataSourceImpl({
    required this.db,
    required this.secureStorage,
    required this.logService,
  });

  @override
  Future<List<StockHistoryModel>> getStockHistory(String productId) async {
    final query = db.select(db.stockHistories)..where((s) => s.productId.equals(productId));
    final histories = await query.get();
    return histories.map((h) => StockHistoryModel.fromDrift(h)).toList();
  }

  @override
  Future<void> adjustStock(String productId, String type, int quantity, String notes) async {
    final userId = await secureStorage.read(key: AppConstants.currentUserIdKey) ?? 'admin_id';

    await db.transaction(() async {
      // 1. Insert history
      await db.into(db.stockHistories).insert(
        StockHistoriesCompanion.insert(
          id: const Uuid().v4(),
          productId: productId,
          type: type,
          qty: quantity,
          notes: Value(notes.isEmpty ? null : notes),
          userId: userId,
          createdAt: DateTime.now(),
        ),
      );

      // 2. Update product stock
      final productQuery = db.select(db.products)..where((p) => p.id.equals(productId));
      final product = await productQuery.getSingle();
      
      int newStock = product.stock;
      if (type == 'IN' || type == 'ADJUSTMENT_ADD') {
        newStock += quantity;
      } else if (type == 'OUT' || type == 'ADJUSTMENT_SUB') {
        if (product.stock - quantity < 0) {
          throw Exception('Jumlah penyesuaian melebihi stok yang tersedia saat ini.');
        }
        newStock -= quantity;
      }

      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(stock: Value(newStock)),
      );

      final typeText = (type == 'IN' || type == 'ADJUSTMENT_ADD') ? 'Penambahan' : 'Pengurangan';
      final reason = notes.isNotEmpty ? ' karena: $notes' : '';
      await logService.log(
        action: 'ADJUST_STOCK',
        description: 'Penyesuaian stok produk ${product.name}: $typeText $quantity pcs$reason.',
        userId: userId,
      );
    });
  }
}
