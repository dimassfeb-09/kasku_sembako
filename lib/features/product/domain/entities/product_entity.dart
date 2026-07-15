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
  ];
}
