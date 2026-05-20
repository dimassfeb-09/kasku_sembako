import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'di/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);
  await di.init();

  runApp(const App());
}
