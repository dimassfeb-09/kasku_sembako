import '../../../../core/database/app_database.dart';
import '../models/wholesale_price_model.dart';

abstract class WholesalePriceLocalDataSource {
  Future<List<WholesalePriceModel>> getWholesalePricesByProductId(
    String productId,
  );
  Future<void> insertWholesalePrice(WholesalePriceModel price);
  Future<void> deleteWholesalePrice(String id);
}

class WholesalePriceLocalDataSourceImpl
    implements WholesalePriceLocalDataSource {
  final AppDatabase db;

  WholesalePriceLocalDataSourceImpl({required this.db});

  @override
  Future<List<WholesalePriceModel>> getWholesalePricesByProductId(
    String productId,
  ) async {
    final query = db.select(db.wholesalePrices)
      ..where((p) => p.productId.equals(productId));
    final prices = await query.get();
    return prices.map((p) => WholesalePriceModel.fromDrift(p)).toList();
  }

  @override
  Future<void> insertWholesalePrice(WholesalePriceModel price) async {
    await db
        .into(db.wholesalePrices)
        .insert(
          WholesalePricesCompanion.insert(
            id: price.id,
            productId: price.productId,
            minQty: price.minQty,
            price: price.price,
          ),
        );
  }

  @override
  Future<void> deleteWholesalePrice(String id) async {
    await (db.delete(db.wholesalePrices)..where((p) => p.id.equals(id))).go();
  }
}
