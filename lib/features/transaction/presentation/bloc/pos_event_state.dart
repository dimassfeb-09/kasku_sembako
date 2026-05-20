import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../customer/domain/entities/customer_entity.dart';

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

abstract class PosState extends Equatable {
  final List<CartItemEntity> cartItems;
  final CustomerEntity? selectedCustomer;
  final double discount;
  final double tax;

  const PosState({
    this.cartItems = const [],
    this.selectedCustomer,
    this.discount = 0.0,
    this.tax = 0.0,
  });

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount + tax;

  @override
  List<Object?> get props => [cartItems, selectedCustomer, discount, tax];
}

class PosInitial extends PosState {}

class PosUpdated extends PosState {
  const PosUpdated({
    required List<CartItemEntity> cartItems,
    CustomerEntity? selectedCustomer,
    double discount = 0.0,
    double tax = 0.0,
  }) : super(
         cartItems: cartItems,
         selectedCustomer: selectedCustomer,
         discount: discount,
         tax: tax,
       );
}

class PosCheckoutLoading extends PosState {
  PosCheckoutLoading(PosState state)
    : super(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
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
      );
}
