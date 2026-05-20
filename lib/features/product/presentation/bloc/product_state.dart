import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class SingleProductLoaded extends ProductState {
  final ProductEntity product;
  const SingleProductLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  const ProductOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
