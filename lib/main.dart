import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'di/injection.dart' as di;
import 'features/subscription/domain/repositories/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);
  await di.init();

  // Force the subscription repository's purchaseStream listener to start
  // now rather than lazily on first visit to the upgrade page, so a
  // purchase completed while the app was backgrounded/killed is still
  // caught as soon as the app reopens (see plan: purchase flow step 3).
  di.sl<SubscriptionRepository>();

  runApp(const App());
}
