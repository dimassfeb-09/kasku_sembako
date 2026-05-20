import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(DateTime startDate, DateTime endDate) async {
    return await repository.getTransactions(startDate, endDate);
  }
}
