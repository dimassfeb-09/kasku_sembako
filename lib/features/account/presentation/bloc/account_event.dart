import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object> get props => [];
}

class CheckAccountSessionEvent extends AccountEvent {}

class RegisterSubmittedEvent extends AccountEvent {
  final String email;
  final String password;

  const RegisterSubmittedEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LoginSubmittedEvent extends AccountEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AccountEvent {}
