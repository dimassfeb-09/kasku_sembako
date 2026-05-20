import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/customer_usecases.dart';
import 'customer_event_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final InsertCustomerUseCase insertCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.insertCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getCustomersUseCase();
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomerLoaded(customers)),
    );
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await insertCustomerUseCase(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(
        const CustomerOperationSuccess('Pelanggan berhasil ditambahkan'),
      ),
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await updateCustomerUseCase(event.customer);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) =>
          emit(const CustomerOperationSuccess('Pelanggan berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await deleteCustomerUseCase(event.id);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(const CustomerOperationSuccess('Pelanggan berhasil dihapus')),
    );
  }
}
