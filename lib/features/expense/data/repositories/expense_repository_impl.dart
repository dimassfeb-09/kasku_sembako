import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await localDataSource.getExpenses(startDate, endDate);
      return Right(expenses.map((e) => _mapToEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure('Gagal memuat data pengeluaran: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(
    ExpenseEntity expense,
  ) async {
    try {
      final companion = ExpensesCompanion(
        id: Value(expense.id),
        category: Value(expense.category),
        amount: Value(expense.amount),
        notes: Value(expense.notes),
        date: Value(expense.date),
        receiptPath: Value(expense.receiptPath),
      );
      final newExpense = await localDataSource.addExpense(companion);
      return Right(_mapToEntity(newExpense));
    } catch (e) {
      return Left(DatabaseFailure('Gagal menyimpan pengeluaran: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Gagal menghapus pengeluaran: $e'));
    }
  }

  ExpenseEntity _mapToEntity(Expense e) {
    return ExpenseEntity(
      id: e.id,
      category: e.category,
      amount: e.amount,
      notes: e.notes,
      date: e.date,
      receiptPath: e.receiptPath,
    );
  }
}
