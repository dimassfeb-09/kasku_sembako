import '../../../../core/database/app_database.dart';
import '../../domain/entities/debt_payment_entity.dart';

class DebtPaymentModel extends DebtPaymentEntity {
  const DebtPaymentModel({
    required super.id,
    required super.customerId,
    required super.amount,
    required super.paymentMethod,
    super.notes,
    required super.cashierId,
    required super.createdAt,
  });

  factory DebtPaymentModel.fromDrift(DebtPayment entry) {
    return DebtPaymentModel(
      id: entry.id,
      customerId: entry.customerId,
      amount: entry.amount,
      paymentMethod: entry.paymentMethod,
      notes: entry.notes,
      cashierId: entry.cashierId,
      createdAt: entry.createdAt,
    );
  }

  factory DebtPaymentModel.fromEntity(DebtPaymentEntity entity) {
    return DebtPaymentModel(
      id: entity.id,
      customerId: entity.customerId,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      cashierId: entity.cashierId,
      createdAt: entity.createdAt,
    );
  }
}
