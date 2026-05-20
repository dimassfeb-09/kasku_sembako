import 'package:equatable/equatable.dart';
import '../../domain/entities/debt_payment_entity.dart';

abstract class DebtEvent extends Equatable {
  const DebtEvent();
  @override
  List<Object?> get props => [];
}

class LoadDebtPaymentsEvent extends DebtEvent {
  final String? customerId;
  const LoadDebtPaymentsEvent({this.customerId});
  @override
  List<Object?> get props => [customerId];
}

class PayDebtEvent extends DebtEvent {
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String? notes;

  const PayDebtEvent({
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, amount, paymentMethod, notes];
}

abstract class DebtState extends Equatable {
  const DebtState();
  @override
  List<Object?> get props => [];
}

class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

class DebtPaymentsLoaded extends DebtState {
  final List<DebtPaymentEntity> payments;
  const DebtPaymentsLoaded(this.payments);
  @override
  List<Object?> get props => [payments];
}

class DebtOperationSuccess extends DebtState {
  final String message;
  const DebtOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DebtError extends DebtState {
  final String message;
  const DebtError(this.message);
  @override
  List<Object?> get props => [message];
}
