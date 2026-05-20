import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/pin_utils.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String username, String pin);
  Future<void> cacheSession(UserModel user);
  Future<UserModel?> getCachedSession();
  Future<void> clearSession();
  Future<bool> hasUsers();
  Future<UserModel> registerFirstAdmin(String username, String pin);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase db;
  final FlutterSecureStorage secureStorage;
  final ActivityLogService logService;

  AuthLocalDataSourceImpl({
    required this.db,
    required this.secureStorage,
    required this.logService,
  });

  @override
  Future<UserModel> login(String username, String pin) async {
    final hashedPin = PinUtils.hashPin(pin);

    // Check if user exists
    final query = db.select(db.users)
      ..where((u) => u.username.equals(username))
      ..where((u) => u.pinHash.equals(hashedPin));

    final userResult = await query.getSingleOrNull();

    if (userResult != null) {
      if (!userResult.isActive) {
        throw const AuthException('Akun Anda tidak aktif.');
      }
      return UserModel.fromDrift(userResult);
    } else {
      throw const AuthException('Username atau PIN salah.');
    }
  }

  @override
  Future<void> cacheSession(UserModel user) async {
    await secureStorage.write(key: AppConstants.sessionKey, value: user.id);
    await secureStorage.write(
      key: AppConstants.currentUserIdKey,
      value: user.id,
    );
    await secureStorage.write(
      key: AppConstants.currentUserRoleKey,
      value: user.role,
    );

    // Log login sukses
    await logService.log(
      action: 'LOGIN',
      description: 'User ${user.username} berhasil masuk ke sistem.',
      userId: user.id,
    );
  }

  @override
  Future<void> clearSession() async {
    final userId = await secureStorage.read(key: AppConstants.currentUserIdKey);
    if (userId != null) {
      String username = 'User';
      try {
        final query = db.select(db.users)..where((u) => u.id.equals(userId));
        final userResult = await query.getSingleOrNull();
        if (userResult != null) {
          username = userResult.username;
        }
      } catch (_) {}

      await logService.log(
        action: 'LOGOUT',
        description: 'User $username keluar dari sistem.',
        userId: userId,
      );
    }

    await secureStorage.delete(key: AppConstants.sessionKey);
    await secureStorage.delete(key: AppConstants.currentUserIdKey);
    await secureStorage.delete(key: AppConstants.currentUserRoleKey);
  }

  @override
  Future<UserModel?> getCachedSession() async {
    final sessionId = await secureStorage.read(key: AppConstants.sessionKey);
    if (sessionId != null) {
      final query = db.select(db.users)..where((u) => u.id.equals(sessionId));
      final userResult = await query.getSingleOrNull();
      if (userResult != null && userResult.isActive) {
        return UserModel.fromDrift(userResult);
      } else {
        await clearSession(); // Invalid or inactive user
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> hasUsers() async {
    final query = db.select(db.users);
    final results = await query.get();
    return results.isNotEmpty;
  }

  @override
  Future<UserModel> registerFirstAdmin(String username, String pin) async {
    final hashedPin = PinUtils.hashPin(pin);
    final userId = const Uuid().v4();
    final newUser = UsersCompanion.insert(
      id: userId,
      username: username,
      pinHash: hashedPin,
      role: 'admin',
      isActive: const Value(true),
    );

    await db.into(db.users).insert(newUser);

    // Create permissions for the super admin
    final permId = const Uuid().v4();
    final newPerm = PermissionsCompanion.insert(
      id: permId,
      userId: userId,
      menuProduct: const Value(true),
      menuStock: const Value(true),
      menuReport: const Value(true),
      actionVoid: const Value(true),
    );
    await db.into(db.permissions).insert(newPerm);

    // Return the newly created user model
    final userResult = await (db.select(
      db.users,
    )..where((u) => u.id.equals(userId))).getSingle();
    return UserModel.fromDrift(userResult);
  }
}
