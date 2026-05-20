import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../../debt/domain/entities/debt_payment_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';
import '../../../debt/data/models/debt_payment_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final customers = await localDataSource.getCustomers();
      return Right(customers);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil daftar pelanggan'));
    }
  }

  @override
  Future<Either<Failure, void>> insertCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        notes: customer.notes,
        debtAmount: customer.debtAmount,
      );
      await localDataSource.insertCustomer(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menambahkan pelanggan'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        notes: customer.notes,
        debtAmount: customer.debtAmount,
      );
      await localDataSource.updateCustomer(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengubah pelanggan'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await localDataSource.deleteCustomer(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghapus pelanggan'));
    }
  }

  @override
  Future<Either<Failure, List<DebtPaymentEntity>>> getDebtPayments(String? customerId) async {
    try {
      final results = await localDataSource.getDebtPayments(customerId);
      return Right(results);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil riwayat pembayaran cicilan'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDebtPayment(DebtPaymentEntity payment) async {
    try {
      final model = DebtPaymentModel.fromEntity(payment);
      await localDataSource.saveDebtPayment(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal memproses pembayaran cicilan'));
    }
  }
}
