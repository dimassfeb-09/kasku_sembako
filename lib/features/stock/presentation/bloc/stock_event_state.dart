import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_history_entity.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();
  @override
  List<Object?> get props => [];
}

class LoadStockHistoryEvent extends StockEvent {
  final String productId;
  const LoadStockHistoryEvent(this.productId);
  @override
  List<Object?> get props => [productId];
}

class AdjustStockEvent extends StockEvent {
  final String productId;
  final String type;
  final int quantity;
  final String notes;

  const AdjustStockEvent({
    required this.productId,
    required this.type,
    required this.quantity,
    required this.notes,
  });

  @override
  List<Object?> get props => [productId, type, quantity, notes];
}

abstract class StockState extends Equatable {
  const StockState();
  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}
class StockLoading extends StockState {}
class StockHistoryLoaded extends StockState {
  final List<StockHistoryEntity> histories;
  const StockHistoryLoaded(this.histories);
  @override
  List<Object?> get props => [histories];
}
class StockOperationSuccess extends StockState {
  final String message;
  const StockOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class StockError extends StockState {
  final String message;
  const StockError(this.message);
  @override
  List<Object?> get props => [message];
}
