import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {}

class AddCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  const AddCustomerEvent(this.customer);
  @override
  List<Object?> get props => [customer];
}

class UpdateCustomerEvent extends CustomerEvent {
  final CustomerEntity customer;
  const UpdateCustomerEvent(this.customer);
  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;
  const DeleteCustomerEvent(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  const CustomerLoaded(this.customers);
  @override
  List<Object?> get props => [customers];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  const CustomerOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
  @override
  List<Object?> get props => [message];
}
