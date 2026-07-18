import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:workmanager/workmanager.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/database_json_codec.dart';
import '../error/exceptions.dart';
// Both of these must stay free of di/injection.dart: this file runs in a
// background isolate with an empty get_it container.
import '../network/dio_client.dart';
import 'backup_payload_util.dart';
import '../../features/settings/domain/entities/backup_schedule.dart';
import '../../features/settings/data/datasources/backup_schedule_local_datasource.dart';
import '../../features/settings/data/datasources/cloud_backup_remote_datasource.dart';

const backupTaskKey = 'com.kasirku.autoBackup';
const stockAlertTaskKey = 'com.kasirku.stockAlert';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == stockAlertTaskKey) {
      return _checkStockAlert();
    }
    if (task != backupTaskKey) return true;
    return _runScheduledBackup();
  });
}

/// The single execution path for scheduled cloud backups - this is the only
/// place that actually uploads. A foreground Timer used to run the same
/// logic in parallel with this WorkManager task, causing duplicate uploads
/// every interval; that Timer no longer exists (see BackupSchedulerService).
Future<bool> _runScheduledBackup() async {
  final storage = FlutterSecureStorage();
  final ds = BackupScheduleLocalDataSource(storage);

  try {
    final schedule = await ds.load();
    if (!schedule.enabled || !_shouldRun(schedule)) return true;

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kasirku_db.sqlite'));
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    final db = AppDatabase.forTesting(NativeDatabase.createInBackground(file));

    final json = await exportDbToJson(db);
    await db.close();

    final compressed = BackupPayloadUtil.compress(json);
    final now = DateTime.now();

    final lastHash = await ds.readLastUploadedHash();
    if (lastHash == compressed.contentHash) {
      await ds.save(schedule.copyWith(lastRun: now));
      await ds.saveLastResult(
        BackupResult(status: BackupResultStatus.skippedUnchanged, at: now),
      );
      return true;
    }

    final token =
        await storage.read(key: AppConstants.sessionKey) ??
        await storage.read(key: AppConstants.accountAccessTokenKey);
    if (token == null) {
      await ds.saveLastResult(
        BackupResult(
          status: BackupResultStatus.authExpired,
          at: now,
          message:
              'Silakan masuk ke akun toko untuk melanjutkan backup otomatis.',
        ),
      );
      return true;
    }

    // Built here rather than resolved from get_it: this runs in WorkManager's
    // background isolate, where di.init() never ran and the container is
    // empty. buildDio and the datasource take only isolate-safe args.
    //
    // Going through buildDio is the point: its interceptor refreshes an
    // expired access token. A bare Dio with a static Authorization header
    // used to report authExpired here even when the refresh token was valid.
    final remote = CloudBackupRemoteDataSourceImpl(dio: buildDio(storage));
    final deviceId = await ds.readOrCreateDeviceId();

    try {
      await remote.uploadBackup(
        gzipBytes: compressed.gzipBytes,
        contentHash: compressed.contentHash,
        deviceId: deviceId,
      );
    } on AuthException {
      // Only reached once the interceptor's refresh attempt has itself failed.
      await ds.saveLastResult(
        BackupResult(
          status: BackupResultStatus.authExpired,
          at: now,
          message:
              'Sesi berakhir. Silakan masuk kembali untuk melanjutkan backup otomatis.',
        ),
      );
      return true;
    }

    await ds.saveLastUploadedHash(compressed.contentHash);
    await ds.save(schedule.copyWith(lastRun: now));
    await ds.saveLastResult(
      BackupResult(status: BackupResultStatus.success, at: now),
    );

    return true;
  } catch (e) {
    await ds.saveLastResult(
      BackupResult(
        status: BackupResultStatus.error,
        at: DateTime.now(),
        message: e.toString(),
      ),
    );
    return false;
  }
}

Future<bool> _checkStockAlert() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kasirku_db.sqlite'));
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;
    final db = AppDatabase.forTesting(NativeDatabase.createInBackground(file));

    final rows = await db.select(db.products).get();
    final lowStock = rows
        .where((p) => p.trackStock && p.stock <= (p.minStock ?? 5))
        .toList();
    await db.close();

    if (lowStock.isEmpty) return true;

    final plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: DarwinInitializationSettings(),
      ),
    );

    if (lowStock.length == 1) {
      final p = lowStock.first;
      await plugin.show(
        id: 0,
        title: 'Stok Menipis',
        body: '${p.name} — Sisa ${p.stock} ${p.unit} (min. ${p.minStock ?? 5})',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_alert',
            'Peringatan Stok',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } else {
      await plugin.show(
        id: 0,
        title: 'Stok Menipis',
        body: '${lowStock.length} produk hampir habis',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_alert',
            'Peringatan Stok',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
    return true;
  } catch (_) {
    return false;
  }
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
