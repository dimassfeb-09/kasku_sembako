import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/debt_payment_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, void>> insertCustomer(CustomerEntity customer);
  Future<Either<Failure, void>> updateCustomer(CustomerEntity customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
  Future<Either<Failure, List<DebtPaymentEntity>>> getDebtPayments(String? customerId);
  Future<Either<Failure, void>> saveDebtPayment(DebtPaymentEntity payment);
}
