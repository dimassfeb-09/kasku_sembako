import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, int>> countToday() async {
    try {
      final count = await localDataSource.countToday();
      return Right(count);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghitung transaksi'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> checkout(
    List<CartItemEntity> cartItems,
    String paymentMethod,
    double discount,
    double tax,
    String? customerId,
  ) async {
    try {
      final transaction = await localDataSource.saveTransaction(
        cartItems,
        paymentMethod,
        discount,
        tax,
        customerId,
      );
      return Right(transaction);
    } catch (e) {
      return Left(
        DatabaseFailure('Gagal memproses transaksi: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await localDataSource.getTransactions(
        startDate,
        endDate,
      );
      return Right(transactions);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil data transaksi'));
    }
  }

  @override
  Future<Either<Failure, void>> voidTransaction(String transactionId) async {
    try {
      await localDataSource.voidTransaction(transactionId);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure('Gagal membatalkan transaksi: ${e.toString()}'),
      );
    }
  }
}
