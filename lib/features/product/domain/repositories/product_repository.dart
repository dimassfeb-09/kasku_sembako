import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductByBarcode(String barcode);
  Future<Either<Failure, void>> insertProduct(ProductEntity product);
  Future<Either<Failure, void>> updateProduct(ProductEntity product);
  Future<Either<Failure, void>> deleteProduct(String id);
}
