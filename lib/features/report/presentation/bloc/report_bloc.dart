import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/export_service.dart';
import '../../../transaction/domain/usecases/get_transactions_usecase.dart';
import '../../../transaction/domain/usecases/void_transaction_usecase.dart';
import 'report_event_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final VoidTransactionUseCase voidTransactionUseCase;
  final ExportService exportService;

  ReportBloc({
    required this.getTransactionsUseCase,
    required this.voidTransactionUseCase,
    required this.exportService,
  }) : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ExportPdfEvent>(_onExportPdf);
    on<ExportExcelEvent>(_onExportExcel);
    on<ExportCsvEvent>(_onExportCsv);
    on<VoidTransactionEvent>(_onVoidTransaction);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await getTransactionsUseCase(event.startDate, event.endDate);

    result.fold((failure) => emit(ReportError(failure.message)), (data) {
      emit(ReportLoaded(data, event.startDate, event.endDate));
    });
  }

  Future<void> _onVoidTransaction(
    VoidTransactionEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) return;
    final currentState = state as ReportLoaded;

    emit(ReportLoading());
    final voidResult = await voidTransactionUseCase(event.transactionId);

    await voidResult.fold(
      (failure) async => emit(ReportError(failure.message)),
      (_) async {
        // Reload data after successful void
        final reloadResult = await getTransactionsUseCase(
          currentState.startDate,
          currentState.endDate,
        );
        reloadResult.fold((failure) => emit(ReportError(failure.message)), (
          data,
        ) {
          emit(
            ReportLoaded(data, currentState.startDate, currentState.endDate),
          );
        });
      },
    );
  }

  Future<void> _onExportPdf(
    ExportPdfEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) return;
    final currentState = state as ReportLoaded;
    if (currentState.transactions.isEmpty) return;

    emit(ReportExporting());
    try {
      await exportService.exportToPdf(
        currentState.transactions,
        currentState.startDate,
        currentState.endDate,
      );
      emit(const ReportExportSuccess("Berhasil mengekspor PDF"));
    } catch (e) {
      emit(ReportExportError("Gagal mengekspor PDF: ${e.toString()}"));
    }
    // Re-emit loaded state to keep UI active
    emit(currentState);
  }

  Future<void> _onExportCsv(
    ExportCsvEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) return;
    final currentState = state as ReportLoaded;
    if (currentState.transactions.isEmpty) return;

    emit(ReportExporting());
    try {
      final headers = ['Tanggal', 'No Struk', 'Kasir', 'Pembayaran', 'Total'];
      final rows = currentState.transactions
          .map(
            (t) => [
              DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
              t.receiptNumber,
              t.cashierId,
              t.paymentMethod,
              t.totalAmount.toStringAsFixed(0),
            ],
          )
          .toList();

      await exportService.exportToCsv(
        headers: headers,
        rows: rows,
        fileName: 'laporan_penjualan.csv',
      );
      emit(const ReportExportSuccess('Berhasil mengekspor CSV'));
    } catch (e) {
      emit(ReportExportError('Gagal mengekspor CSV: ${e.toString()}'));
    }
    emit(currentState);
  }

  Future<void> _onExportExcel(
    ExportExcelEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) return;
    final currentState = state as ReportLoaded;
    if (currentState.transactions.isEmpty) return;

    emit(ReportExporting());
    try {
      await exportService.exportToExcel(
        currentState.transactions,
        currentState.startDate,
        currentState.endDate,
      );
      emit(const ReportExportSuccess("Berhasil mengekspor Excel"));
    } catch (e) {
      emit(ReportExportError("Gagal mengekspor Excel: ${e.toString()}"));
    }
    // Re-emit loaded state to keep UI active
    emit(currentState);
  }
}
