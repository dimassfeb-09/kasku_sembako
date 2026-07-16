import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:workmanager/workmanager.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/database_json_codec.dart';
import '../../features/settings/domain/entities/backup_schedule.dart';
import '../../features/settings/data/datasources/backup_schedule_local_datasource.dart';
import '../../features/settings/data/datasources/cloud_backup_remote_datasource.dart';

const backupTaskKey = 'com.kasirku.autoBackup';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != backupTaskKey) return true;

    try {
      final storage = FlutterSecureStorage();
      final ds = BackupScheduleLocalDataSource(storage);
      final schedule = await ds.load();

      if (!schedule.enabled) return true;

      if (!_shouldRun(schedule)) return true;

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'kasirku_db.sqlite'));
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
      final db = AppDatabase.forTesting(NativeDatabase.createInBackground(file));

      final json = await exportDbToJson(db);
      await db.close();

      final token = await storage.read(key: AppConstants.sessionKey) ??
          await storage.read(key: AppConstants.accountAccessTokenKey);
      if (token == null) return true;

      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Authorization': 'Bearer $token'},
      ));

      final remote = CloudBackupRemoteDataSourceImpl(dio: dio);
      await remote.uploadBackup(json);

      final now = DateTime.now();
      await ds.save(schedule.copyWith(lastRun: now));

      return true;
    } catch (_) {
      return false;
    }
  });
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
