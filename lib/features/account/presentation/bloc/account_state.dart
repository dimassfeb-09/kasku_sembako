import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSignedIn extends AccountState {
  final AccountEntity account;
  const AccountSignedIn(this.account);
  @override
  List<Object> get props => [account];
}

class AccountSignedOut extends AccountState {}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);
  @override
  List<Object> get props => [message];
}
