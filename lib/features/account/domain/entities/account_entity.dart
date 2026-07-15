import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt];
}
