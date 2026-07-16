import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../../wholesale_price/domain/usecases/wholesale_price_usecases.dart';
import 'pos_event_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final CheckoutUseCase checkoutUseCase;
  final GetWholesalePricesUseCase getWholesalePricesUseCase;
  final bool isWholesaleAllowed;

  PosBloc({
    required this.checkoutUseCase,
    required this.getWholesalePricesUseCase,
    this.isWholesaleAllowed = false,
  }) : super(PosInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemQtyEvent>(_onUpdateCartItemQty);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<SetDiscountEvent>(_onSetDiscount);
    on<SetTaxEvent>(_onSetTax);
    on<CheckoutEvent>(_onCheckout);
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<PosState> emit,
  ) async {
    final updatedCart = List<CartItemEntity>.from(state.cartItems);
    final existingIndex = updatedCart.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (existingIndex >= 0) {
      // Tambah QTY jika sudah ada
      final existingItem = updatedCart[existingIndex];
      final nextQty = existingItem.quantity + 1;
      if (nextQty > event.product.stock) {
        emit(
          PosError(
            'Stok tidak mencukupi. Sisa stok: ${event.product.stock}',
            state,
          ),
        );
        return;
      }
      updatedCart[existingIndex] = existingItem.copyWith(quantity: nextQty);
    } else {
      // Cek apakah stok awal mencukupi
      if (event.product.stock < 1) {
        emit(PosError('Stok habis', state));
        return;
      }
      // Ambil Harga Grosir hanya jika Pro
      final prices = isWholesaleAllowed
          ? (await getWholesalePricesUseCase(event.product.id)).fold((l) => [], (r) => r)
          : [];

      updatedCart.add(
        CartItemEntity(
          product: event.product,
          quantity: 1,
          wholesalePrices: List.from(prices),
        ),
      );
    }

    emit(
      PosUpdated(
        cartItems: updatedCart,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
      ),
    );
  }

  void _onUpdateCartItemQty(
    UpdateCartItemQtyEvent event,
    Emitter<PosState> emit,
  ) {
    if (event.quantity <= 0) {
      add(RemoveFromCartEvent(event.product));
      return;
    }

    if (event.quantity > event.product.stock) {
      emit(
        PosError(
          'Stok tidak mencukupi. Sisa stok: ${event.product.stock}',
          state,
        ),
      );
      return;
    }

    final updatedCart = List<CartItemEntity>.from(state.cartItems);
    final index = updatedCart.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (index >= 0) {
      updatedCart[index] = updatedCart[index].copyWith(
        quantity: event.quantity,
      );
      emit(
        PosUpdated(
          cartItems: updatedCart,
          selectedCustomer: state.selectedCustomer,
          discount: state.discount,
          tax: state.tax,
        ),
      );
    }
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<PosState> emit) {
    final updatedCart = List<CartItemEntity>.from(state.cartItems);
    updatedCart.removeWhere((item) => item.product.id == event.product.id);

    emit(
      PosUpdated(
        cartItems: updatedCart,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
      ),
    );
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    emit(
      const PosUpdated(
        cartItems: [],
        selectedCustomer: null,
        discount: 0,
        tax: 0,
      ),
    );
  }

  void _onSelectCustomer(SelectCustomerEvent event, Emitter<PosState> emit) {
    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: event.customer,
        discount: state.discount,
        tax: state.tax,
      ),
    );
  }

  void _onSetDiscount(SetDiscountEvent event, Emitter<PosState> emit) {
    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: event.discount,
        tax: state.tax,
      ),
    );
  }

  void _onSetTax(SetTaxEvent event, Emitter<PosState> emit) {
    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: event.tax,
      ),
    );
  }

  Future<void> _onCheckout(CheckoutEvent event, Emitter<PosState> emit) async {
    if (state.cartItems.isEmpty) return;

    // Validasi stok terlebih dahulu sebelum memproses checkout
    for (var item in state.cartItems) {
      if (item.quantity > item.product.stock) {
        emit(
          PosError(
            'Stok produk "${item.product.name}" tidak mencukupi (Tersedia: ${item.product.stock}, Diminta: ${item.quantity}).',
            state,
          ),
        );
        return;
      }
    }

    emit(PosCheckoutLoading(state));

    final result = await checkoutUseCase(
      cartItems: state.cartItems,
      paymentMethod: event.paymentMethod,
      discount: state.discount,
      tax: state.tax,
      customerId: state.selectedCustomer?.id,
      cashReceived: event.cashReceived,
    );

    result.fold((failure) => emit(PosError(failure.message, state)), (
      transaction,
    ) {
      emit(PosCheckoutSuccess(transaction, state));
      // Clear cart setelah sukses
      add(ClearCartEvent());
    });
  }
}
