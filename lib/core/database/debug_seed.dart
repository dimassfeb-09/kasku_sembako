import 'package:drift/drift.dart';
import 'app_database.dart';

Future<void> seedDebugData(AppDatabase db) async {
  final now = DateTime.now();
  String catId(String s) => 'seed-cat-$s';
  String prodId(int i) => 'seed-prod-$i';
  String custId(String s) => 'seed-cust-$s';

  final categories = [
    (catId('makanan'), 'Makanan', '#FF6B6B'),
    (catId('minuman'), 'Minuman', '#4ECDC4'),
    (catId('sembako'), 'Sembako', '#45B7D1'),
    (catId('bumbu'), 'Bumbu Dapur', '#96CEB4'),
    (catId('rt'), 'Alat Rumah Tangga', '#FFEAA7'),
  ];

  final products = [
    (
      prodId(1),
      '8991002122230',
      'Beras Ramos 5kg',
      catId('sembako'),
      65000.0,
      72000.0,
      20,
      'kg',
    ),
    (
      prodId(2),
      '8991002122247',
      'Gula Pasir Gulaku 1kg',
      catId('sembako'),
      13000.0,
      15500.0,
      30,
      'kg',
    ),
    (
      prodId(3),
      '8991002122254',
      'Minyak Goreng Bimoli 1L',
      catId('sembako'),
      18000.0,
      21000.0,
      15,
      'L',
    ),
    (
      prodId(4),
      '8991002122261',
      'Telur Ayam 1kg',
      catId('makanan'),
      25000.0,
      28000.0,
      10,
      'kg',
    ),
    (
      prodId(5),
      '8991002122278',
      'Mie Instan Indomie',
      catId('makanan'),
      2500.0,
      3500.0,
      100,
      'pcs',
    ),
    (
      prodId(6),
      '8991002122285',
      'Kopi Kapal Api 10s',
      catId('minuman'),
      8000.0,
      10000.0,
      25,
      'pcs',
    ),
    (
      prodId(7),
      '8991002122292',
      'Teh Sariwangi 25s',
      catId('minuman'),
      5000.0,
      6500.0,
      20,
      'pcs',
    ),
    (
      prodId(8),
      '8991002122308',
      'Garam Beryodium Kapal 500g',
      catId('bumbu'),
      4000.0,
      5500.0,
      40,
      'pcs',
    ),
    (
      prodId(9),
      '8991002122315',
      'Kecap Bango 600ml',
      catId('bumbu'),
      12000.0,
      15000.0,
      12,
      'pcs',
    ),
    (
      prodId(10),
      '8991002122322',
      'Sabun Cuci Piring Sunlight 450ml',
      catId('rt'),
      8000.0,
      11000.0,
      18,
      'pcs',
    ),
  ];

  final customers = [
    (custId('budi'), 'Budi Santoso', '081234567890', null),
    (custId('sari'), 'Sari Dewi', '081234567891', 'Pelanggan tetap'),
    (custId('tono'), 'Tono Hartono', '081234567892', null),
  ];

  final transactions = [
    (
      'TRX-001',
      'cash',
      'completed',
      now.subtract(const Duration(days: 2)),
      custId('budi'),
      [(prodId(1), 2, 72000.0, 144000.0), (prodId(5), 10, 3500.0, 35000.0)],
    ),
    (
      'TRX-002',
      'cash',
      'completed',
      now.subtract(const Duration(days: 1)),
      null,
      [(prodId(3), 3, 21000.0, 63000.0), (prodId(6), 5, 10000.0, 50000.0)],
    ),
    (
      'TRX-003',
      'qris',
      'completed',
      now.subtract(const Duration(hours: 5)),
      custId('sari'),
      [
        (prodId(2), 5, 15500.0, 77500.0),
        (prodId(8), 2, 5500.0, 11000.0),
        (prodId(9), 3, 15000.0, 45000.0),
      ],
    ),
    (
      'TRX-004',
      'cash',
      'completed',
      now.subtract(const Duration(hours: 2)),
      null,
      [
        (prodId(4), 1, 28000.0, 28000.0),
        (prodId(7), 2, 6500.0, 13000.0),
        (prodId(10), 1, 11000.0, 11000.0),
      ],
    ),
  ];

  await db.batch((batch) {
    for (final c in categories) {
      batch.insert(
        db.categories,
        CategoriesCompanion.insert(id: c.$1, name: c.$2, color: Value(c.$3)),
      );
    }
    for (final p in products) {
      batch.insert(
        db.products,
        ProductsCompanion.insert(
          id: p.$1,
          barcode: p.$2,
          name: p.$3,
          categoryId: Value(p.$4),
          purchasePrice: p.$5,
          sellingPrice: p.$6,
          stock: Value(p.$7),
          unit: p.$8,
        ),
      );
    }
    for (final c in customers) {
      batch.insert(
        db.customers,
        CustomersCompanion.insert(
          id: c.$1,
          name: c.$2,
          phone: Value(c.$3),
          notes: Value(c.$4),
        ),
      );
    }
    var txnItemId = 1;
    for (final t in transactions) {
      final txnId = 'seed-trx-${t.$1}';
      final total = t.$6.fold<double>(0, (s, e) => s + e.$4);

      batch.insert(
        db.transactions,
        TransactionsCompanion.insert(
          id: txnId,
          receiptNumber: t.$1,
          cashierId: 'local-dev',
          customerId: Value(t.$5),
          totalAmount: total,
          paymentMethod: t.$2,
          status: t.$3,
          createdAt: t.$4,
        ),
      );

      for (final item in t.$6) {
        batch.insert(
          db.transactionItems,
          TransactionItemsCompanion.insert(
            id: 'seed-trx-item-${txnItemId++}',
            transactionId: txnId,
            productId: item.$1,
            productName: products.firstWhere((p) => p.$1 == item.$1).$3,
            qty: item.$2,
            price: item.$3,
            subtotal: item.$4,
          ),
        );
      }
    }
  });
}

void _deleteAll(Batch batch, AppDatabase db, String key) {
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

Future<void> resetDebugData(AppDatabase db) async {
  await db.batch((batch) {
    for (final key in _tableOrder.reversed) {
      _deleteAll(batch, db, key);
    }
  });
}
