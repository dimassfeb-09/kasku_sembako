import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/backup_schedule.dart';

class BackupScheduleLocalDataSource {
  final FlutterSecureStorage _storage;

  BackupScheduleLocalDataSource(this._storage);

  static const _keyEnabled = 'BACKUP_SCHEDULE_ENABLED';
  static const _keyInterval = 'BACKUP_SCHEDULE_INTERVAL';
  static const _keyDay = 'BACKUP_SCHEDULE_DAY';
  static const _keyTime = 'BACKUP_SCHEDULE_TIME';
  static const _keyLastRun = 'BACKUP_SCHEDULE_LAST_RUN';

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
      await _storage.write(key: _keyLastRun, value: s.lastRun!.toIso8601String());
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyEnabled);
    await _storage.delete(key: _keyInterval);
    await _storage.delete(key: _keyDay);
    await _storage.delete(key: _keyTime);
    await _storage.delete(key: _keyLastRun);
  }
}
