import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object> get props => [];
}

class CheckAccountSessionEvent extends AccountEvent {}

/// Argument order deliberately matches the auth feature's identically-named
/// RegisterSubmittedEvent (auth_event.dart) - all four fields are Strings, so
/// diverging here would swap silently.
class RegisterSubmittedEvent extends AccountEvent {
  final String name;
  final String email;
  final String password;
  final String whatsapp;

  const RegisterSubmittedEvent(
    this.name,
    this.email,
    this.password,
    this.whatsapp,
  );

  @override
  List<Object> get props => [name, email, password, whatsapp];
}

class LoginSubmittedEvent extends AccountEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AccountEvent {}
