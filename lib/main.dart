import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'app/app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/backup_dispatcher.dart';
import 'core/services/stock_alert_service.dart';
import 'di/injection.dart' as di;
import 'features/subscription/domain/repositories/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast rather than silently shipping a release build that forgot
  // --dart-define=API_BASE_URL=https://... and would otherwise send the
  // account JWT/password over plain HTTP to whatever the dev default
  // ("http://localhost:8080") resolves to on the user's device.
  if (kReleaseMode && !AppConstants.isApiBaseUrlSafeForRelease) {
    throw StateError(
      'API_BASE_URL must be a real https:// endpoint in release builds '
      '(got "${AppConstants.apiBaseUrl}"). Build with '
      '--dart-define=API_BASE_URL=https://your-api-domain.com',
    );
  }

  await Workmanager().initialize(callbackDispatcher);
  await initializeDateFormatting('id', null);
  await di.init();

  // Force the subscription repository's purchaseStream listener to start
  // now rather than lazily on first visit to the upgrade page, so a
  // purchase completed while the app was backgrounded/killed is still
  // caught as soon as the app reopens (see plan: purchase flow step 3).
  di.sl<SubscriptionRepository>();

  // Stock alert notification service
  di.sl<StockAlertService>().init();
  Workmanager().registerPeriodicTask(
    stockAlertTaskKey,
    stockAlertTaskKey,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );

  runApp(const App());
}
