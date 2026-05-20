import 'package:equatable/equatable.dart';
import '../../../../features/product/domain/entities/product_entity.dart';
import '../../../../features/product/domain/entities/wholesale_price_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final List<WholesalePriceEntity> wholesalePrices;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.wholesalePrices = const [],
  });

  double get unitPrice {
    if (wholesalePrices.isEmpty) return product.sellingPrice;
    
    // Temukan harga grosir yang memenuhi qty minimum, urutkan dari minQty terbesar
    final sortedPrices = List<WholesalePriceEntity>.from(wholesalePrices)
      ..sort((a, b) => b.minQty.compareTo(a.minQty));
      
    for (var wp in sortedPrices) {
      if (quantity >= wp.minQty) {
        return wp.price;
      }
    }
    return product.sellingPrice;
  }

  double get subtotal => unitPrice * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    List<WholesalePriceEntity>? wholesalePrices,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      wholesalePrices: wholesalePrices ?? this.wholesalePrices,
    );
  }

  @override
  List<Object?> get props => [product, quantity, wholesalePrices];
}
