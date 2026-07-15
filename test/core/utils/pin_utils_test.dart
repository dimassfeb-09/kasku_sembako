import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/core/utils/pin_utils.dart';

void main() {
  group('hashPinWithSalt', () {
    test('matches a known PBKDF2-HMAC-SHA256 reference value', () {
      // Cross-checked against Python's hashlib.pbkdf2_hmac('sha256', ...)
      // for the same pin/salt/iteration count during implementation.
      const salt = '000102030405060708090a0b0c0d0e0f';
      const pin = '123456';
      final result = PinUtils.hashPinWithSalt(pin, salt);
      const expected =
          '3e3d2422f00f2cc1d1bad045819bfb8360117d59c588035c4294f3403ac097a5';
      expect(result, expected);
    });

    test('is deterministic for the same pin+salt', () {
      final salt = PinUtils.generateSalt();
      expect(
        PinUtils.hashPinWithSalt('654321', salt),
        PinUtils.hashPinWithSalt('654321', salt),
      );
    });

    test('produces different hashes for different salts (same pin)', () {
      final saltA = PinUtils.generateSalt();
      final saltB = PinUtils.generateSalt();
      expect(saltA, isNot(saltB));
      expect(
        PinUtils.hashPinWithSalt('654321', saltA),
        isNot(PinUtils.hashPinWithSalt('654321', saltB)),
      );
    });

    test('produces different hashes for different pins (same salt)', () {
      final salt = PinUtils.generateSalt();
      expect(
        PinUtils.hashPinWithSalt('111111', salt),
        isNot(PinUtils.hashPinWithSalt('222222', salt)),
      );
    });

    test('output is a 64-char lowercase hex string (32-byte digest)', () {
      final salt = PinUtils.generateSalt();
      final hash = PinUtils.hashPinWithSalt('123456', salt);
      expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  group('generateSalt', () {
    test('produces a 32-char lowercase hex string (16 bytes)', () {
      final salt = PinUtils.generateSalt();
      expect(salt, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('is random across calls', () {
      final salts = List.generate(20, (_) => PinUtils.generateSalt());
      expect(salts.toSet().length, salts.length);
    });
  });

  group('legacyHashPin (migration compatibility only)', () {
    test(
      'matches plain unsalted SHA-256 (cross-checked against Python hashlib)',
      () {
        const expected =
            '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
        expect(PinUtils.legacyHashPin('123456'), expected);
      },
    );

    test('is deterministic and unsalted (same output every call)', () {
      expect(
        PinUtils.legacyHashPin('123456'),
        PinUtils.legacyHashPin('123456'),
      );
    });
  });

  group('isValidPin', () {
    test('accepts exactly 6 digits', () {
      expect(PinUtils.isValidPin('123456'), isTrue);
    });

    test('rejects shorter than 6 digits (previously allowed down to 4)', () {
      expect(PinUtils.isValidPin('1234'), isFalse);
      expect(PinUtils.isValidPin('12345'), isFalse);
    });

    test('rejects longer than 6 digits', () {
      expect(PinUtils.isValidPin('1234567'), isFalse);
    });

    test('rejects non-numeric input', () {
      expect(PinUtils.isValidPin('12a456'), isFalse);
      expect(PinUtils.isValidPin('abcdef'), isFalse);
    });
  });
}
