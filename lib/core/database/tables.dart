import 'package:drift/drift.dart';

@DataClassName('User')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get pinHash => text()();
  TextColumn get role => text()(); // 'admin' atau 'cashier'
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Permission')
class Permissions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  BoolColumn get menuProduct => boolean().withDefault(const Constant(false))();
  BoolColumn get menuStock => boolean().withDefault(const Constant(false))();
  BoolColumn get menuReport => boolean().withDefault(const Constant(false))();
  BoolColumn get actionVoid => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get barcode => text().unique()();
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  RealColumn get purchasePrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  TextColumn get unit => text()(); // pcs, kg, etc
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WholesalePrice')
class WholesalePrices extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get minQty => integer()();
  RealColumn get price => real()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get debtAmount => real().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get receiptNumber => text().unique()();
  TextColumn get cashierId => text().references(Users, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  RealColumn get totalAmount => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text()(); // cash, qris, dll
  TextColumn get status => text()(); // success, hold, void
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionItem')
class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  IntColumn get qty => integer()();
  RealColumn get price => real()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get subtotal => real()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StockHistory')
class StockHistories extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get type => text()(); // in, out, adjustment
  IntColumn get qty => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get receiptPath => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityLog')
class ActivityLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get action => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DebtPayment')
class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  RealColumn get amount => real()();
  TextColumn get paymentMethod => text()(); // 'CASH', 'QRIS', dll
  TextColumn get notes => text().nullable()();
  TextColumn get cashierId => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
