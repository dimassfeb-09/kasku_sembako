import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await localDataSource.getProducts();
      return Right(products);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil daftar produk'));
    }
  }

  @override
  Future<Either<Failure, int>> countProducts() async {
    try {
      final count = await localDataSource.countProducts();
      return Right(count);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghitung produk'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductByBarcode(
    String barcode,
  ) async {
    try {
      final product = await localDataSource.getProductByBarcode(barcode);
      return Right(product);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil produk'));
    }
  }

  @override
  Future<Either<Failure, void>> insertProduct(ProductEntity product) async {
    try {
      try {
        final existing = await localDataSource.getProductByBarcode(
          product.barcode,
        );
        if (existing.isActive) {
          return const Left(
            DatabaseFailure('Barcode sudah terdaftar untuk produk lain'),
          );
        } else {
          return const Left(
            DatabaseFailure('Barcode sudah terdaftar untuk produk non-aktif'),
          );
        }
      } catch (_) {
        // Expected if not found
      }

      final productModel = ProductModel(
        id: product.id,
        barcode: product.barcode,
        name: product.name,
        categoryId: product.categoryId,
        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,
        stock: product.stock,
        unit: product.unit,
        imagePath: product.imagePath,
        isActive: product.isActive,
      );
      await localDataSource.insertProduct(productModel);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menambahkan produk'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product) async {
    try {
      try {
        final existing = await localDataSource.getProductByBarcode(
          product.barcode,
        );
        if (existing.id != product.id) {
          return const Left(
            DatabaseFailure('Barcode sudah terdaftar untuk produk lain'),
          );
        }
      } catch (_) {
        // Expected if not found
      }

      final productModel = ProductModel(
        id: product.id,
        barcode: product.barcode,
        name: product.name,
        categoryId: product.categoryId,
        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,
        stock: product.stock,
        unit: product.unit,
        imagePath: product.imagePath,
        isActive: product.isActive,
      );
      await localDataSource.updateProduct(productModel);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengubah produk'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await localDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghapus produk'));
    }
  }
}
