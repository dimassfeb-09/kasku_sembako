import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasirku_sembako/core/database/app_database.dart';
import 'package:kasirku_sembako/core/database/database_json_codec.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds one row per FK-dependent table across the graph exercised by the
  /// codec's delete/insert ordering: users -> permissions, categories ->
  /// products -> wholesalePrices, customers -> transactions ->
  /// transactionItems, products -> stockHistories, users -> activityLogs,
  /// customers -> debtPayments.
  Future<void> seedFullGraph(AppDatabase db) async {
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: 'user-1',
            username: 'admin',
            pinHash: 'hash',
            role: 'admin',
          ),
        );
    await db
        .into(db.permissions)
        .insert(PermissionsCompanion.insert(id: 'perm-1', userId: 'user-1'));
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(id: 'cat-1', name: 'Sembako'));
    await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            id: 'prod-1',
            barcode: '12345',
            name: 'Beras 5kg',
            purchasePrice: 50000,
            sellingPrice: 60000,
            unit: 'pcs',
            categoryId: const Value('cat-1'),
          ),
        );
    await db
        .into(db.wholesalePrices)
        .insert(
          WholesalePricesCompanion.insert(
            id: 'wp-1',
            productId: 'prod-1',
            minQty: 10,
            price: 55000,
          ),
        );
    await db
        .into(db.customers)
        .insert(CustomersCompanion.insert(id: 'cust-1', name: 'Budi'));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'trx-1',
            receiptNumber: 'RCPT-1',
            cashierId: 'user-1',
            totalAmount: 60000,
            paymentMethod: 'cash',
            status: 'success',
            createdAt: DateTime(2026, 1, 1),
            customerId: const Value('cust-1'),
          ),
        );
    await db
        .into(db.transactionItems)
        .insert(
          TransactionItemsCompanion.insert(
            id: 'ti-1',
            transactionId: 'trx-1',
            productId: 'prod-1',
            productName: 'Beras 5kg',
            qty: 1,
            price: 60000,
            subtotal: 60000,
          ),
        );
    await db
        .into(db.stockHistories)
        .insert(
          StockHistoriesCompanion.insert(
            id: 'sh-1',
            productId: 'prod-1',
            type: 'in',
            qty: 20,
            userId: 'user-1',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: 'exp-1',
            category: 'Listrik',
            amount: 100000,
            date: DateTime(2026, 1, 1),
          ),
        );
    await db
        .into(db.activityLogs)
        .insert(
          ActivityLogsCompanion.insert(
            id: 'log-1',
            userId: 'user-1',
            action: 'LOGIN',
            description: 'test',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await db
        .into(db.debtPayments)
        .insert(
          DebtPaymentsCompanion.insert(
            id: 'debt-1',
            customerId: 'cust-1',
            amount: 5000,
            paymentMethod: 'CASH',
            cashierId: 'user-1',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await db
        .into(db.subscriptionCaches)
        .insert(
          SubscriptionCachesCompanion.insert(
            id: 'current',
            tier: 'pro',
            lastVerifiedAt: DateTime(2026, 1, 1),
          ),
        );
  }

  test('exportToJson produces the expected envelope shape', () async {
    await seedFullGraph(db);

    final json = await DatabaseJsonCodec.exportToJson(db);

    expect(json['schemaVersion'], db.schemaVersion);
    expect(json['exportedAt'], isA<String>());
    final tables = json['tables'] as Map<String, dynamic>;
    expect(tables['users'], hasLength(1));
    expect(tables['products'], hasLength(1));
    expect(tables['transactions'], hasLength(1));
    expect(tables['transactionItems'], hasLength(1));
    expect(tables['debtPayments'], hasLength(1));
    expect(tables['subscriptionCaches'], hasLength(1));
  });

  test(
    'importFromJson round-trips every table without violating FK constraints',
    () async {
      await seedFullGraph(db);
      final exported = await DatabaseJsonCodec.exportToJson(db);

      // Mutate the live DB after export so we can prove import restores the
      // exported snapshot, not just leaves existing data untouched.
      await db
          .into(db.categories)
          .insert(CategoriesCompanion.insert(id: 'cat-2', name: 'Extra'));

      await DatabaseJsonCodec.importFromJson(db, exported);

      final categories = await db.select(db.categories).get();
      expect(
        categories.map((c) => c.id),
        equals(['cat-1']),
        reason: 'import should have wiped the post-export mutation',
      );

      final products = await db.select(db.products).get();
      expect(products, hasLength(1));
      expect(products.single.name, 'Beras 5kg');
      expect(products.single.categoryId, 'cat-1');

      final transactions = await db.select(db.transactions).get();
      expect(transactions, hasLength(1));
      expect(transactions.single.cashierId, 'user-1');
      expect(transactions.single.customerId, 'cust-1');

      final items = await db.select(db.transactionItems).get();
      expect(items, hasLength(1));
      expect(items.single.transactionId, 'trx-1');

      final debtPayments = await db.select(db.debtPayments).get();
      expect(debtPayments, hasLength(1));
      expect(debtPayments.single.customerId, 'cust-1');

      final caches = await db.select(db.subscriptionCaches).get();
      expect(caches, hasLength(1));
      expect(caches.single.tier, 'pro');
    },
  );

  test(
    'importFromJson handles a fully empty database (no rows anywhere)',
    () async {
      final exported = await DatabaseJsonCodec.exportToJson(db);
      // Should not throw despite every table list being empty.
      await DatabaseJsonCodec.importFromJson(db, exported);
      expect(await db.select(db.users).get(), isEmpty);
    },
  );

  test('importFromJson rejects a mismatched schemaVersion', () async {
    final badJson = {
      'schemaVersion': db.schemaVersion - 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{},
    };

    expect(
      () => DatabaseJsonCodec.importFromJson(db, badJson),
      throwsA(isA<InvalidBackupFormatException>()),
    );
  });

  test('importFromJson rejects a payload missing the tables key', () async {
    final badJson = {
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
    };

    expect(
      () => DatabaseJsonCodec.importFromJson(db, badJson),
      throwsA(isA<InvalidBackupFormatException>()),
    );
  });

  test(
    'importFromJson rejects a payload missing schemaVersion entirely',
    () async {
      final badJson = {'tables': <String, dynamic>{}};

      expect(
        () => DatabaseJsonCodec.importFromJson(db, badJson),
        throwsA(isA<InvalidBackupFormatException>()),
      );
    },
  );
}
