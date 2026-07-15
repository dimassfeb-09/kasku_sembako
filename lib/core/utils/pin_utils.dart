import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class PinUtils {
  static const int pbkdf2Iterations = 100000;
  static const int _saltLengthBytes = 16;
  static const int _derivedKeyLengthBytes = 32;
  static const int _sha256OutputBytes = 32;

  /// Generates a new cryptographically random, hex-encoded salt for a PIN.
  /// Call once per user when setting/changing a PIN.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = Uint8List(_saltLengthBytes);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return _bytesToHex(bytes);
  }

  /// Hashes [pin] with [salt] using PBKDF2-HMAC-SHA256 (RFC 2898). This is
  /// the only PIN-hashing function new writes should use — see
  /// [legacyHashPin] for why the old unsalted scheme still exists.
  static String hashPinWithSalt(String pin, String salt) {
    final derived = _pbkdf2(
      utf8.encode(pin),
      _hexToBytes(salt),
      pbkdf2Iterations,
      _derivedKeyLengthBytes,
    );
    return _bytesToHex(derived);
  }

  /// Legacy unsalted single-round SHA-256 hash. Kept ONLY so
  /// AuthLocalDataSourceImpl.login() can verify PIN rows created before
  /// salted hashing existed (schema v5) and transparently upgrade them —
  /// never call this for a new PIN write.
  static String legacyHashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Memvalidasi format PIN (harus 6 digit angka, sesuai desain UI).
  static bool isValidPin(String pin) {
    return pin.length == 6 && RegExp(r'^\d+$').hasMatch(pin);
  }

  static String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  /// PBKDF2 (RFC 2898) using HMAC-SHA256 as the pseudorandom function.
  static Uint8List _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLengthBytes,
  ) {
    final hmac = Hmac(sha256, password);
    final blockCount = (keyLengthBytes / _sha256OutputBytes).ceil();
    final derivedKey = BytesBuilder();

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex, Endian.big);
      var u = hmac.convert([
        ...salt,
        ...blockIndexBytes.buffer.asUint8List(),
      ]).bytes;
      final block = Uint8List.fromList(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < block.length; j++) {
          block[j] ^= u[j];
        }
      }
      derivedKey.add(block);
    }

    return Uint8List.sublistView(derivedKey.toBytes(), 0, keyLengthBytes);
  }
}
