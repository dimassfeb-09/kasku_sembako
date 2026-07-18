import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/held_cart_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../wholesale_price/domain/entities/wholesale_price_entity.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();
  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends PosEvent {
  final ProductEntity product;
  const AddToCartEvent(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateCartItemQtyEvent extends PosEvent {
  final ProductEntity product;
  final int quantity;
  const UpdateCartItemQtyEvent(this.product, this.quantity);
  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCartEvent extends PosEvent {
  final ProductEntity product;
  const RemoveFromCartEvent(this.product);
  @override
  List<Object?> get props => [product];
}

class ClearCartEvent extends PosEvent {}

class SelectCustomerEvent extends PosEvent {
  final CustomerEntity? customer;
  const SelectCustomerEvent(this.customer);
  @override
  List<Object?> get props => [customer];
}

class SetDiscountEvent extends PosEvent {
  final double discount;
  const SetDiscountEvent(this.discount);
  @override
  List<Object?> get props => [discount];
}

class SetTaxEvent extends PosEvent {
  final double tax;
  const SetTaxEvent(this.tax);
  @override
  List<Object?> get props => [tax];
}

class CheckoutEvent extends PosEvent {
  final String paymentMethod;
  final double cashReceived;
  const CheckoutEvent(this.paymentMethod, this.cashReceived);
  @override
  List<Object?> get props => [paymentMethod, cashReceived];
}

class HoldCartEvent extends PosEvent {
  final String? note;
  const HoldCartEvent(this.note);
  @override
  List<Object?> get props => [note];
}

class ResumeCartEvent extends PosEvent {
  final String heldCartId;
  const ResumeCartEvent(this.heldCartId);
  @override
  List<Object?> get props => [heldCartId];
}

class DeleteHeldCartEvent extends PosEvent {
  final String heldCartId;
  const DeleteHeldCartEvent(this.heldCartId);
  @override
  List<Object?> get props => [heldCartId];
}

class LoadHeldCartsEvent extends PosEvent {}

abstract class PosState extends Equatable {
  final List<CartItemEntity> cartItems;
  final CustomerEntity? selectedCustomer;
  final double discount;
  final double tax;
  final List<HeldCartEntity> heldCarts;

  const PosState({
    this.cartItems = const [],
    this.selectedCustomer,
    this.discount = 0.0,
    this.tax = 0.0,
    this.heldCarts = const [],
  });

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount + tax;

  @override
  List<Object?> get props => [
    cartItems,
    selectedCustomer,
    discount,
    tax,
    heldCarts,
  ];
}

class PosInitial extends PosState {}

class PosUpdated extends PosState {
  const PosUpdated({
    required super.cartItems,
    super.selectedCustomer,
    super.discount,
    super.tax,
    super.heldCarts,
  });
}

class PosCheckoutLoading extends PosState {
  PosCheckoutLoading(PosState state)
    : super(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: state.heldCarts,
      );
}

class PosCheckoutSuccess extends PosState {
  final TransactionEntity transaction;

  PosCheckoutSuccess(this.transaction, PosState state)
    : super(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: state.heldCarts,
      );
}

class PosError extends PosState {
  final String message;

  PosError(this.message, PosState state)
    : super(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: state.heldCarts,
      );
}

// ponytail: uses simplified JSON snapshot (product fields + wholesalePrices)
// instead of entity-backed serialization. Replace with proper codec if
// products need live price/stock syncing on resume.
String cartItemsToJson(List<CartItemEntity> items) {
  return jsonEncode(
    items
        .map(
          (item) => {
            'productId': item.product.id,
            'barcode': item.product.barcode,
            'productName': item.product.name,
            'categoryId': item.product.categoryId,
            'purchasePrice': item.product.purchasePrice,
            'sellingPrice': item.product.sellingPrice,
            'stock': item.product.stock,
            'unit': item.product.unit,
            'imagePath': item.product.imagePath,
            'isActive': item.product.isActive,
            'trackStock': item.product.trackStock,
            'minStock': item.product.minStock,
            'quantity': item.quantity,
            'wholesalePrices': item.wholesalePrices
                .map(
                  (wp) => {
                    'id': wp.id,
                    'productId': wp.productId,
                    'minQty': wp.minQty,
                    'price': wp.price,
                  },
                )
                .toList(),
            'unitPrice': item.unitPrice,
          },
        )
        .toList(),
  );
}

List<CartItemEntity> cartItemsFromJson(String json) {
  final list = jsonDecode(json) as List;
  return list.map((m) {
    final map = m as Map<String, dynamic>;
    return CartItemEntity(
      product: ProductEntity(
        id: map['productId'] as String,
        barcode: map['barcode'] as String,
        name: map['productName'] as String,
        categoryId: map['categoryId'] as String?,
        purchasePrice: (map['purchasePrice'] as num).toDouble(),
        sellingPrice: (map['sellingPrice'] as num).toDouble(),
        stock: (map['stock'] as num).toInt(),
        unit: map['unit'] as String,
        imagePath: map['imagePath'] as String?,
        isActive: map['isActive'] as bool,
        trackStock: map['trackStock'] as bool,
        minStock: (map['minStock'] as num?)?.toInt(),
      ),
      quantity: (map['quantity'] as num).toInt(),
      wholesalePrices: (map['wholesalePrices'] as List).map((w) {
        final wp = w as Map<String, dynamic>;
        return WholesalePriceEntity(
          id: wp['id'] as String,
          productId: wp['productId'] as String,
          minQty: (wp['minQty'] as num).toInt(),
          price: (wp['price'] as num).toDouble(),
        );
      }).toList(),
    );
  }).toList();
}
