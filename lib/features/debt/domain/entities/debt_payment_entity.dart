import 'package:equatable/equatable.dart';

class DebtPaymentEntity extends Equatable {
  final String id;
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String? notes;
  final String cashierId;
  final DateTime createdAt;

  const DebtPaymentEntity({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
    required this.cashierId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerId,
    amount,
    paymentMethod,
    notes,
    cashierId,
    createdAt,
  ];
}
