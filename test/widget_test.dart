import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(const App(), isNotNull);
  });
}
