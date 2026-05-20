import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String role;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, username, role, isActive];
}
