import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.barcode,
    required super.name,
    super.categoryId,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.stock,
    required super.unit,
    super.imagePath,
    required super.isActive,
    super.trackStock,
    super.minStock,
  });

  factory ProductModel.fromDrift(Product product) {
    return ProductModel(
      id: product.id,
      barcode: product.barcode,
      name: product.name,
      categoryId: product.categoryId,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: product.stock,
      unit: product.unit,
      imagePath: product.imagePath,
      isActive: product.isActive,
      trackStock: product.trackStock,
      minStock: product.minStock,
    );
  }

  ProductsCompanion toCompanion() {
    return ProductsCompanion.insert(
      id: id,
      barcode: barcode,
      name: name,
      categoryId: Value(categoryId),
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      stock: Value(stock),
      unit: unit,
      imagePath: Value(imagePath),
      isActive: Value(isActive),
      trackStock: Value(trackStock),
      minStock: Value(minStock),
    );
  }
}
