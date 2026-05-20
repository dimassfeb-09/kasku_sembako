import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class CheckSessionEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String username;
  final String pin;

  const LoginSubmittedEvent(this.username, this.pin);

  @override
  List<Object> get props => [username, pin];
}

class LogoutEvent extends AuthEvent {}

class RegisterFirstAdminEvent extends AuthEvent {
  final String username;
  final String pin;

  const RegisterFirstAdminEvent(this.username, this.pin);

  @override
  List<Object> get props => [username, pin];
}
