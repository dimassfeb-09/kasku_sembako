import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/wholesale_price_usecases.dart';
import 'wholesale_price_event_state.dart';

class WholesalePriceBloc
    extends Bloc<WholesalePriceEvent, WholesalePriceState> {
  final GetWholesalePricesUseCase getWholesalePricesUseCase;
  final InsertWholesalePriceUseCase insertWholesalePriceUseCase;
  final DeleteWholesalePriceUseCase deleteWholesalePriceUseCase;

  WholesalePriceBloc({
    required this.getWholesalePricesUseCase,
    required this.insertWholesalePriceUseCase,
    required this.deleteWholesalePriceUseCase,
  }) : super(WholesalePriceInitial()) {
    on<LoadWholesalePricesEvent>(_onLoadWholesalePrices);
    on<AddWholesalePriceEvent>(_onAddWholesalePrice);
    on<DeleteWholesalePriceEvent>(_onDeleteWholesalePrice);
  }

  Future<void> _onLoadWholesalePrices(
    LoadWholesalePricesEvent event,
    Emitter<WholesalePriceState> emit,
  ) async {
    emit(WholesalePriceLoading());
    final result = await getWholesalePricesUseCase(event.productId);
    result.fold(
      (failure) => emit(WholesalePriceError(failure.message)),
      (prices) => emit(WholesalePriceLoaded(prices)),
    );
  }

  Future<void> _onAddWholesalePrice(
    AddWholesalePriceEvent event,
    Emitter<WholesalePriceState> emit,
  ) async {
    emit(WholesalePriceLoading());
    final result = await insertWholesalePriceUseCase(event.wholesalePrice);
    result.fold(
      (failure) => emit(WholesalePriceError(failure.message)),
      (_) => emit(
        const WholesalePriceOperationSuccess('Harga grosir ditambahkan'),
      ),
    );
  }

  Future<void> _onDeleteWholesalePrice(
    DeleteWholesalePriceEvent event,
    Emitter<WholesalePriceState> emit,
  ) async {
    emit(WholesalePriceLoading());
    final result = await deleteWholesalePriceUseCase(event.id);
    result.fold(
      (failure) => emit(WholesalePriceError(failure.message)),
      (_) => emit(const WholesalePriceOperationSuccess('Harga grosir dihapus')),
    );
  }
}
