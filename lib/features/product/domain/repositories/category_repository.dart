import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, void>> insertCategory(CategoryEntity category);
  Future<Either<Failure, void>> updateCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String id);
}
