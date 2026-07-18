import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class HeldCartEntity extends Equatable {
  final String id;
  final String? note;
  final List<CartItemEntity> items;
  final DateTime createdAt;

  const HeldCartEntity({
    required this.id,
    this.note,
    required this.items,
    required this.createdAt,
  });

  int get totalQty => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  @override
  List<Object?> get props => [id, note, items, createdAt];
}
