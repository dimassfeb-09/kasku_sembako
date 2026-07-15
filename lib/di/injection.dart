import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasirku_sembako/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kasirku_sembako/features/home/presentation/bloc/home_bloc.dart';
import '../features/home/data/datasources/home_local_datasource.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/usecases/get_home_metrics_usecase.dart';
import '../core/database/app_database.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/user_management/data/datasources/permission_local_datasource.dart';
import '../features/user_management/domain/repositories/permission_repository.dart';
import '../features/user_management/data/repositories/permission_repository_impl.dart';
import '../features/user_management/domain/usecases/get_user_permission_usecase.dart';
import '../features/user_management/presentation/bloc/permission_cubit.dart';

import '../features/product/data/datasources/product_local_datasource.dart';
import '../features/product/domain/repositories/product_repository.dart';
import '../features/product/data/repositories/product_repository_impl.dart';
import '../features/product/domain/usecases/product_usecases.dart';
import '../features/product/presentation/bloc/product_bloc.dart';

import '../features/category/data/datasources/category_local_datasource.dart';
import '../features/category/domain/repositories/category_repository.dart';
import '../features/category/data/repositories/category_repository_impl.dart';
import '../features/category/domain/usecases/category_usecases.dart';
import '../features/category/presentation/bloc/category_bloc.dart';

import '../features/wholesale_price/data/datasources/wholesale_price_local_datasource.dart';
import '../features/wholesale_price/domain/repositories/wholesale_price_repository.dart';
import '../features/wholesale_price/data/repositories/wholesale_price_repository_impl.dart';
import '../features/wholesale_price/domain/usecases/wholesale_price_usecases.dart';
import '../features/wholesale_price/presentation/bloc/wholesale_price_bloc.dart';

import '../features/stock/data/datasources/stock_local_datasource.dart';
import '../features/stock/domain/repositories/stock_repository.dart';
import '../features/stock/data/repositories/stock_repository_impl.dart';
import '../features/stock/domain/usecases/stock_usecases.dart';
import '../features/stock/presentation/bloc/stock_bloc.dart';

import '../features/transaction/data/datasources/transaction_local_datasource.dart';
import '../features/transaction/domain/repositories/transaction_repository.dart';
import '../features/customer/data/datasources/customer_local_datasource.dart';
import '../features/customer/domain/repositories/customer_repository.dart';
import '../features/customer/data/repositories/customer_repository_impl.dart';
import '../features/customer/domain/usecases/customer_usecases.dart';
import '../features/debt/domain/usecases/debt_usecases.dart';
import '../features/customer/presentation/bloc/customer_bloc.dart';

import '../features/debt/presentation/bloc/debt_bloc.dart';

import '../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../features/transaction/domain/usecases/checkout_usecase.dart';
import '../features/transaction/domain/usecases/get_transactions_usecase.dart';
import '../features/transaction/domain/usecases/void_transaction_usecase.dart';
import '../features/transaction/presentation/bloc/pos_bloc.dart';
import '../features/report/presentation/bloc/report_bloc.dart';
import '../features/transaction/presentation/bloc/quick_customer_cubit.dart';
import '../features/transaction/presentation/bloc/pos_setup_cubit.dart';

import '../features/expense/data/datasources/expense_local_datasource.dart';
import '../features/expense/domain/repositories/expense_repository.dart';
import '../features/expense/data/repositories/expense_repository_impl.dart';
import '../features/expense/domain/usecases/get_expenses_usecase.dart';
import '../features/expense/domain/usecases/add_expense_usecase.dart';
import '../features/expense/domain/usecases/delete_expense_usecase.dart';
import '../features/expense/presentation/bloc/expense_bloc.dart';

import '../core/services/export_service.dart';
import '../core/services/printer_service.dart';
import '../core/services/activity_log_service.dart';
import '../features/settings/presentation/bloc/printer_bloc.dart';

import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

import '../features/account/data/datasources/account_remote_datasource.dart';
import '../features/account/domain/repositories/account_repository.dart';
import '../features/account/data/repositories/account_repository_impl.dart';
import '../features/account/domain/usecases/account_usecases.dart';
import '../features/account/presentation/bloc/account_bloc.dart';

import '../features/subscription/data/datasources/billing_local_datasource.dart';
import '../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../features/subscription/domain/repositories/subscription_repository.dart';
import '../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../features/subscription/domain/usecases/subscription_usecases.dart';
import '../features/subscription/presentation/cubit/subscription_cubit.dart';

