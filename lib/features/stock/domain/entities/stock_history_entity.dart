import 'package:equatable/equatable.dart';

class StockHistoryEntity extends Equatable {
  final String id;
  final String productId;
  final String type; // 'IN', 'OUT', 'ADJUSTMENT'
  final int quantity;
  final String notes;
  final DateTime createdAt;

  const StockHistoryEntity({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, productId, type, quantity, notes, createdAt];
}
