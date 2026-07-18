import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String barcode;
  final String name;
  final String? categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final String unit;
  final String? imagePath;
  final bool isActive;
  final bool trackStock;
  final int? minStock;

  const ProductEntity({
    required this.id,
    required this.barcode,
    required this.name,
    this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.unit,
    this.imagePath,
    required this.isActive,
    this.trackStock = true,
    this.minStock,
  });

  @override
  List<Object?> get props => [
    id,
    barcode,
    name,
    categoryId,
    purchasePrice,
    sellingPrice,
    stock,
    unit,
    imagePath,
    isActive,
    trackStock,
    minStock,
  ];

  ProductEntity copyWith({
    String? id,
    String? barcode,
    String? name,
    String? categoryId,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    String? unit,
    String? imagePath,
    bool? isActive,
    bool? trackStock,
    int? minStock,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      trackStock: trackStock ?? this.trackStock,
      minStock: minStock ?? this.minStock,
    );
  }
}
