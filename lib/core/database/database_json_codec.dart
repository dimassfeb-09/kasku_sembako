import 'package:drift/drift.dart';
import 'app_database.dart';

/// Thrown when a backup file/payload fails parsing, shape, or schema-version
/// validation during [DatabaseJsonCodec.importFromJson].
class InvalidBackupFormatException implements Exception {
  final String message;
  const InvalidBackupFormatException(this.message);

  @override
  String toString() => message;
}

/// Serializes/deserializes the entire local database to/from a single JSON
/// document, used by both local backup/restore (backup_page.dart) and cloud
/// sync (cloud_backup_remote_datasource.dart) so both speak the same format.
///
/// Every table's generated `toJson()`/`fromJson()` (from drift_dev codegen)
/// does the per-field mapping — this class only assembles/disassembles the
/// envelope and handles table ordering.
class DatabaseJsonCodec {
  const DatabaseJsonCodec._();

  /// Parent-before-child insert order, derived from the FK graph in
  /// tables.dart. Delete order (used during import) is the exact reverse.
  static const List<String> _tableOrder = [
    'users',
    'categories',
    'customers',
    'expenses',
    'subscriptionCaches',
    'permissions',
    'products',
    'wholesalePrices',
    'transactions',
    'transactionItems',
    'stockHistories',
    'activityLogs',
    'debtPayments',
  ];

