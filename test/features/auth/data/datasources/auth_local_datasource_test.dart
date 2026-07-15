import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kasirku_sembako/core/database/app_database.dart';
import 'package:kasirku_sembako/core/error/exceptions.dart';
import 'package:kasirku_sembako/core/services/activity_log_service.dart';
import 'package:kasirku_sembako/core/utils/pin_utils.dart';
import 'package:kasirku_sembako/features/auth/data/datasources/auth_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AppDatabase db;
  late AuthLocalDataSourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = AuthLocalDataSourceImpl(
      db: db,
      secureStorage: MockFlutterSecureStorage(),
      logService: ActivityLogService(db, MockFlutterSecureStorage()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedUser({
    required String id,
    required String username,
    required String pin,
    bool useSaltedHash = true,
  }) async {
    String pinHash;
    String? pinSalt;
    if (useSaltedHash) {
      pinSalt = PinUtils.generateSalt();
      pinHash = PinUtils.hashPinWithSalt(pin, pinSalt);
    } else {
      pinHash = PinUtils.legacyHashPin(pin);
      pinSalt = null;
    }
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: id,
            username: username,
            pinHash: pinHash,
            pinSalt: Value(pinSalt),
            role: 'admin',
          ),
        );
  }

  group('salted PIN login', () {
    test('succeeds with the correct PIN', () async {
      await seedUser(id: 'u1', username: 'admin', pin: '123456');

      final user = await datasource.login('admin', '123456');
      expect(user.username, 'admin');
    });

    test('fails with the wrong PIN using the generic error message', () async {
      await seedUser(id: 'u1', username: 'admin', pin: '123456');

      expect(
        () => datasource.login('admin', '999999'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Username atau PIN salah.',
          ),
        ),
      );
    });

    test(
      'fails for an unknown username with the same generic message (no enumeration)',
      () async {
        expect(
          () => datasource.login('nobody', '123456'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Username atau PIN salah.',
            ),
          ),
        );
      },
    );
  });

  group('legacy unsalted PIN migration', () {
    test(
      'a pre-migration row (null pinSalt) still logs in with its legacy hash',
      () async {
        await seedUser(
          id: 'u1',
          username: 'legacyadmin',
          pin: '654321',
          useSaltedHash: false,
        );

        final user = await datasource.login('legacyadmin', '654321');
        expect(user.username, 'legacyadmin');
      },
    );

    test(
      'a successful legacy login transparently upgrades the row to a salted hash',
      () async {
        await seedUser(
          id: 'u1',
          username: 'legacyadmin',
          pin: '654321',
          useSaltedHash: false,
        );

        await datasource.login('legacyadmin', '654321');

        final row = await (db.select(
          db.users,
        )..where((u) => u.id.equals('u1'))).getSingle();
        expect(row.pinSalt, isNotNull);
        expect(
          row.pinHash,
          PinUtils.hashPinWithSalt('654321', row.pinSalt!),
          reason: 'the row should now store a salted hash matching the salt',
        );
        expect(
          row.pinHash,
          isNot(PinUtils.legacyHashPin('654321')),
          reason: 'the legacy unsalted hash should no longer be stored',
        );

        // And the upgraded row must still authenticate correctly afterward.
        final user = await datasource.login('legacyadmin', '654321');
        expect(user.username, 'legacyadmin');
      },
    );

    test('a failed legacy login does NOT upgrade the row', () async {
      await seedUser(
        id: 'u1',
        username: 'legacyadmin',
        pin: '654321',
        useSaltedHash: false,
      );

      await expectLater(
        () => datasource.login('legacyadmin', 'wrong1'),
        throwsA(isA<AuthException>()),
      );

      final row = await (db.select(
        db.users,
      )..where((u) => u.id.equals('u1'))).getSingle();
      expect(row.pinSalt, isNull);
    });
  });

  group('brute-force lockout', () {
    test('locks the account after 5 consecutive failed attempts', () async {
      await seedUser(id: 'u1', username: 'admin', pin: '123456');

      for (var i = 0; i < 5; i++) {
        await expectLater(
          () => datasource.login('admin', '000000'),
          throwsA(isA<AuthException>()),
        );
      }

      // A 6th attempt, even with the CORRECT PIN, must be rejected while locked.
      await expectLater(
        () => datasource.login('admin', '123456'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Terlalu banyak percobaan gagal'),
          ),
        ),
      );
    });

    test('a successful login resets the failed-attempt counter', () async {
      await seedUser(id: 'u1', username: 'admin', pin: '123456');

      // A few failures, but fewer than the lockout threshold.
      for (var i = 0; i < 3; i++) {
        await expectLater(
          () => datasource.login('admin', '000000'),
          throwsA(isA<AuthException>()),
        );
      }

      await datasource.login(
        'admin',
        '123456',
      ); // succeeds, should reset the counter

      final row = await (db.select(
        db.users,
      )..where((u) => u.id.equals('u1'))).getSingle();
      expect(row.failedPinAttempts, 0);
      expect(row.lockedUntil, isNull);
    });
  });
}
