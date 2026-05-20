import '../../../../core/database/app_database.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    required super.isActive,
  });

  factory UserModel.fromDrift(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    );
  }
}
