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

  /// Failed PIN attempts before a lockout starts.
  static const int _lockoutThreshold = 5;

  /// Lockout duration doubles each additional failure past the threshold,
  /// capped at 30 minutes, so a shared-device PIN can't be brute-forced by
  /// simple retry against the live login screen.
  static const int _baseLockoutSeconds = 30;
  static const int _maxLockoutSeconds = 1800;

  @override
  Future<UserModel> login(String username, String pin) async {
    final query = db.select(db.users)
      ..where((u) => u.username.equals(username));
    final userResult = await query.getSingleOrNull();

    // Same generic error for "no such user" and "wrong PIN" below, so the
    // error message alone never reveals whether a username exists.
    const invalidCredentials = AuthException('Username atau PIN salah.');

    if (userResult == null) {
      throw invalidCredentials;
    }

    final now = DateTime.now();
    if (userResult.lockedUntil != null &&
        userResult.lockedUntil!.isAfter(now)) {
      final remaining = userResult.lockedUntil!.difference(now).inSeconds;
      throw AuthException(
        'Terlalu banyak percobaan gagal. Coba lagi dalam $remaining detik.',
      );
    }

    final pinMatches = await _verifyPin(userResult, pin);
    if (!pinMatches) {
      await _recordFailedAttempt(userResult);
      throw invalidCredentials;
    }

    await _resetFailedAttempts(userResult);

    if (!userResult.isActive) {
      throw const AuthException('Akun Anda tidak aktif.');
    }
    return UserModel.fromDrift(userResult);
  }

  /// Verifies [pin] against [user]'s stored hash. Rows created before salted
  /// hashing existed (schema v5) have a null `pinSalt` — those are verified
  /// against the legacy unsalted SHA-256 hash and, on success, transparently
  /// upgraded to a salted PBKDF2 hash so no PIN reset is ever required.
  Future<bool> _verifyPin(User user, String pin) async {
    if (user.pinSalt != null) {
      final hashed = PinUtils.hashPinWithSalt(pin, user.pinSalt!);
      return hashed == user.pinHash;
    }

    final legacyMatches = PinUtils.legacyHashPin(pin) == user.pinHash;
    if (legacyMatches) {
      final newSalt = PinUtils.generateSalt();
      final newHash = PinUtils.hashPinWithSalt(pin, newSalt);
      await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
        UsersCompanion(pinHash: Value(newHash), pinSalt: Value(newSalt)),
      );
    }
    return legacyMatches;
  }

  Future<void> _recordFailedAttempt(User user) async {
    final attempts = user.failedPinAttempts + 1;
    DateTime? lockedUntil;
    if (attempts >= _lockoutThreshold) {
      final lockSeconds =
          (_baseLockoutSeconds * (1 << (attempts - _lockoutThreshold))).clamp(
            _baseLockoutSeconds,
            _maxLockoutSeconds,
          );
      lockedUntil = DateTime.now().add(Duration(seconds: lockSeconds));
    }
    await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(
        failedPinAttempts: Value(attempts),
        lockedUntil: Value(lockedUntil),
      ),
    );
  }

  Future<void> _resetFailedAttempts(User user) async {
    if (user.failedPinAttempts == 0 && user.lockedUntil == null) return;
    await (db.update(db.users)..where((u) => u.id.equals(user.id))).write(
      const UsersCompanion(
        failedPinAttempts: Value(0),
        lockedUntil: Value(null),
      ),
    );
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
    final salt = PinUtils.generateSalt();
    final hashedPin = PinUtils.hashPinWithSalt(pin, salt);
    final userId = const Uuid().v4();
    final newUser = UsersCompanion.insert(
      id: userId,
      username: username,
      pinHash: hashedPin,
      pinSalt: Value(salt),
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
