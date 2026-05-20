import 'package:equatable/equatable.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  const LoadReportsEvent(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}

class ExportPdfEvent extends ReportEvent {}

class ExportExcelEvent extends ReportEvent {}

class VoidTransactionEvent extends ReportEvent {
  final String transactionId;
  const VoidTransactionEvent(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<TransactionEntity> transactions;
  final DateTime startDate;
  final DateTime endDate;

  final double totalOmset;
  final double totalHpp;
  final double totalProfit;
  final int voidCount;

  ReportLoaded(this.transactions, this.startDate, this.endDate)
    : voidCount = transactions.where((t) => t.status == 'VOID').length,
      totalOmset = transactions
          .where((t) => t.status != 'VOID')
          .fold(0.0, (sum, t) => sum + t.totalAmount),
      totalHpp = transactions.where((t) => t.status != 'VOID').fold(0.0, (
        sum,
        t,
      ) {
        return sum +
            t.items.fold(
              0.0,
              (itemSum, item) => itemSum + (item.purchasePrice * item.qty),
            );
      }),
      totalProfit = transactions.where((t) => t.status != 'VOID').fold(0.0, (
        sum,
        t,
      ) {
        final hpp = t.items.fold(
          0.0,
          (itemSum, item) => itemSum + (item.purchasePrice * item.qty),
        );
        return sum + (t.totalAmount - hpp);
      });

  @override
  List<Object?> get props => [
    transactions,
    startDate,
    endDate,
    totalOmset,
    totalHpp,
    totalProfit,
    voidCount,
  ];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
  @override
  List<Object?> get props => [message];
}

class ReportExporting extends ReportState {}

class ReportExportSuccess extends ReportState {
  final String message;
  const ReportExportSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ReportExportError extends ReportState {
  final String message;
  const ReportExportError(this.message);
  @override
  List<Object?> get props => [message];
}
