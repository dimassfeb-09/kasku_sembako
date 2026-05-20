import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinUtils {
  /// Melakukan hashing PIN menggunakan algoritme SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Memvalidasi format PIN (harus angka dan panjang minimal 4 digit)
  static bool isValidPin(String pin) {
    return pin.length >= 4 && RegExp(r'^\d+$').hasMatch(pin);
  }
}
