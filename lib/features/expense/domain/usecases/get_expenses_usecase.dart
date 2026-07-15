import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<Either<Failure, List<ExpenseEntity>>> call(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getExpenses(startDate, endDate);
  }
}
