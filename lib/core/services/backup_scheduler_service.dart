import 'package:workmanager/workmanager.dart';
import '../../di/injection.dart';
import '../../features/settings/domain/entities/backup_schedule.dart';
import '../../features/settings/data/datasources/backup_schedule_local_datasource.dart';
import 'backup_dispatcher.dart' show backupTaskKey;

/// Registers/cancels the background backup task with WorkManager. This is
/// the only place that mutates the WorkManager registration - the actual
/// upload logic (compress, hash, skip-if-unchanged, upload) lives solely in
/// backup_dispatcher.dart's callbackDispatcher, which WorkManager invokes on
/// its own periodic schedule. There is deliberately no in-process Timer here
/// anymore: a foreground Timer racing WorkManager's own execution caused
/// duplicate uploads on every interval.
class BackupSchedulerService {
  Future<void> init() async {
    final ds = BackupScheduleLocalDataSource(sl());
    final schedule = await ds.load();
    if (schedule.enabled) {
      await _register();
    }
  }

  Future<void> apply(BackupSchedule schedule) async {
    final ds = BackupScheduleLocalDataSource(sl());
    await ds.save(schedule);
    if (schedule.enabled) {
      await _register();
    } else {
      await Workmanager().cancelByUniqueName(backupTaskKey);
    }
  }

  Future<void> disable() async {
    await Workmanager().cancelByUniqueName(backupTaskKey);
    final ds = BackupScheduleLocalDataSource(sl());
    await ds.clear();
  }

  Future<void> _register() async {
    // The periodic frequency is fixed at 15 minutes (WorkManager's minimum);
    // the user-facing interval (hourly/daily/weekly/...) is evaluated inside
    // the dispatcher itself on every 15-minute tick, not here.
    await Workmanager().registerPeriodicTask(
      backupTaskKey,
      backupTaskKey,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
