import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_event_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final InsertCategoryUseCase insertCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.insertCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await insertCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(const CategoryOperationSuccess('Kategori berhasil ditambahkan')),
    );
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await updateCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(const CategoryOperationSuccess('Kategori berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await deleteCategoryUseCase(event.id);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(const CategoryOperationSuccess('Kategori berhasil dihapus')),
    );
  }
}
