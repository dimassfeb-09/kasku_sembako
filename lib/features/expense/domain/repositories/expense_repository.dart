import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(DateTime startDate, DateTime endDate);
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String id);
}
