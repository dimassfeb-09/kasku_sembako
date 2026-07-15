import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name, super.color});

  factory CategoryModel.fromDrift(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      color: category.color,
    );
  }
}
