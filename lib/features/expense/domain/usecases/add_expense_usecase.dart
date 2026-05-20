import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense) async {
    return await repository.addExpense(expense);
  }
}
