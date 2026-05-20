import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/debt_payment_entity.dart';
import '../../../customer/domain/repositories/customer_repository.dart';

class GetDebtPaymentsUseCase {
  final CustomerRepository repository;

  GetDebtPaymentsUseCase(this.repository);

  Future<Either<Failure, List<DebtPaymentEntity>>> call(String? customerId) {
    return repository.getDebtPayments(customerId);
  }
}

class SaveDebtPaymentUseCase {
  final CustomerRepository repository;

  SaveDebtPaymentUseCase(this.repository);

  Future<Either<Failure, void>> call(DebtPaymentEntity payment) {
    return repository.saveDebtPayment(payment);
  }
}
