import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/product_usecases.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final InsertProductUseCase insertProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByBarcodeUseCase,
    required this.insertProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductByBarcodeEvent>(_onSearchProductByBarcode);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await getProductsUseCase();
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }

  Future<void> _onSearchProductByBarcode(SearchProductByBarcodeEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(SingleProductLoaded(product)),
    );
  }

  Future<void> _onAddProduct(AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await insertProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil ditambahkan')),
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await updateProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await deleteProductUseCase(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil dihapus')),
    );
  }
}
