import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> insertCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase db;

  CategoryLocalDataSourceImpl({required this.db});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final categories = await db.select(db.categories).get();
    return categories.map((c) => CategoryModel.fromDrift(c)).toList();
  }

  @override
  Future<void> insertCategory(CategoryModel category) async {
    await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        id: category.id,
        name: category.name,
        color: Value(category.color),
      ),
    );
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await (db.update(db.categories)..where((c) => c.id.equals(category.id))).write(
      CategoriesCompanion(
        name: Value(category.name),
        color: Value(category.color),
      ),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
