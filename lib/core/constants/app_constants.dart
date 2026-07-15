class AppConstants {
  static const String appName = 'Kasirku Sembako';

  // Secure Storage Keys
  static const String sessionKey = 'USER_SESSION_KEY';
  static const String currentUserIdKey = 'CURRENT_USER_ID';
  static const String currentUserRoleKey = 'CURRENT_USER_ROLE';

  // Role
  static const String roleAdmin = 'admin';
  static const String roleCashier = 'cashier';

  // Cloud account (Pro subscription) secure storage keys.
  // Separate from the local PIN session above: this represents the store's
  // cloud identity, not a per-cashier login.
  static const String accountAccessTokenKey = 'ACCOUNT_ACCESS_TOKEN';
  static const String accountIdKey = 'ACCOUNT_ID';
  static const String accountEmailKey = 'ACCOUNT_EMAIL';
  static const String accountCreatedAtKey = 'ACCOUNT_CREATED_AT';

  // Backend base URL, supplied at build time via:
  //   flutter run --dart-define=API_BASE_URL=https://api.example.com
  // Falls back to a local dev default so `flutter run` works out of the box
  // against a locally running backend (see backend/README.md).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// False if [apiBaseUrl] is still the cleartext dev default — checked at
  /// startup in main.dart so a release build that forgot
  /// --dart-define=API_BASE_URL=https://... fails loudly immediately,
  /// instead of silently shipping with the account JWT sent over plain
  /// HTTP to whatever "localhost:8080" resolves to on the user's device.
  static bool get isApiBaseUrlSafeForRelease =>
      apiBaseUrl.startsWith('https://');

  // Play Billing product id — must match the subscription created in
  // Play Console > Monetize > Products > Subscriptions.
  static const String proMonthlyProductId = 'pro_monthly';
}
