import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/debt_usecases.dart';
import '../../domain/entities/debt_payment_entity.dart';
import 'debt_event_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  final GetDebtPaymentsUseCase getDebtPaymentsUseCase;
  final SaveDebtPaymentUseCase saveDebtPaymentUseCase;

  DebtBloc({
    required this.getDebtPaymentsUseCase,
    required this.saveDebtPaymentUseCase,
  }) : super(DebtInitial()) {
    on<LoadDebtPaymentsEvent>(_onLoadDebtPayments);
    on<PayDebtEvent>(_onPayDebt);
  }

  Future<void> _onLoadDebtPayments(
    LoadDebtPaymentsEvent event,
    Emitter<DebtState> emit,
  ) async {
    emit(DebtLoading());
    final result = await getDebtPaymentsUseCase(event.customerId);
    result.fold(
      (failure) => emit(DebtError(failure.message)),
      (payments) => emit(DebtPaymentsLoaded(payments)),
    );
  }

  Future<void> _onPayDebt(PayDebtEvent event, Emitter<DebtState> emit) async {
    emit(DebtLoading());
    final payment = DebtPaymentEntity(
      id: const Uuid().v4(),
      customerId: event.customerId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
      notes: event.notes,
      cashierId: 'temp_cashier_id', // Akan ditimpa oleh datasource
      createdAt: DateTime.now(),
    );

    final result = await saveDebtPaymentUseCase(payment);
    result.fold(
      (failure) => emit(DebtError(failure.message)),
      (_) => emit(
        const DebtOperationSuccess('Pembayaran cicilan berhasil diproses'),
      ),
    );
  }
}
