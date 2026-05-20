import 'package:equatable/equatable.dart';

class WholesalePriceEntity extends Equatable {
  final String id;
  final String productId;
  final int minQty;
  final double price;

  const WholesalePriceEntity({
    required this.id,
    required this.productId,
    required this.minQty,
    required this.price,
  });

  @override
  List<Object?> get props => [id, productId, minQty, price];
}
