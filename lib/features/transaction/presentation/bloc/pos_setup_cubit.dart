import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../category/domain/usecases/category_usecases.dart';
import '../../../customer/domain/usecases/customer_usecases.dart';

abstract class PosSetupState extends Equatable {
  const PosSetupState();
  @override
  List<Object?> get props => [];
}

class PosSetupInitial extends PosSetupState {}

class PosSetupLoading extends PosSetupState {}

class PosSetupLoaded extends PosSetupState {
  final List<CategoryEntity> categories;
  final List<CustomerEntity> customers;

  const PosSetupLoaded({
    required this.categories,
    required this.customers,
  });

  @override
  List<Object?> get props => [categories, customers];
}

class PosSetupError extends PosSetupState {
  final String message;
  const PosSetupError(this.message);
  @override
  List<Object?> get props => [message];
}

class PosSetupCubit extends Cubit<PosSetupState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetCustomersUseCase getCustomersUseCase;

  PosSetupCubit({
    required this.getCategoriesUseCase,
    required this.getCustomersUseCase,
  }) : super(PosSetupInitial());

  Future<void> load() async {
    emit(PosSetupLoading());
    final categoryResult = await getCategoriesUseCase();
    final customerResult = await getCustomersUseCase();

    categoryResult.fold(
      (failure) => emit(PosSetupError(failure.message)),
      (categories) {
        customerResult.fold(
          (failure) => emit(PosSetupError(failure.message)),
          (customers) {
            emit(PosSetupLoaded(
              categories: categories,
              customers: customers,
            ));
          },
        );
      },
    );
  }

  void updateCustomers(List<CustomerEntity> updatedCustomers) {
    if (state is PosSetupLoaded) {
      final loaded = state as PosSetupLoaded;
      emit(PosSetupLoaded(
        categories: loaded.categories,
        customers: updatedCustomers,
      ));
    }
  }
}
