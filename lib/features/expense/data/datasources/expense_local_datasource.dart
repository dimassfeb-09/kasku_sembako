import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class ExpenseLocalDataSource {
  Future<List<Expense>> getExpenses(DateTime startDate, DateTime endDate);
  Future<Expense> addExpense(ExpensesCompanion expense);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final AppDatabase db;

  ExpenseLocalDataSourceImpl(this.db);

  @override
  Future<List<Expense>> getExpenses(DateTime startDate, DateTime endDate) async {
    return await (db.select(db.expenses)
          ..where((e) => e.date.isBetweenValues(startDate, endDate))
          ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.desc)]))
        .get();
  }

  @override
  Future<Expense> addExpense(ExpensesCompanion expense) async {
    final expenseRow = await db.into(db.expenses).insertReturning(expense);
    return expenseRow;
  }

  @override
  Future<void> deleteExpense(String id) async {
    await (db.delete(db.expenses)..where((e) => e.id.equals(id))).go();
  }
}
