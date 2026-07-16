import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class CheckSessionEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const RegisterSubmittedEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}
