import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class CompressedBackup {
  final List<int> gzipBytes;

  /// SHA-256 hex digest of the *uncompressed* canonical JSON — stable
  /// regardless of gzip settings, used for skip-if-unchanged detection,
  /// the upload idempotency key, and post-download integrity checks.
  final String contentHash;

  const CompressedBackup({required this.gzipBytes, required this.contentHash});
}

/// Compression and hashing for cloud backup payloads. Kept as a standalone
/// pure-function utility (no DI) so it can run identically from the
/// foreground repository and from the WorkManager background isolate, which
/// has no access to the app's dependency-injection container.
class BackupPayloadUtil {
  const BackupPayloadUtil._();

  static CompressedBackup compress(Map<String, dynamic> payload) {
    final canonicalTables = jsonEncode(payload['tables']);
    final contentHash = sha256.convert(utf8.encode(canonicalTables)).toString();
    final gzipBytes = gzip.encode(utf8.encode(jsonEncode(payload)));
    return CompressedBackup(gzipBytes: gzipBytes, contentHash: contentHash);
  }

  static Map<String, dynamic> decodeBytes(
    List<int> bytes, {
    required bool isGzip,
  }) {
    final raw = isGzip ? gzip.decode(bytes) : bytes;
    return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
  }

  static String hashOf(Map<String, dynamic> payload) {
    return sha256
        .convert(utf8.encode(jsonEncode(payload['tables'])))
        .toString();
  }
}
