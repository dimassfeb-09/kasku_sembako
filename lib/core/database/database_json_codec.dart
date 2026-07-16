import 'package:drift/drift.dart';
import 'app_database.dart';

class InvalidBackupFormatException implements Exception {
  final String message;
  const InvalidBackupFormatException(this.message);

  @override
  String toString() => message;
}

const _tableOrder = [
  'categories',
  'customers',
  'expenses',
  'subscriptionCaches',
  'products',
  'wholesalePrices',
  'transactions',
  'transactionItems',
  'stockHistories',
  'activityLogs',
  'debtPayments',
];

Future<Map<String, dynamic>> exportDbToJson(AppDatabase db) async {
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

Future<void> importDbFromJson(AppDatabase db, Map<String, dynamic> json) async {
  final tables = _validateAndExtractTables(db, json);

  await db.batch((batch) {
    for (final key in _tableOrder.reversed) {
      _deleteAllFor(batch, db, key);
    }
    for (final key in _tableOrder) {
      _insertAllFor(batch, db, key, _listOf(tables, key));
    }
  });
}

Map<String, dynamic> _validateAndExtractTables(
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
  return tables.cast<String, dynamic>();
}

List<Map<String, dynamic>> _listOf(Map<String, dynamic> tables, String key) {
  final raw = tables[key];
  if (raw is! List) return const [];
  return raw.cast<Map<String, dynamic>>();
}

void _deleteAllFor(Batch batch, AppDatabase db, String key) {
  switch (key) {
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

void _insertAllFor(
  Batch batch,
  AppDatabase db,
  String key,
  List<Map<String, dynamic>> rows,
) {
  switch (key) {
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
