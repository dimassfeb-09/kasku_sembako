import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);
  Future<Either<Failure, List<ProductEntity>>> call() async {
    return await repository.getProducts();
  }
}

class GetProductByBarcodeUseCase {
  final ProductRepository repository;
  GetProductByBarcodeUseCase(this.repository);
  Future<Either<Failure, ProductEntity>> call(String barcode) async {
    return await repository.getProductByBarcode(barcode);
  }
}

class InsertProductUseCase {
  final ProductRepository repository;
  InsertProductUseCase(this.repository);
  Future<Either<Failure, void>> call(ProductEntity product) async {
    return await repository.insertProduct(product);
  }
}

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);
  Future<Either<Failure, void>> call(ProductEntity product) async {
    return await repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteProduct(id);
  }
}
