import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengambil daftar kategori'));
    }
  }

  @override
  Future<Either<Failure, void>> insertCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel(
        id: category.id,
        name: category.name,
        color: category.color,
      );
      await localDataSource.insertCategory(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menambahkan kategori'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel(
        id: category.id,
        name: category.name,
        color: category.color,
      );
      await localDataSource.updateCategory(model);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal mengubah kategori'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure('Gagal menghapus kategori'));
    }
  }
}
