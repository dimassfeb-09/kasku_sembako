import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/domain/usecases/customer_usecases.dart';

abstract class QuickCustomerState extends Equatable {
  const QuickCustomerState();

  @override
  List<Object?> get props => [];
}

class QuickCustomerInitial extends QuickCustomerState {}

class QuickCustomerLoading extends QuickCustomerState {}

class QuickCustomerSuccess extends QuickCustomerState {
  final CustomerEntity customer;
  const QuickCustomerSuccess(this.customer);

  @override
  List<Object?> get props => [customer];
}

class QuickCustomerError extends QuickCustomerState {
  final String message;
  const QuickCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuickCustomerCubit extends Cubit<QuickCustomerState> {
  final InsertCustomerUseCase insertCustomerUseCase;

  QuickCustomerCubit({
    required this.insertCustomerUseCase,
  }) : super(QuickCustomerInitial());

  Future<void> addCustomer({
    required String name,
    required String? phone,
  }) async {
    if (name.isEmpty) {
      emit(const QuickCustomerError('Nama pelanggan tidak boleh kosong.'));
      return;
    }

    emit(QuickCustomerLoading());

    final id = const Uuid().v4();
    final entity = CustomerEntity(
      id: id,
      name: name,
      phone: phone?.isNotEmpty == true ? phone : null,
      notes: null,
      debtAmount: 0.0,
    );

    final result = await insertCustomerUseCase(entity);

    result.fold(
      (failure) => emit(QuickCustomerError(failure.message)),
      (_) {
        emit(QuickCustomerSuccess(entity));
      },
    );
  }
}
