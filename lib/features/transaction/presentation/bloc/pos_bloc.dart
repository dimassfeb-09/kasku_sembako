import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/held_cart_entity.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../../wholesale_price/domain/usecases/wholesale_price_usecases.dart';
import 'pos_event_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final CheckoutUseCase checkoutUseCase;
  final GetWholesalePricesUseCase getWholesalePricesUseCase;
  final AppDatabase database;

  /// Evaluated fresh on every add-to-cart, not cached at construction time —
  /// PosBloc is built once at app startup, before SubscriptionCubit has
  /// finished its first async load, so a cached bool would be frozen false
  /// for the whole session regardless of actual entitlement.
  final bool Function() isWholesaleAllowed;
  final bool Function() isPro;

  PosBloc({
    required this.checkoutUseCase,
    required this.getWholesalePricesUseCase,
    required this.database,
    bool Function()? isWholesaleAllowed,
    bool Function()? isPro,
  }) : isWholesaleAllowed = isWholesaleAllowed ?? _alwaysFalse,
       isPro = isPro ?? _alwaysFalse,
       super(PosInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemQtyEvent>(_onUpdateCartItemQty);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<SetDiscountEvent>(_onSetDiscount);
    on<SetTaxEvent>(_onSetTax);
    on<CheckoutEvent>(_onCheckout);
    on<HoldCartEvent>(_onHoldCart);
    on<ResumeCartEvent>(_onResumeCart);
    on<DeleteHeldCartEvent>(_onDeleteHeldCart);
    on<LoadHeldCartsEvent>(_onLoadHeldCarts);
  }

  static bool _alwaysFalse() => false;

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<PosState> emit,
  ) async {
    final updatedCart = List<CartItemEntity>.from(state.cartItems);
    final existingIndex = updatedCart.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = updatedCart[existingIndex];
      final nextQty = existingItem.quantity + 1;
      if (event.product.trackStock && nextQty > event.product.stock) {
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
      if (event.product.trackStock && event.product.stock < 1) {
        emit(PosError('Stok habis', state));
        return;
      }
      // Ambil Harga Grosir hanya jika Pro
      final prices = isWholesaleAllowed()
          ? (await getWholesalePricesUseCase(
              event.product.id,
            )).fold((l) => [], (r) => r)
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
        heldCarts: state.heldCarts,
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

    if (event.product.trackStock && event.quantity > event.product.stock) {
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
          heldCarts: state.heldCarts,
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
        heldCarts: state.heldCarts,
      ),
    );
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    emit(
      PosUpdated(
        cartItems: [],
        selectedCustomer: null,
        discount: 0,
        tax: 0,
        heldCarts: state.heldCarts,
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
        heldCarts: state.heldCarts,
      ),
    );
  }

  Future<void> _onHoldCart(HoldCartEvent event, Emitter<PosState> emit) async {
    if (state.cartItems.isEmpty) {
      emit(PosError('Keranjang kosong, tidak ada yang bisa ditahan', state));
      return;
    }

    final id = const Uuid().v4();
    final itemsJson = cartItemsToJson(state.cartItems);

    await database
        .into(database.heldCarts)
        .insert(
          HeldCartsCompanion.insert(
            id: id,
            note: Value(event.note),
            itemsJson: itemsJson,
            createdAt: DateTime.now(),
          ),
        );

    final heldCarts = await _loadHeldCartsFromDb();

    emit(
      PosUpdated(
        cartItems: [],
        selectedCustomer: null,
        discount: 0,
        tax: 0,
        heldCarts: heldCarts,
      ),
    );
  }

  Future<void> _onResumeCart(
    ResumeCartEvent event,
    Emitter<PosState> emit,
  ) async {
    final query = database.select(database.heldCarts)
      ..where((h) => h.id.equals(event.heldCartId));
    final row = await query.getSingleOrNull();
    if (row == null) {
      emit(PosError('Pesanan tertunda tidak ditemukan', state));
      return;
    }

    final heldItems = cartItemsFromJson(row.itemsJson);
    final updatedCart = List<CartItemEntity>.from(state.cartItems);

    for (final item in heldItems) {
      final existingIdx = updatedCart.indexWhere(
        (e) => e.product.id == item.product.id,
      );
      if (existingIdx >= 0) {
        updatedCart[existingIdx] = updatedCart[existingIdx].copyWith(
          quantity: updatedCart[existingIdx].quantity + item.quantity,
        );
      } else {
        updatedCart.add(item);
      }
    }

    await (database.delete(
      database.heldCarts,
    )..where((h) => h.id.equals(event.heldCartId))).go();

    final heldCarts = await _loadHeldCartsFromDb();

    emit(
      PosUpdated(
        cartItems: updatedCart,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: heldCarts,
      ),
    );
  }

  Future<void> _onDeleteHeldCart(
    DeleteHeldCartEvent event,
    Emitter<PosState> emit,
  ) async {
    await (database.delete(
      database.heldCarts,
    )..where((h) => h.id.equals(event.heldCartId))).go();

    final heldCarts = await _loadHeldCartsFromDb();

    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: heldCarts,
      ),
    );
  }

  Future<void> _onLoadHeldCarts(
    LoadHeldCartsEvent event,
    Emitter<PosState> emit,
  ) async {
    final heldCarts = await _loadHeldCartsFromDb();

    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: state.discount,
        tax: state.tax,
        heldCarts: heldCarts,
      ),
    );
  }

  Future<List<HeldCartEntity>> _loadHeldCartsFromDb() async {
    final rows =
        await (database.select(database.heldCarts)..orderBy([
              (h) => OrderingTerm(
                expression: h.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();

    return rows.map((row) {
      return HeldCartEntity(
        id: row.id,
        note: row.note,
        items: cartItemsFromJson(row.itemsJson),
        createdAt: row.createdAt,
      );
    }).toList();
  }

  void _onSetDiscount(SetDiscountEvent event, Emitter<PosState> emit) {
    emit(
      PosUpdated(
        cartItems: state.cartItems,
        selectedCustomer: state.selectedCustomer,
        discount: event.discount,
        tax: state.tax,
        heldCarts: state.heldCarts,
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
        heldCarts: state.heldCarts,
      ),
    );
  }

  Future<void> _onCheckout(CheckoutEvent event, Emitter<PosState> emit) async {
    if (state.cartItems.isEmpty) return;

    for (var item in state.cartItems) {
      if (item.product.trackStock && item.quantity > item.product.stock) {
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
      isPro: isPro(),
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
