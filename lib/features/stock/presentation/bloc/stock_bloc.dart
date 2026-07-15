import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/stock_usecases.dart';
import 'stock_event_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final GetStockHistoryUseCase getStockHistoryUseCase;
  final AdjustStockUseCase adjustStockUseCase;

  StockBloc({
    required this.getStockHistoryUseCase,
    required this.adjustStockUseCase,
  }) : super(StockInitial()) {
    on<LoadStockHistoryEvent>(_onLoadStockHistory);
    on<AdjustStockEvent>(_onAdjustStock);
  }

  Future<void> _onLoadStockHistory(
    LoadStockHistoryEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    final result = await getStockHistoryUseCase(event.productId);
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (histories) => emit(StockHistoryLoaded(histories)),
    );
  }

  Future<void> _onAdjustStock(
    AdjustStockEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(StockLoading());
    final result = await adjustStockUseCase(
      event.productId,
      event.type,
      event.quantity,
      event.notes,
    );
    result.fold(
      (failure) => emit(StockError(failure.message)),
      (_) => emit(const StockOperationSuccess('Stok berhasil disesuaikan')),
    );
  }
}