  static Future<Map<String, dynamic>> exportToJson(AppDatabase db) async {
    final users = await db.select(db.users).get();
    final permissions = await db.select(db.permissions).get();
    final categories = await db.select(db.categories).get();
    final products = await db.select(db.products).get();
    final wholesalePrices = await db.select(db.wholesalePrices).get();
    final customers = await db.select(db.customers).get();
    final transactions = await db.select(db.transactions).get();
    final transactionItems = await db.select(db.transactionItems).get();
    final stockHistories = await db.select(db.stockHistories).get();
    final expenses = await db.select(db.expenses).get();
    final activityLogs = await db.select(db.activityLogs).get();
    final debtPayments = await db.select(db.debtPayments).get();
    final subscriptionCaches = await db.select(db.subscriptionCaches).get();

    return {
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': {
        'users': users.map((e) => e.toJson()).toList(),
        'permissions': permissions.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'products': products.map((e) => e.toJson()).toList(),
        'wholesalePrices': wholesalePrices.map((e) => e.toJson()).toList(),
        'customers': customers.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'transactionItems': transactionItems.map((e) => e.toJson()).toList(),
        'stockHistories': stockHistories.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'activityLogs': activityLogs.map((e) => e.toJson()).toList(),
        'debtPayments': debtPayments.map((e) => e.toJson()).toList(),
        'subscriptionCaches': subscriptionCaches
            .map((e) => e.toJson())
            .toList(),
      },
    };
  }

  /// Usernames with `role == 'admin'` in a not-yet-imported JSON payload —
  /// used by the restore UI to warn before silently granting admin access
  /// to an account the reviewing admin may not recognize. Deliberately
  /// lenient (doesn't throw on malformed rows): actual enforcement of the
  /// row format happens inside [importFromJson]; this is only for display.
  static Set<String> adminUsernamesIn(Map<String, dynamic> json) {
    final tables = json['tables'];
    if (tables is! Map) return const {};
    final userRows = tables['users'];
    if (userRows is! List) return const {};
    return userRows
        .whereType<Map>()
        .where((row) => row['role'] == 'admin' && row['username'] is String)
        .map((row) => row['username'] as String)
        .toSet();
  }

  static Future<void> importFromJson(
    AppDatabase db,
    Map<String, dynamic> json,
  ) async {
    final tables = _validateAndExtractTables(db, json);

    await db.batch((batch) {
      // Delete children before parents (reverse of _tableOrder).
      for (final key in _tableOrder.reversed) {
        _deleteAllFor(batch, db, key);
      }
      // Insert parents before children.
      for (final key in _tableOrder) {
        _insertAllFor(batch, db, key, _listOf(tables, key));
      }
    });
  }

  static Map<String, dynamic> _validateAndExtractTables(
    AppDatabase db,
    Map<String, dynamic> json,
  ) {
    final schemaVersion = json['schemaVersion'];
    final tables = json['tables'];

    if (schemaVersion is! int) {
      throw const InvalidBackupFormatException(
        'Format cadangan tidak valid: versi skema tidak ditemukan.',
      );
    }
    if (tables is! Map) {
      throw const InvalidBackupFormatException(
        'Format cadangan tidak valid: data tabel tidak ditemukan.',
      );
    }
    if (schemaVersion != db.schemaVersion) {
      throw InvalidBackupFormatException(
        'Cadangan ini dibuat dengan versi aplikasi yang berbeda '
        '(skema $schemaVersion, aplikasi saat ini skema ${db.schemaVersion}). '
        'Perbarui atau gunakan versi aplikasi yang sesuai untuk memulihkan cadangan ini.',
      );
    }
    final castTables = tables.cast<String, dynamic>();
    _validateUsersRows(_listOf(castTables, 'users'));
    return castTables;
  }

  static final RegExp _hexHash64 = RegExp(r'^[0-9a-f]{64}$');
  static final RegExp _hexSalt32 = RegExp(r'^[0-9a-f]{32}$');
  static const Set<String> _allowedRoles = {'admin', 'cashier'};

  /// Defense-in-depth content validation for the `users` table specifically
  /// — this is the table a hand-crafted backup would need to tamper with to
  /// plant a backdoor admin account. Rejects the whole import if any row's
  /// `role` isn't a known value or `pinHash`/`pinSalt` isn't a well-formed
  /// hash/salt of the expected shape, rather than silently accepting
  /// arbitrary attacker-supplied strings for these security-sensitive
  /// fields.
  static void _validateUsersRows(List<Map<String, dynamic>> userRows) {
    for (final row in userRows) {
      final role = row['role'];
      if (role is! String || !_allowedRoles.contains(role)) {
        throw InvalidBackupFormatException(
          'Format cadangan tidak valid: peran pengguna tidak dikenali (${row['username']}).',
        );
      }
      final pinHash = row['pinHash'];
      if (pinHash is! String || !_hexHash64.hasMatch(pinHash)) {
        throw InvalidBackupFormatException(
          'Format cadangan tidak valid: hash PIN tidak sesuai format (${row['username']}).',
        );
      }
      final pinSalt = row['pinSalt'];
      if (pinSalt != null &&
          (pinSalt is! String || !_hexSalt32.hasMatch(pinSalt))) {
        throw InvalidBackupFormatException(
          'Format cadangan tidak valid: salt PIN tidak sesuai format (${row['username']}).',
        );
      }
    }
  }

  static List<Map<String, dynamic>> _listOf(
    Map<String, dynamic> tables,
    String key,
  ) {
    final raw = tables[key];
    if (raw is! List) return const [];
    return raw.cast<Map<String, dynamic>>();
  }

  static void _deleteAllFor(Batch batch, AppDatabase db, String key) {
    switch (key) {
      case 'users':
        batch.deleteAll(db.users);
      case 'permissions':
        batch.deleteAll(db.permissions);
      case 'categories':
        batch.deleteAll(db.categories);
      case 'products':
        batch.deleteAll(db.products);
      case 'wholesalePrices':
        batch.deleteAll(db.wholesalePrices);
      case 'customers':
        batch.deleteAll(db.customers);
      case 'transactions':
        batch.deleteAll(db.transactions);
      case 'transactionItems':
        batch.deleteAll(db.transactionItems);
      case 'stockHistories':
        batch.deleteAll(db.stockHistories);
      case 'expenses':
        batch.deleteAll(db.expenses);
      case 'activityLogs':
        batch.deleteAll(db.activityLogs);
      case 'debtPayments':
        batch.deleteAll(db.debtPayments);
      case 'subscriptionCaches':
        batch.deleteAll(db.subscriptionCaches);
    }
  }

  static void _insertAllFor(
    Batch batch,
    AppDatabase db,
    String key,
    List<Map<String, dynamic>> rows,
  ) {
    switch (key) {
      case 'users':
        batch.insertAll(db.users, rows.map(User.fromJson));
      case 'permissions':
        batch.insertAll(db.permissions, rows.map(Permission.fromJson));
      case 'categories':
        batch.insertAll(db.categories, rows.map(Category.fromJson));
      case 'products':
        batch.insertAll(db.products, rows.map(Product.fromJson));
      case 'wholesalePrices':
        batch.insertAll(db.wholesalePrices, rows.map(WholesalePrice.fromJson));
      case 'customers':
        batch.insertAll(db.customers, rows.map(Customer.fromJson));
      case 'transactions':
        batch.insertAll(db.transactions, rows.map(Transaction.fromJson));
      case 'transactionItems':
        batch.insertAll(
          db.transactionItems,
          rows.map(TransactionItem.fromJson),
        );
      case 'stockHistories':
        batch.insertAll(db.stockHistories, rows.map(StockHistory.fromJson));
      case 'expenses':
        batch.insertAll(db.expenses, rows.map(Expense.fromJson));
      case 'activityLogs':
        batch.insertAll(db.activityLogs, rows.map(ActivityLog.fromJson));
      case 'debtPayments':
        batch.insertAll(db.debtPayments, rows.map(DebtPayment.fromJson));
      case 'subscriptionCaches':
        batch.insertAll(
          db.subscriptionCaches,
          rows.map(SubscriptionCache.fromJson),
        );
    }
  }
}
