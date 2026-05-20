import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasirku_sembako/core/services/activity_log_service.dart';
import 'package:kasirku_sembako/core/utils/currency_formatter.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_item_entity.dart';

abstract class TransactionLocalDataSource {
  Future<TransactionEntity> saveTransaction(
    List<CartItemEntity> cartItems,
    String paymentMethod,
    double discount,
    double tax,
    String? customerId,
  );
  Future<List<TransactionEntity>> getTransactions(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> voidTransaction(String transactionId);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase db;
  final FlutterSecureStorage secureStorage;
  final ActivityLogService logService;

  TransactionLocalDataSourceImpl({
    required this.db,
    required this.secureStorage,
    required this.logService,
  });

  String _generateReceiptNumber() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'TRX-$timestamp';
  }

  @override
  Future<TransactionEntity> saveTransaction(
    List<CartItemEntity> cartItems,
    String paymentMethod,
    double discount,
    double tax,
    String? customerId,
  ) async {
    final cashierId = await secureStorage.read(key: AppConstants.currentUserIdKey);
    if (cashierId == null) {
      throw Exception('Sesi kasir tidak aktif. Silakan masuk kembali.');
    }
    final transactionId = const Uuid().v4();
    final receiptNumber = _generateReceiptNumber();
    final now = DateTime.now();

    double totalAmount = cartItems.fold(0, (sum, item) => sum + item.subtotal);
    final finalTotalAmount = totalAmount - discount + tax;

    final result = await db.transaction(() async {
      // 1. Insert Transaction
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: transactionId,
              receiptNumber: receiptNumber,
              cashierId: cashierId,
              customerId: Value(customerId),
              totalAmount: finalTotalAmount,
              discount: Value(discount),
              tax: Value(tax),
              paymentMethod: paymentMethod,
              status: 'SUCCESS',
              createdAt: now,
            ),
          );

      final transactionItems = <TransactionItemEntity>[];

      // 2. Insert Items & Update Stock
      for (var cartItem in cartItems) {
        final itemId = const Uuid().v4();

        // Calculate item discount based on normal price vs wholesale price
        final normalSubtotal =
            cartItem.product.sellingPrice * cartItem.quantity;
        final itemDiscount = normalSubtotal - cartItem.subtotal;

        await db
            .into(db.transactionItems)
            .insert(
              TransactionItemsCompanion.insert(
                id: itemId,
                transactionId: transactionId,
                productId: cartItem.product.id,
                productName: cartItem.product.name,
                qty: cartItem.quantity,
                price: cartItem.unitPrice,
                purchasePrice: Value(cartItem.product.purchasePrice),
                discount: Value(itemDiscount),
                subtotal: cartItem.subtotal,
              ),
            );

        // Update Stock
        final productQuery = db.select(db.products)
          ..where((p) => p.id.equals(cartItem.product.id));
        final productData = await productQuery.getSingleOrNull();
        if (productData == null) {
          throw Exception('Produk "${cartItem.product.name}" tidak ditemukan di database.');
        }

        final newStock = productData.stock - cartItem.quantity;
        if (newStock < 0) {
          throw Exception('Stok produk "${cartItem.product.name}" tidak mencukupi (Tersedia: ${productData.stock}, Diminta: ${cartItem.quantity}).');
        }

        await (db.update(
          db.products,
        )..where((p) => p.id.equals(cartItem.product.id))).write(
          ProductsCompanion(
            stock: Value(newStock),
          ),
        );

        // Add Stock History
        await db
            .into(db.stockHistories)
            .insert(
              StockHistoriesCompanion.insert(
                id: const Uuid().v4(),
                productId: cartItem.product.id,
                type: 'OUT',
                qty: cartItem.quantity,
                notes: Value('Terjual via transaksi $receiptNumber'),
                userId: cashierId,
                createdAt: now,
              ),
            );

        transactionItems.add(
          TransactionItemEntity(
            id: itemId,
            transactionId: transactionId,
            productId: cartItem.product.id,
            productName: cartItem.product.name,
            qty: cartItem.quantity,
            price: cartItem.unitPrice,
            purchasePrice: cartItem.product.purchasePrice,
            discount: itemDiscount,
            subtotal: cartItem.subtotal,
          ),
        );
      }

      // Update Customer Debt if payment is 'HUTANG'
      if (paymentMethod.toUpperCase() == 'HUTANG' && customerId != null) {
        final custQuery = db.select(db.customers)
          ..where((c) => c.id.equals(customerId));
        final customerData = await custQuery.getSingleOrNull();
        if (customerData != null) {
          await (db.update(
            db.customers,
          )..where((c) => c.id.equals(customerId))).write(
            CustomersCompanion(
              debtAmount: Value(customerData.debtAmount + finalTotalAmount),
            ),
          );
        }
      }

      // Log checkout sukses
      await logService.log(
        action: 'CREATE_TRANSACTION',
        description: 'Membuat transaksi $receiptNumber sebesar ${finalTotalAmount.toRupiah()} dengan metode $paymentMethod.',
        userId: cashierId,
      );

      return TransactionEntity(
        id: transactionId,
        receiptNumber: receiptNumber,
        cashierId: cashierId,
        customerId: customerId,
        totalAmount: finalTotalAmount,
        discount: discount,
        tax: tax,
        paymentMethod: paymentMethod,
        status: 'SUCCESS',
        createdAt: now,
        items: transactionItems,
      );
    });

    return result;
  }

  @override
  Future<List<TransactionEntity>> getTransactions(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Normalisasi end date to end of the day
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    final query = db.select(db.transactions)
      ..where((t) => t.createdAt.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);

    final trxResults = await query.get();

    final result = <TransactionEntity>[];
    for (var trx in trxResults) {
      final itemsQuery = db.select(db.transactionItems)
        ..where((i) => i.transactionId.equals(trx.id));
      final itemResults = await itemsQuery.get();

      final items = itemResults.map((i) => TransactionItemEntity(
        id: i.id,
        transactionId: i.transactionId,
        productId: i.productId,
        productName: i.productName,
        qty: i.qty,
        price: i.price,
        purchasePrice: i.purchasePrice,
        discount: i.discount,
        subtotal: i.subtotal,
      )).toList();

      result.add(TransactionEntity(
        id: trx.id,
        receiptNumber: trx.receiptNumber,
        cashierId: trx.cashierId,
        customerId: trx.customerId,
        totalAmount: trx.totalAmount,
        discount: trx.discount,
        tax: trx.tax,
        paymentMethod: trx.paymentMethod,
        status: trx.status,
        createdAt: trx.createdAt,
        items: items,
      ));
    }
    return result;
  }

  @override
  Future<void> voidTransaction(String transactionId) async {
    final cashierId = await secureStorage.read(key: AppConstants.currentUserIdKey) ?? 'admin_id';

    await db.transaction(() async {
      // 1. Get Transaction
      final trxQuery = db.select(db.transactions)..where((t) => t.id.equals(transactionId));
      final trx = await trxQuery.getSingle();

      if (trx.status == 'VOID') return; // Sudah di-void sebelumnya

      // 2. Update status to VOID
      await (db.update(db.transactions)..where((t) => t.id.equals(transactionId))).write(
        const TransactionsCompanion(status: Value('VOID')),
      );

      // 3. Get Items to restore stock
      final itemsQuery = db.select(db.transactionItems)..where((i) => i.transactionId.equals(transactionId));
      final items = await itemsQuery.get();

      for (var item in items) {
        // Restore stock
        final productQuery = db.select(db.products)..where((p) => p.id.equals(item.productId));
        final product = await productQuery.getSingle();

        await (db.update(db.products)..where((p) => p.id.equals(item.productId))).write(
          ProductsCompanion(stock: Value(product.stock + item.qty)),
        );

        // Record stock history IN
        await db.into(db.stockHistories).insert(
              StockHistoriesCompanion.insert(
                id: const Uuid().v4(),
                productId: item.productId,
                type: 'IN',
                qty: item.qty,
                notes: Value('Pembatalan transaksi ${trx.receiptNumber}'),
                userId: cashierId,
                createdAt: DateTime.now(),
              ),
            );
      }

      // 4. Update customer debt if payment was 'HUTANG'
      if (trx.paymentMethod.toUpperCase() == 'HUTANG' && trx.customerId != null) {
        final custQuery = db.select(db.customers)..where((c) => c.id.equals(trx.customerId!));
        final customer = await custQuery.getSingleOrNull();
        if (customer != null) {
          final newDebt = customer.debtAmount - trx.totalAmount;
          await (db.update(db.customers)..where((c) => c.id.equals(trx.customerId!))).write(
            CustomersCompanion(debtAmount: Value(newDebt >= 0 ? newDebt : 0.0)),
          );
        }
      }

      // 5. Add Activity Log
      await logService.log(
        action: 'VOID_TRANSACTION',
        description: 'Membatalkan Transaksi ${trx.receiptNumber}',
        userId: cashierId,
      );
    });
  }
}
