import '../../../../core/database/app_database.dart';
import '../../domain/entities/home_metrics.dart';
import 'package:drift/drift.dart';

abstract class HomeLocalDataSource {
  Future<HomeMetrics> getHomeMetrics({
    required bool isAdmin,
    required String? userId,
  });
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final AppDatabase db;

  HomeLocalDataSourceImpl({required this.db});

  @override
  Future<HomeMetrics> getHomeMetrics({
    required bool isAdmin,
    required String? userId,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Ambil semua transaksi hari ini
    final trxs =
        await (db.select(db.transactions)..where((tbl) {
              var expr =
                  tbl.createdAt.isBiggerOrEqualValue(todayStart) &
                  tbl.createdAt.isSmallerOrEqualValue(todayEnd);
              if (!isAdmin && userId != null) {
                expr = expr & tbl.cashierId.equals(userId);
              }
              return expr;
            }))
            .get();

    final activeTrxs = trxs.where((t) => t.status != 'VOID').toList();
    final double omset = activeTrxs.fold(0.0, (sum, t) => sum + t.totalAmount);
    final int trxCount = activeTrxs.length;

    double totalExp = 0.0;
    int lowStockCount = 0;

    if (isAdmin) {
      // Ambil pengeluaran hari ini
      final exps =
          await (db.select(db.expenses)..where(
                (tbl) =>
                    tbl.date.isBiggerOrEqualValue(todayStart) &
                    tbl.date.isSmallerOrEqualValue(todayEnd),
              ))
              .get();
      totalExp = exps.fold(0.0, (sum, e) => sum + e.amount);

      // Ambil barang dengan stok menipis (<= 5)
      final lowStockProducts =
          await (db.select(db.products)..where(
                (tbl) =>
                    tbl.stock.isSmallerThanValue(6) & tbl.isActive.equals(true),
              ))
              .get();
      lowStockCount = lowStockProducts.length;
    }

    return HomeMetrics(
      omset: omset,
      trxCount: trxCount,
      expenses: totalExp,
      lowStock: lowStockCount,
    );
  }
}
