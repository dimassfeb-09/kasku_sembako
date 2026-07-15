import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> checkout(
    List<CartItemEntity> cartItems,
    String paymentMethod,
    double discount,
    double tax,
    String? customerId,
  );
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, void>> voidTransaction(String transactionId);
}
