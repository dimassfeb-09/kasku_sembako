import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/backup_schedule.dart';

class BackupScheduleLocalDataSource {
  final FlutterSecureStorage _storage;

  BackupScheduleLocalDataSource(this._storage);

  static const _keyEnabled = 'BACKUP_SCHEDULE_ENABLED';
  static const _keyInterval = 'BACKUP_SCHEDULE_INTERVAL';
  static const _keyDay = 'BACKUP_SCHEDULE_DAY';
  static const _keyTime = 'BACKUP_SCHEDULE_TIME';
  static const _keyLastRun = 'BACKUP_SCHEDULE_LAST_RUN';
  static const _keyLastUploadedHash = 'BACKUP_LAST_UPLOADED_HASH';
  static const _keyDeviceId = 'BACKUP_DEVICE_ID';
  static const _keyLastResultStatus = 'BACKUP_LAST_RESULT_STATUS';
  static const _keyLastResultAt = 'BACKUP_LAST_RESULT_AT';
  static const _keyLastResultMessage = 'BACKUP_LAST_RESULT_MESSAGE';

  Future<BackupSchedule> load() async {
    final enabled = await _storage.read(key: _keyEnabled);
    final interval = await _storage.read(key: _keyInterval);
    final day = await _storage.read(key: _keyDay);
    final time = await _storage.read(key: _keyTime);
    final lastRun = await _storage.read(key: _keyLastRun);

    return BackupSchedule(
      enabled: enabled == 'true',
      interval: interval != null
          ? BackupInterval.values.firstWhere(
              (e) => e.name == interval,
              orElse: () => BackupInterval.daily,
            )
          : BackupInterval.daily,
      day: day != null ? int.tryParse(day) : null,
      time: time ?? '02:00',
      lastRun: lastRun != null ? DateTime.tryParse(lastRun) : null,
    );
  }

  Future<void> save(BackupSchedule s) async {
    await _storage.write(key: _keyEnabled, value: s.enabled ? 'true' : 'false');
    await _storage.write(key: _keyInterval, value: s.interval.name);
    if (s.day != null) {
      await _storage.write(key: _keyDay, value: s.day.toString());
    } else {
      await _storage.delete(key: _keyDay);
    }
    await _storage.write(key: _keyTime, value: s.time);
    if (s.lastRun != null) {
      await _storage.write(
        key: _keyLastRun,
        value: s.lastRun!.toIso8601String(),
      );
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyEnabled);
    await _storage.delete(key: _keyInterval);
    await _storage.delete(key: _keyDay);
    await _storage.delete(key: _keyTime);
    await _storage.delete(key: _keyLastRun);
  }

  /// Content hash of the last successfully uploaded backup, used to skip
  /// re-uploading identical data.
  Future<String?> readLastUploadedHash() =>
      _storage.read(key: _keyLastUploadedHash);

  Future<void> saveLastUploadedHash(String hash) =>
      _storage.write(key: _keyLastUploadedHash, value: hash);

  /// Stable per-installation identifier, generated once and persisted.
  /// Used to label/distinguish backups uploaded from different devices.
  Future<String> readOrCreateDeviceId() async {
    final existing = await _storage.read(key: _keyDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await _storage.write(key: _keyDeviceId, value: id);
    return id;
  }

  Future<BackupResult?> readLastResult() async {
    final statusStr = await _storage.read(key: _keyLastResultStatus);
    final atStr = await _storage.read(key: _keyLastResultAt);
    if (statusStr == null || atStr == null) return null;
    final at = DateTime.tryParse(atStr);
    if (at == null) return null;
    final status = BackupResultStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => BackupResultStatus.error,
    );
    final message = await _storage.read(key: _keyLastResultMessage);
    return BackupResult(status: status, at: at, message: message);
  }

  Future<void> saveLastResult(BackupResult result) async {
    await _storage.write(key: _keyLastResultStatus, value: result.status.name);
    await _storage.write(
      key: _keyLastResultAt,
      value: result.at.toIso8601String(),
    );
    if (result.message != null) {
      await _storage.write(key: _keyLastResultMessage, value: result.message);
    } else {
      await _storage.delete(key: _keyLastResultMessage);
    }
  }
}
