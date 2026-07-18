import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/core/constants/app_constants.dart';
import 'package:kasirku_sembako/features/auth/data/business_setup_gate.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late Map<String, String> store;

  setUp(() {
    storage = MockFlutterSecureStorage();
    store = {};

    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((i) async => store[i.namedArguments[#key] as String]);
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((i) async {
      store[i.namedArguments[#key] as String] =
          i.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((i) async {
      store.remove(i.namedArguments[#key] as String);
    });
  });

  // The gate only reaches the network when it must. No server is reachable in
  // tests, so any call fails into the fail-open path - which is exactly the
  // behaviour these cases pin.
  test('trusts an already-verified flag without touching the network', () async {
    store[AppConstants.isBusinessSetupComplete] = 'true';
    store[AppConstants.businessSetupVerifiedKey] = 'true';

    expect(await resolveBusinessSetupComplete(storage), isTrue);
    verifyNever(() => storage.delete(key: any(named: 'key')));
  });

  // The guardrail that matters most: a user with a real profile who launches
  // offline must never be demoted, or business setup would overwrite it.
  test('keeps a set flag when the server is unreachable', () async {
    store[AppConstants.isBusinessSetupComplete] = 'true';

    expect(await resolveBusinessSetupComplete(storage), isTrue);
    // The flag survives...
    expect(store[AppConstants.isBusinessSetupComplete], 'true');
    // ...and the run is not marked verified, so it retries next launch.
    expect(store.containsKey(AppConstants.businessSetupVerifiedKey), isFalse);
  });

  test('stays false when unreachable and no flag was ever set', () async {
    expect(await resolveBusinessSetupComplete(storage), isFalse);
    expect(store.containsKey(AppConstants.businessSetupVerifiedKey), isFalse);
  });
}
