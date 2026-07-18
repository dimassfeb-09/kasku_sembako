import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import 'datasources/store_profile_remote_datasource.dart';

/// Decides whether the signed-in user has finished business setup, and heals
/// the locally cached flag when it disagrees with the server.
///
/// Shared by the splash and login screens, which must answer this identically
/// - they previously carried duplicate copies of the logic.
///
/// Why the healing pass exists: [StoreProfileRemoteDataSource.get] used to
/// read the `{"profile": null}` envelope as the profile itself and return a
/// model with every field blank. Callers took that non-null value to mean
/// "setup complete" and persisted [AppConstants.isBusinessSetupComplete], so
/// existing installs carry a flag that was never earned. Because that flag was
/// read before any network call, fixing `get()` alone would never reach them.
///
/// Fails open on purpose: a transient network or auth failure must never
/// demote a user who really does have a profile, since business setup would
/// then overwrite it. On failure the cached flag stands and the verification
/// marker is left unwritten, so the check retries on the next launch.
Future<bool> resolveBusinessSetupComplete(FlutterSecureStorage storage) async {
  final setupDone =
      await storage.read(key: AppConstants.isBusinessSetupComplete) == 'true';
  final alreadyVerified =
      await storage.read(key: AppConstants.businessSetupVerifiedKey) == 'true';

  // Already reconciled against the server on this device.
  if (setupDone && alreadyVerified) return true;

  try {
    final remote = StoreProfileRemoteDataSourceImpl(dio: buildDio(storage));
    final profile = await remote.get();

    // A profile row can exist while still being empty - treat a blank business
    // name as "not set up", which is what the blank-model bug produced.
    final hasProfile =
        profile != null && profile.businessName.trim().isNotEmpty;

    if (hasProfile) {
      await storage.write(
        key: AppConstants.isBusinessSetupComplete,
        value: 'true',
      );
    } else {
      // Only ever demote on a definitive answer from the server.
      await storage.delete(key: AppConstants.isBusinessSetupComplete);
    }
    await storage.write(
      key: AppConstants.businessSetupVerifiedKey,
      value: 'true',
    );
    return hasProfile;
  } catch (_) {
    return setupDone;
  }
}
