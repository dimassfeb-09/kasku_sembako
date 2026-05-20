import 'package:equatable/equatable.dart';

class HomeMetrics extends Equatable {
  final double omset;
  final int trxCount;
  final double expenses;
  final int lowStock;

  const HomeMetrics({
    required this.omset,
    required this.trxCount,
    required this.expenses,
    required this.lowStock,
  });

  @override
  List<Object?> get props => [omset, trxCount, expenses, lowStock];
}
