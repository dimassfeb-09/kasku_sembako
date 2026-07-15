import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final double totalToday;
  final double totalThisMonth;
  final Map<String, List<ExpenseEntity>> groupedByDate;

  const ExpenseLoaded({
    required this.expenses,
    required this.totalToday,
    required this.totalThisMonth,
    required this.groupedByDate,
  });

  @override
  List<Object?> get props => [
    expenses,
    totalToday,
    totalThisMonth,
    groupedByDate,
  ];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseActionSuccess extends ExpenseState {
  final String message;

  const ExpenseActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
