import 'package:drift/drift.dart' show Value;
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/app_database.dart';
import '../models/product_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductByBarcode(String barcode);
  Future<int> countProducts();
  Future<void> insertProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final AppDatabase db;
  final ActivityLogService logService;

  ProductLocalDataSourceImpl({required this.db, required this.logService});

  @override
  Future<List<ProductModel>> getProducts() async {
    final products = await db.select(db.products).get();
    return products.map((p) => ProductModel.fromDrift(p)).toList();
  }

  @override
  Future<int> countProducts() async {
    final products = await (db.select(db.products)
      ..where((p) => p.isActive.equals(true))).get();
    return products.length;
  }

  @override
  Future<ProductModel> getProductByBarcode(String barcode) async {
    final query = db.select(db.products)
      ..where((p) => p.barcode.equals(barcode));
    final product = await query.getSingleOrNull();
    if (product != null) {
      return ProductModel.fromDrift(product);
    } else {
      throw const CacheException('Produk tidak ditemukan');
    }
  }

  @override
  Future<void> insertProduct(ProductModel product) async {
    await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            id: product.id,
            barcode: product.barcode,
            name: product.name,
            categoryId: Value(product.categoryId),
            purchasePrice: product.purchasePrice,
            sellingPrice: product.sellingPrice,
            stock: Value(product.stock),
            unit: product.unit,
            imagePath: Value(product.imagePath),
            isActive: Value(product.isActive),
          ),
        );

    await logService.log(
      action: 'ADD_PRODUCT',
      description:
          'Menambahkan produk baru: ${product.name} dengan harga eceran ${product.sellingPrice.toRupiah()}.',
    );
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await (db.update(db.products)..where((p) => p.id.equals(product.id))).write(
      ProductsCompanion(
        barcode: Value(product.barcode),
        name: Value(product.name),
        categoryId: Value(product.categoryId),
        purchasePrice: Value(product.purchasePrice),
        sellingPrice: Value(product.sellingPrice),
        stock: Value(product.stock),
        unit: Value(product.unit),
        imagePath: Value(product.imagePath),
        isActive: Value(product.isActive),
      ),
    );

    await logService.log(
      action: 'EDIT_PRODUCT',
      description:
          'Mengubah detail produk: ${product.name} (${product.barcode}).',
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    String name = id;
    try {
      final query = db.select(db.products)..where((p) => p.id.equals(id));
      final product = await query.getSingleOrNull();
      if (product != null) {
        name = product.name;
      }
    } catch (_) {}

    await (db.update(db.products)..where((p) => p.id.equals(id))).write(
      const ProductsCompanion(isActive: Value(false)),
    );

    await logService.log(
      action: 'DELETE_PRODUCT',
      description: 'Menghapus (menonaktifkan) produk $name.',
    );
  }
}
