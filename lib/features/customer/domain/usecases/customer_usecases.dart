import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);
  Future<Either<Failure, List<CustomerEntity>>> call() async {
    return await repository.getCustomers();
  }
}

class InsertCustomerUseCase {
  final CustomerRepository repository;
  InsertCustomerUseCase(this.repository);
  Future<Either<Failure, void>> call(CustomerEntity customer) async {
    return await repository.insertCustomer(customer);
  }
}

class UpdateCustomerUseCase {
  final CustomerRepository repository;
  UpdateCustomerUseCase(this.repository);
  Future<Either<Failure, void>> call(CustomerEntity customer) async {
    return await repository.updateCustomer(customer);
  }
}

class DeleteCustomerUseCase {
  final CustomerRepository repository;
  DeleteCustomerUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCustomer(id);
  }
}
