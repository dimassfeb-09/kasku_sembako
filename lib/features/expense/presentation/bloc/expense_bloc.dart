import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  // We need to store the current date range filter if we want to reload after an action
  DateTime _currentStartDate = DateTime.now().subtract(
    const Duration(days: 30),
  );
  DateTime _currentEndDate = DateTime.now();

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseInitial()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;

    final result = await getExpensesUseCase(_currentStartDate, _currentEndDate);

    result.fold((failure) => emit(ExpenseError(failure.message)), (expenses) {
      final grouped = _groupExpenses(expenses);
      final totalToday = _calculateTotalToday(expenses);
      final totalThisMonth = _calculateTotalThisMonth(expenses);

      emit(
        ExpenseLoaded(
          expenses: expenses,
          totalToday: totalToday,
          totalThisMonth: totalThisMonth,
          groupedByDate: grouped,
        ),
      );
    });
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await addExpenseUseCase(event.expense);
    result.fold((failure) => emit(ExpenseError(failure.message)), (_) {
      emit(const ExpenseActionSuccess('Pengeluaran berhasil disimpan'));
      add(
        LoadExpensesEvent(
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
      );
    });
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final result = await deleteExpenseUseCase(event.id);
    result.fold((failure) => emit(ExpenseError(failure.message)), (_) {
      emit(const ExpenseActionSuccess('Pengeluaran berhasil dihapus'));
      add(
        LoadExpensesEvent(
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
      );
    });
  }

  Map<String, List<ExpenseEntity>> _groupExpenses(
    List<ExpenseEntity> expenses,
  ) {
    final Map<String, List<ExpenseEntity>> map = {};
    for (final expense in expenses) {
      // Create key as yyyy-MM-dd
      final key =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(expense);
    }
    return map;
  }

  double _calculateTotalToday(List<ExpenseEntity> expenses) {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _calculateTotalThisMonth(List<ExpenseEntity> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
