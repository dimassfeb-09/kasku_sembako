import 'package:equatable/equatable.dart';
import '../../domain/entities/wholesale_price_entity.dart';

abstract class WholesalePriceEvent extends Equatable {
  const WholesalePriceEvent();
  @override
  List<Object?> get props => [];
}

class LoadWholesalePricesEvent extends WholesalePriceEvent {
  final String productId;
  const LoadWholesalePricesEvent(this.productId);
  @override
  List<Object?> get props => [productId];
}

class AddWholesalePriceEvent extends WholesalePriceEvent {
  final WholesalePriceEntity wholesalePrice;
  const AddWholesalePriceEvent(this.wholesalePrice);
  @override
  List<Object?> get props => [wholesalePrice];
}

class DeleteWholesalePriceEvent extends WholesalePriceEvent {
  final String id;
  const DeleteWholesalePriceEvent(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class WholesalePriceState extends Equatable {
  const WholesalePriceState();
  @override
  List<Object?> get props => [];
}

class WholesalePriceInitial extends WholesalePriceState {}

class WholesalePriceLoading extends WholesalePriceState {}

class WholesalePriceLoaded extends WholesalePriceState {
  final List<WholesalePriceEntity> prices;
  const WholesalePriceLoaded(this.prices);
  @override
  List<Object?> get props => [prices];
}

class WholesalePriceOperationSuccess extends WholesalePriceState {
  final String message;
  const WholesalePriceOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class WholesalePriceError extends WholesalePriceState {
  final String message;
  const WholesalePriceError(this.message);
  @override
  List<Object?> get props => [message];
}
