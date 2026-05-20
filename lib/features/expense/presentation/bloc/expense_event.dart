import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseEntity expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}
