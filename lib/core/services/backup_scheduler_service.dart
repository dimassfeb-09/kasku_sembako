import 'dart:async';
import 'package:workmanager/workmanager.dart';
import '../../di/injection.dart';
import '../database/app_database.dart';
import '../database/database_json_codec.dart';
import '../../features/settings/domain/usecases/cloud_backup_usecases.dart';
import '../../features/settings/domain/entities/backup_schedule.dart';
import '../../features/settings/data/datasources/backup_schedule_local_datasource.dart';
import 'backup_dispatcher.dart' show backupTaskKey;

class BackupSchedulerService {
  Timer? _timer;
  BackupSchedule? _current;

  Future<void> init() async {
    final ds = BackupScheduleLocalDataSource(sl());
    _current = await ds.load();
    _apply();
  }

  Future<void> apply(BackupSchedule schedule) async {
    _current = schedule;
    final ds = BackupScheduleLocalDataSource(sl());
    await ds.save(schedule);
    _apply();
  }

  Future<void> disable() async {
    _timer?.cancel();
    _timer = null;
    _current = null;
    await Workmanager().cancelAll();
    final ds = BackupScheduleLocalDataSource(sl());
    await ds.clear();
  }

  void _apply() {
    _timer?.cancel();
    _timer = null;
    if (_current == null || !_current!.enabled) return;
    Workmanager().registerPeriodicTask(
      backupTaskKey,
      backupTaskKey,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _tick());
    _tick();
  }

  Future<void> _tick() async {
    final s = _current;
    if (s == null || !s.enabled) return;

    if (!_shouldRun(s)) return;

    try {
      final db = sl<AppDatabase>();
      final json = await exportDbToJson(db);
      final usecase = sl<UploadCloudBackupUseCase>();
      await usecase(json);

      final now = DateTime.now();
      final ds = BackupScheduleLocalDataSource(sl());
      await ds.save(s.copyWith(lastRun: now));
      _current = s.copyWith(lastRun: now);
    } catch (_) {}
  }

  bool _shouldRun(BackupSchedule s) {
    final now = DateTime.now();
    final last = s.lastRun;

    if (last == null) return true;

    final elapsed = now.difference(last);

    switch (s.interval) {
      case BackupInterval.hourly:
        return elapsed.inHours >= 1;

      case BackupInterval.daily:
        if (elapsed.inHours < 24) return false;
        return _timeMatch(s.time, now);

      case BackupInterval.weekly:
        if (elapsed.inDays < 7) return false;
        if (s.day != null && s.day != now.weekday) return false;
        return _timeMatch(s.time, now);

      case BackupInterval.biweekly:
        if (elapsed.inDays < 14) return false;
        if (s.day != null && s.day != now.weekday) return false;
        return _timeMatch(s.time, now);

      case BackupInterval.monthly:
        if (elapsed.inDays < 28) return false;
        if (s.day != null && s.day != now.day) return false;
        return _timeMatch(s.time, now);
    }
  }

  bool _timeMatch(String time, DateTime now) {
    final parts = time.split(':');
    if (parts.length != 2) return true;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return true;
    return now.hour == hour && now.minute >= minute && now.minute < minute + 15;
  }
}