import '../features/settings/data/datasources/cloud_backup_remote_datasource.dart';
import '../features/settings/domain/repositories/cloud_backup_repository.dart';
import '../features/settings/data/repositories/cloud_backup_repository_impl.dart';
import '../features/settings/domain/usecases/cloud_backup_usecases.dart';
import '../features/settings/presentation/bloc/backup_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Core Services
  // Explicit iOS hardening rather than relying on the plugin's default
  // Keychain accessibility: first_unlock_this_device excludes the item from
  // unencrypted iTunes/Finder backups and requires the device to have been
  // unlocked at least once since boot. (Android's flutter_secure_storage
  // 10.x already encrypts automatically via platform ciphers - the
  // AndroidOptions(encryptedSharedPreferences: true) flag is deprecated as
  // of this version and intentionally omitted.)
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );
  sl.registerLazySingleton<PrinterService>(() => PrinterService());
  sl.registerLazySingleton<ExportService>(() => ExportService());
  sl.registerLazySingleton<ActivityLogService>(
    () => ActivityLogService(sl<AppDatabase>(), sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<Dio>(
    () => DioClient.build(sl<FlutterSecureStorage>()),
  );

  // Datasources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      db: sl<AppDatabase>(),
      secureStorage: sl<FlutterSecureStorage>(),
      logService: sl<ActivityLogService>(),
    ),
  );
  sl.registerLazySingleton<PermissionLocalDataSource>(
    () => PermissionLocalDataSourceImpl(db: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      db: sl<AppDatabase>(),
      logService: sl<ActivityLogService>(),
    ),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(db: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<WholesalePriceLocalDataSource>(
    () => WholesalePriceLocalDataSourceImpl(db: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(
      db: sl<AppDatabase>(),
      secureStorage: sl<FlutterSecureStorage>(),
      logService: sl<ActivityLogService>(),
    ),
  );
  sl.registerLazySingleton<StockLocalDataSource>(
    () => StockLocalDataSourceImpl(
      db: sl<AppDatabase>(),
      secureStorage: sl<FlutterSecureStorage>(),
      logService: sl<ActivityLogService>(),
    ),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(
      db: sl<AppDatabase>(),
      secureStorage: sl<FlutterSecureStorage>(),
      logService: sl<ActivityLogService>(),
    ),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(db: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(
      dio: sl<Dio>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerLazySingleton<BillingLocalDataSource>(
    () => BillingLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<CloudBackupRemoteDataSource>(
    () => CloudBackupRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<WholesalePriceRepository>(
    () => WholesalePriceRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      remoteDataSource: sl<AccountRemoteDataSource>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      billingLocalDataSource: sl<BillingLocalDataSource>(),
      remoteDataSource: sl<SubscriptionRemoteDataSource>(),
      db: sl<AppDatabase>(),
    ),
  );
  sl.registerLazySingleton<CloudBackupRepository>(
    () => CloudBackupRepositoryImpl(
      remoteDataSource: sl<CloudBackupRemoteDataSource>(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionUseCase(sl()));
  sl.registerLazySingleton(() => HasUsersUseCase(sl()));
  sl.registerLazySingleton(() => RegisterFirstAdminUseCase(sl()));
  sl.registerLazySingleton(() => GetUserPermissionUseCase(sl()));

  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => InsertProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => InsertCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  sl.registerLazySingleton(() => GetWholesalePricesUseCase(sl()));
  sl.registerLazySingleton(() => InsertWholesalePriceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWholesalePriceUseCase(sl()));

  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => InsertCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));
  sl.registerLazySingleton(() => GetDebtPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => SaveDebtPaymentUseCase(sl()));

  sl.registerLazySingleton(() => GetStockHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AdjustStockUseCase(sl()));

  sl.registerLazySingleton(() => CheckoutUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => VoidTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetHomeMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));

  sl.registerLazySingleton(() => RegisterAccountUseCase(sl()));
  sl.registerLazySingleton(() => LoginAccountUseCase(sl()));
  sl.registerLazySingleton(() => LogoutAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedAccountUseCase(sl()));

  sl.registerLazySingleton(() => PurchaseProUseCase(sl()));
  sl.registerLazySingleton(() => RestorePurchasesUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedSubscriptionStatusUseCase(sl()));
  sl.registerLazySingleton(() => RefreshSubscriptionStatusUseCase(sl()));

  sl.registerLazySingleton(() => UploadCloudBackupUseCase(sl()));
  sl.registerLazySingleton(() => DownloadCloudBackupUseCase(sl()));
  sl.registerLazySingleton(() => ListBackupsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBackupUseCase(sl()));

  // Blocs/Cubits
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getSessionUseCase: sl(),
      hasUsersUseCase: sl(),
      registerFirstAdminUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      getProductByBarcodeUseCase: sl(),
      insertProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategoriesUseCase: sl(),
      insertCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      insertCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DebtBloc(getDebtPaymentsUseCase: sl(), saveDebtPaymentUseCase: sl()),
  );

  sl.registerFactory(
    () => WholesalePriceBloc(
      getWholesalePricesUseCase: sl(),
      insertWholesalePriceUseCase: sl(),
      deleteWholesalePriceUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => StockBloc(getStockHistoryUseCase: sl(), adjustStockUseCase: sl()),
  );

  sl.registerFactory(
    () => PosBloc(checkoutUseCase: sl(), getWholesalePricesUseCase: sl()),
  );

  sl.registerFactory(
    () => PrinterBloc(printerService: sl(), secureStorage: sl()),
  );

  sl.registerFactory(
    () => ReportBloc(
      getTransactionsUseCase: sl(),
      voidTransactionUseCase: sl(),
      exportService: sl(),
    ),
  );

  sl.registerFactory(() => HomeBloc(getHomeMetricsUseCase: sl()));

  sl.registerFactory(() => QuickCustomerCubit(insertCustomerUseCase: sl()));
  sl.registerFactory(
    () => PosSetupCubit(getCategoriesUseCase: sl(), getCustomersUseCase: sl()),
  );
  sl.registerFactory(() => PermissionCubit(getUserPermissionUseCase: sl()));

  sl.registerFactory(
    () => ExpenseBloc(
      getExpensesUseCase: sl(),
      addExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AccountBloc(
      registerAccountUseCase: sl(),
      loginAccountUseCase: sl(),
      logoutAccountUseCase: sl(),
      getCachedAccountUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SubscriptionCubit(
      purchaseProUseCase: sl(),
      restorePurchasesUseCase: sl(),
      getCachedSubscriptionStatusUseCase: sl(),
      refreshSubscriptionStatusUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => BackupBloc(
      uploadCloudBackupUseCase: sl(),
      downloadCloudBackupUseCase: sl(),
    ),
  );
}
