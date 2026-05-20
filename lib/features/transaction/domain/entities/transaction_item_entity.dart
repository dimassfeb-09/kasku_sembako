import 'package:equatable/equatable.dart';

class TransactionItemEntity extends Equatable {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final int qty;
  final double price;
  final double purchasePrice;
  final double discount;
  final double subtotal;

  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.purchasePrice,
    required this.discount,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        transactionId,
        productId,
        productName,
        qty,
        price,
        purchasePrice,
        discount,
        subtotal,
      ];
}
