import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;
  GetCategoriesUseCase(this.repository);
  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await repository.getCategories();
  }
}

class InsertCategoryUseCase {
  final CategoryRepository repository;
  InsertCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(CategoryEntity category) async {
    return await repository.insertCategory(category);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;
  UpdateCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(CategoryEntity category) async {
    return await repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCategory(id);
  }
}
