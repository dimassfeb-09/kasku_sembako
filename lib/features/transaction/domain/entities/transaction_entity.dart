import 'package:equatable/equatable.dart';
import 'transaction_item_entity.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String receiptNumber;
  final String cashierId;
  final String? customerId;
  final double totalAmount;
  final double discount;
  final double tax;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<TransactionItemEntity> items;

  const TransactionEntity({
    required this.id,
    required this.receiptNumber,
    required this.cashierId,
    this.customerId,
    required this.totalAmount,
    required this.discount,
    required this.tax,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    cashierId,
    customerId,
    totalAmount,
    discount,
    tax,
    paymentMethod,
    status,
    createdAt,
    items,
  ];
}
