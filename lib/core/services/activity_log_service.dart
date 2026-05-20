import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../constants/app_constants.dart';

class ActivityLogService {
  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;

  ActivityLogService(this._db, this._secureStorage);

  /// Mencatat log aktivitas baru ke database
  Future<void> log({
    required String action,
    required String description,
    String? userId,
  }) async {
    try {
      // Dapatkan User ID yang sedang aktif jika tidak disediakan
      final activeUserId =
          userId ??
          await _secureStorage.read(key: AppConstants.currentUserIdKey) ??
          'admin_id';

      await _db
          .into(_db.activityLogs)
          .insert(
            ActivityLogsCompanion.insert(
              id: const Uuid().v4(),
              userId: activeUserId,
              action: action,
              description: description,
              createdAt: DateTime.now(),
            ),
          );
    } catch (e) {
      // Kegagalan pencatatan log tidak boleh menghentikan alur utama aplikasi
      if (kDebugMode) {
        debugPrint('Gagal menulis log aktivitas: $e');
      }
    }
  }
}
