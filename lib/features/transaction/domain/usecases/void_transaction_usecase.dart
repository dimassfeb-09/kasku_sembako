import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class VoidTransactionUseCase {
  final TransactionRepository repository;

  VoidTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String transactionId) async {
    return await repository.voidTransaction(transactionId);
  }
}
