import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/customer_model.dart';
import '../../../debt/data/models/debt_payment_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> insertCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<DebtPaymentModel>> getDebtPayments(String? customerId);
  Future<void> saveDebtPayment(DebtPaymentModel payment);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final AppDatabase db;
  final FlutterSecureStorage secureStorage;
  final ActivityLogService logService;

  CustomerLocalDataSourceImpl({
    required this.db,
    required this.secureStorage,
    required this.logService,
  });

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final customers = await db.select(db.customers).get();
    return customers.map((c) => CustomerModel.fromDrift(c)).toList();
  }

  @override
  Future<void> insertCustomer(CustomerModel customer) async {
    await db
        .into(db.customers)
        .insert(
          CustomersCompanion.insert(
            id: customer.id,
            name: customer.name,
            phone: Value(customer.phone),
            notes: Value(customer.notes),
            debtAmount: Value(customer.debtAmount),
          ),
        );

    await logService.log(
      action: 'ADD_CUSTOMER',
      description: 'Menambahkan pelanggan baru: ${customer.name}.',
    );
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await (db.update(
      db.customers,
    )..where((c) => c.id.equals(customer.id))).write(
      CustomersCompanion(
        name: Value(customer.name),
        phone: Value(customer.phone),
        notes: Value(customer.notes),
        debtAmount: Value(customer.debtAmount),
      ),
    );

    await logService.log(
      action: 'EDIT_CUSTOMER',
      description: 'Mengubah profil pelanggan: ${customer.name}.',
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    String name = id;
    try {
      final query = db.select(db.customers)..where((c) => c.id.equals(id));
      final customer = await query.getSingleOrNull();
      if (customer != null) {
        name = customer.name;
      }
    } catch (_) {}

    await (db.delete(db.customers)..where((c) => c.id.equals(id))).go();

    await logService.log(
      action: 'DELETE_CUSTOMER',
      description: 'Menghapus pelanggan $name.',
    );
  }

  @override
  Future<List<DebtPaymentModel>> getDebtPayments(String? customerId) async {
    final query = db.select(db.debtPayments);
    if (customerId != null) {
      query.where((dp) => dp.customerId.equals(customerId));
    }
    query.orderBy([
      (dp) => OrderingTerm(expression: dp.createdAt, mode: OrderingMode.desc),
    ]);
    final results = await query.get();
    return results.map((e) => DebtPaymentModel.fromDrift(e)).toList();
  }

  @override
  Future<void> saveDebtPayment(DebtPaymentModel payment) async {
    final cashierId =
        await secureStorage.read(key: AppConstants.currentUserIdKey) ??
        'admin_id';
    await db.transaction(() async {
      // 1. Insert Debt Payment record
      await db
          .into(db.debtPayments)
          .insert(
            DebtPaymentsCompanion.insert(
              id: payment.id,
              customerId: payment.customerId,
              amount: payment.amount,
              paymentMethod: payment.paymentMethod,
              notes: Value(payment.notes),
              cashierId: cashierId,
              createdAt: payment.createdAt,
            ),
          );

      // 2. Load customer data
      final custQuery = db.select(db.customers)
        ..where((c) => c.id.equals(payment.customerId));
      final customer = await custQuery.getSingleOrNull();

      if (customer != null) {
        // 3. Calculate new debt
        final newDebt = customer.debtAmount - payment.amount;

        // 4. Update customer debt amount
        await (db.update(
          db.customers,
        )..where((c) => c.id.equals(payment.customerId))).write(
          CustomersCompanion(debtAmount: Value(newDebt >= 0 ? newDebt : 0.0)),
        );

        final customerName = customer.name;
        await logService.log(
          action: 'PAY_DEBT',
          description:
              'Pembayaran cicilan hutang oleh pelanggan $customerName sebesar ${payment.amount.toRupiah()} menggunakan metode ${payment.paymentMethod}.',
          userId: cashierId,
        );
      }
    });
  }
}
