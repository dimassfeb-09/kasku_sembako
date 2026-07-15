# Graph Report - kasku_sembako  (2026-07-15)

## Corpus Check
- 324 files · ~141,980 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3549 nodes · 5970 edges · 214 communities (192 shown, 22 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 109 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7329e8df`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Database Schema
- Clean Architecture Data Layer
- Platform Native Plugins
- Database Table Columns
- Go Backend Subscriptions
- macOS/iOS Platform Bridges
- Go Backend Backups
- Stock Management Bloc
- POS Cart & Checkout
- Feature UI Pages
- App Router & Navigation
- Theme & Colors
- Customer & Debtors UI
- Expense Management UI
- Product Card Widget
- Account Auth Bloc
- Subscription Mock Tests
- Account Remote DataSource
- Database Companion Models
- Report Bloc (Excel/PDF)
- AppDatabase
- subscription_repository_impl.dart
- CategoryBloc
- my_application.cc
- home_repository_impl.dart
- product_edit_page.dart
- account_bloc_test.dart
- package:go_router/go_router.dart
- customer_edit_page.dart
- user_card_tile.dart
- ../../../../core/utils/currency_formatter.dart
- product_bloc.dart
- DebtBloc
- report_app_bar.dart
- package:flutter_bloc/flutter_bloc.dart
- /graphify
- database_json_codec.dart
- auth_bloc.dart
- debt_management_page.dart
- package:dartz/dartz.dart
- product_add_page.dart
- printer_event_state.dart
- expense_page.dart
- ../../../../core/error/failures.dart
- checkout_usecase.dart
- CustomerBloc
- State
- printer_settings_page.dart
- stock_local_datasource.dart
- add_expense_usecase.dart
- package:intl/intl.dart
- backup_page.dart
- pos_setup_cubit.dart
- category_bloc.dart
- adjustment_type_card.dart
- cloud_backup_repository_impl.dart
- app.dart
- customer_bloc.dart
- auth_repository_impl.dart
- home_state.dart
- add_expense_sheet.dart
- user_management_page.dart
- pos_dialogs.dart
- backup_bloc.dart
- customer_repository.dart
- product_local_datasource.dart
- stock_repository_impl.dart
- subscription_status_entity.dart
- pos_product_catalog_pane.dart
- wholesale_price_page.dart
- kasirku_sembako Flutter POS app
- pos_cart_pane.dart
- category_repository_impl.dart
- SubscriptionCubit
- expense_bloc.dart
- qty_adjust_dialog.dart
- List
- report_summary_section.dart
- report_transaction_detail_sheet.dart
- receipt_preview_dialog.dart
- user_permissions_bottom_sheet.dart
- pos_page.dart
- customer_selection_dialog.dart
- wholesale_price_bloc.dart
- IconData?
- AppIcon.appiconset
- report_page.dart
- @DataClassName
- 5. Komponen UI (Component Library)
- Subscription
- checkout_bottom_sheet.dart
- category_edit_page.dart
- app_input.dart
- app_constants.dart
- AccountBloc
- VoidCallback
- subscription_upgrade_page.dart
- Load
- account_repository_impl_test.dart
- wholesale_price_repository_impl.dart
- pos_bloc.dart
- transaction_entity.dart
- transaction_history_page.dart
- user_add_dialog.dart
- report_loaded_content.dart
- newTestApp
- stock_page.dart
- cloud_backup_usecases.dart
- backup_bloc_test.dart
- SubscriptionUsecase
- debt_bloc.dart
- package:equatable/equatable.dart
- transaction_local_datasource.dart
- billing_local_datasource.dart
- auth_local_datasource.dart
- expense_state.dart
- expense_summary_section.dart
- ProductEntity
- Equatable
- home_page.dart
- auth_handler.go
- PrinterBloc
- report_bloc.dart
- printer_bloc.dart
- customer_local_datasource.dart
- customer_page.dart
- main
- AuthBloc
- graphify reference: extra exports and benchmark
- product_entity.dart
- BackupBloc
- activity_log_page.dart
- user_change_pin_dialog.dart
- UserRepository
- App
- NewAuthUsecase
- category_page.dart
- Flutter Framework
- account_event.dart
- customer_add_page.dart
- Exception
- ProductBloc
- CLAUDE.md
- transaction_item_entity.dart
- manifest.json
- product_repository.dart
- ExpenseBloc
- subscription_repository.dart
- wholesale_price_list_item.dart
- subscription_cubit.dart
- cart_item_entity.dart
- permission_local_datasource.dart
- graphify reference: query, path, explain
- di/injection.dart
- subscription_handler.go
- AuthUsecase
- kasirku_sembako backend
- ../../domain/entities/subscription_status_entity.dart
- graphify reference: add a URL and watch a folder
- package:flutter/material.dart
- printer_service.dart
- debt_payment_entity.dart
- cloud_backup_repository.dart
- backup_event.dart
- AppIcon.appiconset
- graphify reference: commit hook and native CLAUDE.md integration
- category_list_content.dart
- expense_repository_impl.dart
- account_repository.dart
- category_repository.dart
- graphify reference: incremental update and cluster-only
- category_add_page.dart
- customer_entity.dart
- expense_entity.dart
- printer_devices_list_section.dart
- cart_item.dart
- permission_entity.dart
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- Android Launcher Icon
- fakeUserRepo
- pin_utils.dart
- LaunchImage.imageset
- home_metrics.dart
- expense_widgets.dart
- repository.go
- opencode.json
- Icon-192.png
- MainActivity
- User
- cash_suggestion_helper.dart
- graphify.js
- Dart Analyzer Configuration
- flutter_export_environment.sh
- Graphify CLI Command
- @example
- @tokoanda
- App Screenshot (redesign UI)
- String?
- SubscriptionRepository
- T?
- User
- github.com/dimassfeb-09/kasku_sembako/backend
- web_favicon_png
- AGENTS.md
- README.md
- extraction-spec.md

## God Nodes (most connected - your core abstractions)
1. `ProductBloc` - 43 edges
2. `PosBloc` - 41 edges
3. `CategoryBloc` - 33 edges
4. `CustomerBloc` - 31 edges
5. `AuthBloc` - 30 edges
6. `AppDatabase` - 27 edges
7. `ReportBloc` - 26 edges
8. `AccountBloc` - 25 edges
9. `PrinterBloc` - 22 edges
10. `Win32Window` - 22 edges

## Surprising Connections (you probably didn't know these)
- `clean architecture (feature-first layers)` --semantically_similar_to--> `backend clean architecture (internal/domain/usecase/repository/delivery/platform)`  [INFERRED] [semantically similar]
  CLAUDE.md → backend/README.md
- `iOS Launch Screen Assets` --conceptually_related_to--> `Flutter Framework`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → README.md
- `newTestApp()` --references--> `App`  [EXTRACTED]
  backend/internal/delivery/http/middleware/auth_middleware_test.go → lib/app/app.dart
- `project graphify configuration and workflow rules` --references--> `/graphify`  [EXTRACTED]
  AGENTS.md → .opencode/skills/graphify/SKILL.md
- `kasirku_sembako Flutter POS app` --conceptually_related_to--> `Go Fiber + PostgreSQL backend`  [INFERRED]
  CLAUDE.md → backend/README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **graphify full pipeline** — opencode_skills_graphify_skill_ast_extraction, opencode_skills_graphify_skill_semantic_extraction, opencode_skills_graphify_skill_community_detection, opencode_skills_graphify_references_update_build_merge, opencode_skills_graphify_references_exports_formats [EXTRACTED 1.00]
- **kasirku_sembako app architecture** — claude_clean_architecture, claude_drift_sqlite, claude_manual_di, claude_go_router, claude_dartz_error_handling, design_component_library [EXTRACTED 1.00]
- **design system foundation** — design_color_palette, design_typography_scale, design_spacing, design_component_library [EXTRACTED 1.00]
- **pwa_icon_set** — web_icons_Icon_192, web_icons_Icon_512, web_icons_Icon_maskable_192, web_icons_Icon_maskable_512 [INFERRED]

## Communities (214 total, 22 thin omitted)

### Community 0 - "Database Schema"
Cohesion: 0.01
Nodes (143): class SubscriptionCache extends, ColumnFilters, ColumnOrderings, GeneratedColumn, GeneratedDatabase, int get, Iterable, _openConnection (+135 more)

### Community 1 - "Clean Architecture Data Layer"
Cohesion: 0.03
Nodes (65): ../core/network/dio_client.dart, ../features/account/data/datasources/account_remote_datasource.dart, ../features/account/data/repositories/account_repository_impl.dart, ../features/account/domain/repositories/account_repository.dart, ../features/account/domain/usecases/account_usecases.dart, ../features/auth/data/datasources/auth_local_datasource.dart, ../features/auth/data/repositories/auth_repository_impl.dart, ../features/auth/domain/repositories/auth_repository.dart (+57 more)

### Community 2 - "Platform Native Plugins"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 3 - "Database Table Columns"
Cohesion: 0.03
Nodes (58): BoolColumn get, DateTimeColumn get, IntColumn get, action, actionVoid, amount, barcode, cashierId (+50 more)

### Community 4 - "Go Backend Subscriptions"
Cohesion: 0.23
Nodes (16): NewSubscriptionUsecase(), activePurchase(), Context, T, newFailingFakePlayClient(), newFakePlayClient(), newFakeSubscriptionRepo(), TestDeriveStatus_FutureExpiryIsActive() (+8 more)

### Community 5 - "macOS/iOS Platform Bridges"
Cohesion: 0.05
Nodes (33): Any, Cocoa, file_picker, file_selector_macos, Flutter, flutter_secure_storage_darwin, FlutterAppDelegate, FlutterImplicitEngineBridge (+25 more)

### Community 6 - "Go Backend Backups"
Cohesion: 0.09
Nodes (24): RawMessage, Time, Context, Pool, NewBackupRepository(), Context, RawMessage, NewBackupUsecase() (+16 more)

### Community 7 - "Stock Management Bloc"
Cohesion: 0.06
Nodes (48): Bloc, ../bloc/stock_bloc.dart, ../bloc/stock_event_state.dart, ../../domain/entities/stock_history_entity.dart, ../../domain/usecases/stock_usecases.dart, fromDrift, StockHistoryModel, StockHistoryEntity (+40 more)

### Community 8 - "POS Cart & Checkout"
Cohesion: 0.11
Nodes (34): _BackupPageBodyState, PosBloc, cartItems, cashReceived, CheckoutEvent, ClearCartEvent, customer, discount (+26 more)

### Community 9 - "Feature UI Pages"
Cohesion: 0.05
Nodes (38): ../../features/account/presentation/pages/account_home_page.dart, ../../features/account/presentation/pages/account_login_page.dart, ../../features/account/presentation/pages/account_register_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_first_admin_page.dart, ../../features/auth/presentation/pages/splash_page.dart, ../../features/category/domain/entities/category_entity.dart, ../../features/category/presentation/pages/category_add_page.dart (+30 more)

### Community 10 - "App Router & Navigation"
Cohesion: 0.08
Nodes (32): bool get, ../../../../core/router/app_router.dart, ../../domain/entities/permission_entity.dart, ../../domain/usecases/get_user_permission_usecase.dart, build, build, _getRouteColor, HomeMenuCard (+24 more)

### Community 11 - "Theme & Colors"
Cohesion: 0.06
Nodes (34): AppColors, background, black, border, borderLight, danger, dangerLight, DashboardColors (+26 more)

### Community 12 - "Customer & Debtors UI"
Cohesion: 0.09
Nodes (18): ../../core/theme/app_colors.dart, ../../../customer/presentation/widgets/customer_list_item.dart, build, customers, DebtorsTab, isLoading, searchQuery, build (+10 more)

### Community 13 - "Expense Management UI"
Cohesion: 0.09
Nodes (27): build, _categoryConfig, exp, ExpenseEmptyState, ExpenseGroupedList, ExpenseListHeader, ExpenseTile, grouped (+19 more)

### Community 14 - "Product Card Widget"
Cohesion: 0.07
Nodes (29): _animController, availableStock, build, _controller, createState, currentQty, dispose, FloatingPlusOne (+21 more)

### Community 15 - "Account Auth Bloc"
Cohesion: 0.08
Nodes (28): ../bloc/account_bloc.dart, ../bloc/account_event.dart, ../bloc/account_state.dart, AccountHomePage, email, onSignIn, _SignedOutView, AccountLoginPage (+20 more)

### Community 16 - "Subscription Mock Tests"
Cohesion: 0.12
Nodes (15): class MockGetCachedSubscriptionStatusUseCase extends, class MockRefreshSubscriptionStatusUseCase extends, class MockRestorePurchasesUseCase extends, package:kasirku_sembako/features/subscription/domain/usecases/subscription_usecases.dart, package:kasirku_sembako/features/subscription/presentation/cubit/subscription_cubit.dart, package:kasirku_sembako/features/subscription/presentation/cubit/subscription_state.dart, buildCubit, freeStatus (+7 more)

### Community 17 - "Account Remote DataSource"
Cohesion: 0.09
Nodes (24): core/constants/app_constants.dart, ../datasources/account_remote_datasource.dart, ../../domain/repositories/account_repository.dart, FlutterSecureStorage, AccountRemoteDataSource, AccountRemoteDataSourceImpl, _authRequest, dio (+16 more)

### Community 18 - "Database Companion Models"
Cohesion: 0.13
Nodes (29): Insertable, UpdateCompanion, ActivityLog, ActivityLogsCompanion, CategoriesCompanion, Category, Customer, CustomersCompanion (+21 more)

### Community 19 - "Report Bloc (Excel/PDF)"
Cohesion: 0.14
Nodes (28): ReportBloc, endDate, ExportExcelEvent, ExportPdfEvent, LoadReportsEvent, message, props, ReportError (+20 more)

### Community 20 - "AppDatabase"
Cohesion: 0.06
Nodes (36): _, @DriftDatabase, class MockBillingLocalDataSource extends, class MockSubscriptionRemoteDataSource extends, AppDatabase, SubscriptionRepositoryImpl, package:drift/native.dart, package:flutter_test/flutter_test.dart (+28 more)

### Community 21 - "subscription_repository_impl.dart"
Cohesion: 0.08
Nodes (26): dart:async, ../datasources/billing_local_datasource.dart, ../datasources/subscription_remote_datasource.dart, Dio, ../../domain/repositories/subscription_repository.dart, dio, getStatus, _mapDioException (+18 more)

### Community 22 - "CategoryBloc"
Cohesion: 0.15
Nodes (26): CategoryBloc, AddCategoryEvent, categories, category, CategoryError, CategoryEvent, CategoryInitial, CategoryLoaded (+18 more)

### Community 23 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 24 - "home_repository_impl.dart"
Cohesion: 0.22
Nodes (9): ../datasources/home_local_datasource.dart, ../../domain/entities/home_metrics.dart, ../../domain/repositories/home_repository.dart, db, getHomeMetrics, HomeLocalDataSource, HomeLocalDataSourceImpl, getHomeMetrics (+1 more)

### Community 25 - "product_edit_page.dart"
Cohesion: 0.08
Nodes (24): ../../../../core/database/app_database.dart, fromDrift, _barcodeController, build, _categories, _commonUnits, createState, _customUnitController (+16 more)

### Community 26 - "account_bloc_test.dart"
Cohesion: 0.06
Nodes (36): account_event.dart, account_state.dart, class MockGetCachedAccountUseCase extends, class MockRegisterAccountUseCase extends, ../../domain/usecases/account_usecases.dart, call, GetCachedAccountUseCase, LoginAccountUseCase (+28 more)

### Community 27 - "package:go_router/go_router.dart"
Cohesion: 0.08
Nodes (29): ../bloc/auth_bloc.dart, ../bloc/auth_event.dart, ../bloc/auth_state.dart, build, createState, dispose, LoginPage, _LoginPageState (+21 more)

### Community 28 - "customer_edit_page.dart"
Cohesion: 0.10
Nodes (20): ../bloc/customer_bloc.dart, ../../domain/entities/customer_entity.dart, CustomerModel, fromDrift, CustomerEntity, build, createState, customer (+12 more)

### Community 29 - "user_card_tile.dart"
Cohesion: 0.08
Nodes (21): build, label, onChanged, selectedValue, StockFilterChip, value, build, isSaving (+13 more)

### Community 30 - "../../../../core/utils/currency_formatter.dart"
Cohesion: 0.09
Nodes (20): ../../../../core/utils/currency_formatter.dart, dashed_divider.dart, TransactionEntity, build, CartSummary, onCheckout, onDiscountTap, onTaxTap (+12 more)

### Community 31 - "product_bloc.dart"
Cohesion: 0.10
Nodes (21): ../../domain/usecases/product_usecases.dart, call, DeleteProductUseCase, GetProductByBarcodeUseCase, GetProductsUseCase, InsertProductUseCase, repository, UpdateProductUseCase (+13 more)

### Community 32 - "DebtBloc"
Cohesion: 0.18
Nodes (19): _showPayDebtDialog, DebtBloc, amount, customerId, DebtError, DebtEvent, DebtInitial, DebtLoading (+11 more)

### Community 33 - "report_app_bar.dart"
Cohesion: 0.10
Nodes (20): build, ExpenseAppBar, ExpenseFAB, onBack, onTap, preferredSize, build, color (+12 more)

### Community 34 - "package:flutter_bloc/flutter_bloc.dart"
Cohesion: 0.10
Nodes (20): ../../domain/usecases/get_home_metrics_usecase.dart, home_event.dart, home_state.dart, getHomeMetricsUseCase, _onLoadHomeMetrics, product, build, createState (+12 more)

### Community 35 - "/graphify"
Cohesion: 0.04
Nodes (44): project graphify configuration and workflow rules, URL ingestion and file watching, graph export formats (Wiki/Neo4j/FalkorDB/SVG/GraphML/MCP), edge confidence score rubric, node ID format convention, extraction subagent specification, GitHub clone and cross-repo merge, post-commit hook and CLAUDE.md integration (+36 more)

### Community 36 - "database_json_codec.dart"
Cohesion: 0.10
Nodes (20): app_database.dart, adminUsernamesIn, _allowedRoles, DatabaseJsonCodec, _deleteAllFor, exportToJson, _hexHash64, _hexSalt32 (+12 more)

### Community 37 - "auth_bloc.dart"
Cohesion: 0.11
Nodes (20): auth_event.dart, auth_state.dart, ../../domain/usecases/auth_usecases.dart, call, GetSessionUseCase, HasUsersUseCase, LoginUseCase, LogoutUseCase (+12 more)

### Community 38 - "debt_management_page.dart"
Cohesion: 0.09
Nodes (22): ../bloc/debt_bloc.dart, ../bloc/debt_event_state.dart, ../../../customer/presentation/bloc/customer_bloc.dart, ../../../customer/presentation/bloc/customer_event_state.dart, build, createState, _customers, DebtManagementPage (+14 more)

### Community 39 - "package:dartz/dartz.dart"
Cohesion: 0.14
Nodes (13): ../entities/home_metrics.dart, ../entities/wholesale_price_entity.dart, HomeRepositoryImpl, getHomeMetrics, HomeRepository, call, GetHomeMetricsUseCase, repository (+5 more)

### Community 40 - "product_add_page.dart"
Cohesion: 0.08
Nodes (28): ../bloc/product_bloc.dart, ../bloc/product_event.dart, ../bloc/product_state.dart, dart:io, _barcodeController, build, _categories, _commonUnits (+20 more)

### Community 41 - "printer_event_state.dart"
Cohesion: 0.22
Nodes (12): connectedMacAddress, devices, macAddress, message, PrinterError, PrinterInitial, PrinterLoaded, PrinterLoading (+4 more)

### Community 42 - "expense_page.dart"
Cohesion: 0.10
Nodes (20): ../bloc/expense_bloc.dart, ../bloc/expense_event.dart, ../bloc/expense_state.dart, _accentRed, _amountController, _animController, _bg, build (+12 more)

### Community 43 - "../../../../core/error/failures.dart"
Cohesion: 0.15
Nodes (13): ../../../../core/error/failures.dart, ../datasources/permission_local_datasource.dart, ../../domain/repositories/permission_repository.dart, ../entities/permission_entity.dart, getUserPermission, localDataSource, PermissionRepositoryImpl, getUserPermission (+5 more)

### Community 44 - "checkout_usecase.dart"
Cohesion: 0.12
Nodes (17): ../entities/cart_item_entity.dart, ../entities/transaction_entity.dart, TransactionRepositoryImpl, checkout, getTransactions, TransactionRepository, voidTransaction, call (+9 more)

### Community 45 - "CustomerBloc"
Cohesion: 0.16
Nodes (25): CustomerBloc, AddCustomerEvent, customer, CustomerError, CustomerEvent, CustomerInitial, CustomerLoaded, CustomerLoading (+17 more)

### Community 46 - "State"
Cohesion: 0.08
Nodes (30): AddExpenseSheet, AddExpenseSheetState, ReportTransactionDetailSheet, ReportTransactionDetailSheetState, _BackupPageBody, PrinterSettingsPage, QuickAddCustomerDialog, _QuickAddCustomerDialogState (+22 more)

### Community 47 - "printer_settings_page.dart"
Cohesion: 0.10
Nodes (19): ../bloc/printer_bloc.dart, ../bloc/printer_event_state.dart, _addressController, createState, dispose, initState, _loadStoreProfile, _logoPath (+11 more)

### Community 48 - "stock_local_datasource.dart"
Cohesion: 0.13
Nodes (15): addExpense, db, deleteExpense, ExpenseLocalDataSource, ExpenseLocalDataSourceImpl, getExpenses, adjustStock, db (+7 more)

### Community 49 - "add_expense_usecase.dart"
Cohesion: 0.12
Nodes (16): ../entities/expense_entity.dart, ExpenseRepositoryImpl, addExpense, deleteExpense, ExpenseRepository, getExpenses, AddExpenseUseCase, call (+8 more)

### Community 50 - "package:intl/intl.dart"
Cohesion: 0.11
Nodes (17): NullableRupiahExtension, RupiahExtension, toRupiah, build, customers, DebtPaymentsTab, isLoading, payments (+9 more)

### Community 51 - "backup_page.dart"
Cohesion: 0.08
Nodes (25): ../bloc/backup_bloc.dart, ../bloc/backup_event.dart, ../bloc/backup_state.dart, ../../../../core/database/database_json_codec.dart, ExportService, exportToExcel, exportToPdf, _applyRestoreJson (+17 more)

### Community 52 - "pos_setup_cubit.dart"
Cohesion: 0.10
Nodes (30): ../../../category/domain/entities/category_entity.dart, ../../../category/domain/usecases/category_usecases.dart, Cubit, ../../../customer/domain/usecases/customer_usecases.dart, AppRouter, categories, customers, getCategoriesUseCase (+22 more)

### Community 53 - "category_bloc.dart"
Cohesion: 0.12
Nodes (17): category_event_state.dart, ../../domain/usecases/category_usecases.dart, call, DeleteCategoryUseCase, GetCategoriesUseCase, InsertCategoryUseCase, repository, UpdateCategoryUseCase (+9 more)

### Community 54 - "adjustment_type_card.dart"
Cohesion: 0.11
Nodes (17): Color, activeBg, activeColor, AdjustmentTypeCard, build, icon, onChanged, selectedValue (+9 more)

### Community 55 - "cloud_backup_repository_impl.dart"
Cohesion: 0.11
Nodes (18): ../../../../core/error/exceptions.dart, ../datasources/cloud_backup_remote_datasource.dart, ../../domain/repositories/cloud_backup_repository.dart, CloudBackupRemoteDataSource, CloudBackupRemoteDataSourceImpl, deleteBackup, dio, downloadLatestBackup (+10 more)

### Community 56 - "app.dart"
Cohesion: 0.11
Nodes (18): ../core/theme/app_theme.dart, ../features/account/presentation/bloc/account_bloc.dart, ../features/account/presentation/bloc/account_event.dart, ../../features/auth/presentation/bloc/auth_bloc.dart, ../features/auth/presentation/bloc/auth_event.dart, ../../features/auth/presentation/bloc/auth_state.dart, ../features/category/presentation/bloc/category_bloc.dart, ../features/customer/presentation/bloc/customer_bloc.dart (+10 more)

### Community 57 - "customer_bloc.dart"
Cohesion: 0.12
Nodes (17): customer_event_state.dart, ../../domain/usecases/customer_usecases.dart, call, DeleteCustomerUseCase, GetCustomersUseCase, InsertCustomerUseCase, repository, UpdateCustomerUseCase (+9 more)

### Community 58 - "auth_repository_impl.dart"
Cohesion: 0.11
Nodes (17): ../datasources/auth_local_datasource.dart, ../../domain/entities/user_entity.dart, ../../domain/repositories/auth_repository.dart, ../entities/user_entity.dart, AuthRepositoryImpl, getCachedSession, hasUsers, localDataSource (+9 more)

### Community 59 - "home_state.dart"
Cohesion: 0.33
Nodes (8): HomeInitial, HomeMetricsError, HomeMetricsLoaded, HomeMetricsLoading, HomeState, message, metrics, props

### Community 60 - "add_expense_sheet.dart"
Cohesion: 0.12
Nodes (16): amountController, build, categoryController, controller, createState, ExpenseDarkTextField, hint, icon (+8 more)

### Community 61 - "user_management_page.dart"
Cohesion: 0.11
Nodes (18): build, createState, _db, initState, _isLoading, _loadData, _showAddUserDialog, _showChangePinDialog (+10 more)

### Community 62 - "pos_dialogs.dart"
Cohesion: 0.11
Nodes (16): amount_dialog.dart, ../bloc/pos_event_state.dart, checkout_bottom_sheet.dart, customer_selection_dialog.dart, build, CustomerBar, onTap, state (+8 more)

### Community 63 - "backup_bloc.dart"
Cohesion: 0.20
Nodes (9): backup_event.dart, backup_state.dart, ../../domain/usecases/cloud_backup_usecases.dart, UploadCloudBackupUseCase, downloadCloudBackupUseCase, _onDownload, _onUpload, uploadCloudBackupUseCase (+1 more)

### Community 64 - "customer_repository.dart"
Cohesion: 0.18
Nodes (10): ../../../debt/domain/entities/debt_payment_entity.dart, ../entities/customer_entity.dart, CustomerRepositoryImpl, CustomerRepository, deleteCustomer, getCustomers, getDebtPayments, insertCustomer (+2 more)

### Community 65 - "product_local_datasource.dart"
Cohesion: 0.09
Nodes (21): ../../../../core/services/activity_log_service.dart, ../datasources/product_local_datasource.dart, ../../domain/repositories/product_repository.dart, db, deleteProduct, getProductByBarcode, getProducts, insertProduct (+13 more)

### Community 66 - "stock_repository_impl.dart"
Cohesion: 0.12
Nodes (15): ../datasources/stock_local_datasource.dart, ../../domain/repositories/stock_repository.dart, ../entities/stock_history_entity.dart, adjustStock, getStockHistory, localDataSource, StockRepositoryImpl, adjustStock (+7 more)

### Community 67 - "subscription_status_entity.dart"
Cohesion: 0.25
Nodes (7): expiresAt, free, isActive, lastVerifiedAt, props, SubscriptionTier, tier

### Community 68 - "pos_product_catalog_pane.dart"
Cohesion: 0.11
Nodes (19): AddToCartEvent, build, categories, createState, dispose, _getCategoryIcon, initState, _onSearchFocusChange (+11 more)

### Community 69 - "wholesale_price_page.dart"
Cohesion: 0.18
Nodes (13): LoadWholesalePricesEvent, build, createState, dispose, initState, _priceController, product, _qtyController (+5 more)

### Community 70 - "kasirku_sembako Flutter POS app"
Cohesion: 0.12
Nodes (17): backend clean architecture (internal/domain/usecase/repository/delivery/platform), JSON snapshot cloud backup, Go Fiber + PostgreSQL backend, Google Play Billing subscription verification, clean architecture (feature-first layers), dartz Either/Failure error handling, Drift SQLite persistence, GoRouter centralized routing with auth guards (+9 more)

### Community 71 - "pos_cart_pane.dart"
Cohesion: 0.17
Nodes (12): cart_item.dart, cart_summary.dart, customer_bar.dart, UpdateCartItemQtyEvent, build, _C, customers, onCheckoutTap (+4 more)

### Community 72 - "category_repository_impl.dart"
Cohesion: 0.13
Nodes (15): ../datasources/category_local_datasource.dart, ../../domain/repositories/category_repository.dart, CategoryLocalDataSource, CategoryLocalDataSourceImpl, db, deleteCategory, getCategories, insertCategory (+7 more)

### Community 73 - "SubscriptionCubit"
Cohesion: 0.26
Nodes (12): BackupPage, SubscriptionCubit, message, previous, props, status, SubscriptionError, SubscriptionInitial (+4 more)

### Community 74 - "expense_bloc.dart"
Cohesion: 0.12
Nodes (16): ../../domain/usecases/add_expense_usecase.dart, ../../domain/usecases/delete_expense_usecase.dart, ../../domain/usecases/get_expenses_usecase.dart, expense_event.dart, expense_state.dart, addExpenseUseCase, _calculateTotalThisMonth, _calculateTotalToday (+8 more)

### Community 75 - "qty_adjust_dialog.dart"
Cohesion: 0.12
Nodes (18): FocusNode, RemoveFromCartEvent, appendDigit, build, clearDigits, controller, createState, deleteDigit (+10 more)

### Community 76 - "List"
Cohesion: 0.15
Nodes (11): id, isActive, props, role, username, id, minQty, price (+3 more)

### Community 77 - "report_summary_section.dart"
Cohesion: 0.12
Nodes (16): accent, build, color, flex, icon, label, ReportLabeledDot, ReportMetricTile (+8 more)

### Community 78 - "report_transaction_detail_sheet.dart"
Cohesion: 0.13
Nodes (14): build, createState, icon, isBold, isVoided, label, onTap, onVoid (+6 more)

### Community 79 - "receipt_preview_dialog.dart"
Cohesion: 0.14
Nodes (14): createState, _generateMonospaceReceipt, initState, isLoading, _loadStoreData, ReceiptPreviewDialog, _ReceiptPreviewDialogState, storeAddress (+6 more)

### Community 80 - "user_permissions_bottom_sheet.dart"
Cohesion: 0.12
Nodes (16): actionVoid, build, createState, db, _handleSave, initState, _isSaving, menuProduct (+8 more)

### Community 81 - "pos_page.dart"
Cohesion: 0.13
Nodes (15): ../bloc/pos_setup_cubit.dart, createState, _getCartPane, PosPage, _PosPageState, _showCheckoutDialog, _showCheckoutSuccessDialog, _showClearCartDialog (+7 more)

### Community 82 - "customer_selection_dialog.dart"
Cohesion: 0.13
Nodes (13): ../bloc/pos_bloc.dart, ../bloc/quick_customer_cubit.dart, ../../../customer/domain/entities/customer_entity.dart, build, customers, DebtSummaryCards, _C, createState (+5 more)

### Community 83 - "wholesale_price_bloc.dart"
Cohesion: 0.14
Nodes (14): ../../domain/usecases/wholesale_price_usecases.dart, call, DeleteWholesalePriceUseCase, GetWholesalePricesUseCase, InsertWholesalePriceUseCase, repository, deleteWholesalePriceUseCase, getWholesalePricesUseCase (+6 more)

### Community 84 - "IconData?"
Cohesion: 0.12
Nodes (14): IconData?, build, color, icon, MetricCard, subtitle, title, value (+6 more)

### Community 86 - "report_page.dart"
Cohesion: 0.14
Nodes (14): AnimationController, _animController, build, createState, dispose, _endDate, _fadeAnim, initState (+6 more)

### Community 87 - "@DataClassName"
Cohesion: 0.25
Nodes (15): @DataClassName, ActivityLogs, Categories, Customers, DebtPayments, Expenses, Permissions, Products (+7 more)

### Community 88 - "5. Komponen UI (Component Library)"
Cohesion: 0.05
Nodes (41): 1.1 Filosofi Desain, 1. Fondasi Visual (Design Foundation), 2.1 Palet Warna Utama, 2.2 Palet Warna Netral (Canvas & Surfaces), 2.3 Palet Warna Teks, 2.4 Palet Warna Status (Semantic Colors), 2.5 Warna Pastel Kartu Antrean (Order Card Palette), 2. Sistem Warna (Color System) (+33 more)

### Community 89 - "Subscription"
Cohesion: 0.22
Nodes (8): Duration, Time, Context, Pool, NewSubscriptionRepository(), Subscription, SubscriptionStatus, SubscriptionRepository

### Community 90 - "checkout_bottom_sheet.dart"
Cohesion: 0.11
Nodes (17): ../../../../core/utils/cash_suggestion_helper.dart, build, _C, NoConnectedDeviceSection, _C, cashController, cashReceived, CheckoutBottomSheetContent (+9 more)

### Community 91 - "category_edit_page.dart"
Cohesion: 0.11
Nodes (17): ../../domain/entities/category_entity.dart, CategoryModel, fromDrift, CategoryEntity, color, id, name, props (+9 more)

### Community 92 - "app_input.dart"
Cohesion: 0.13
Nodes (14): int?, AppInput, build, controller, hintText, keyboardType, label, maxLines (+6 more)

### Community 93 - "app_constants.dart"
Cohesion: 0.12
Nodes (16): accountAccessTokenKey, accountCreatedAtKey, accountEmailKey, accountIdKey, apiBaseUrl, AppConstants, appName, currentUserIdKey (+8 more)

### Community 94 - "AccountBloc"
Cohesion: 0.16
Nodes (18): ../../domain/entities/account_entity.dart, AccountModel, fromJson, AccountEntity, AccountBloc, account, AccountError, AccountInitial (+10 more)

### Community 95 - "VoidCallback"
Cohesion: 0.08
Nodes (25): build, controller, DebtSearchField, onChanged, addressController, build, _C, logoPath (+17 more)

### Community 96 - "subscription_upgrade_page.dart"
Cohesion: 0.15
Nodes (13): ../../../account/presentation/bloc/account_bloc.dart, ../../../account/presentation/bloc/account_state.dart, ../cubit/subscription_cubit.dart, ../cubit/subscription_state.dart, build, createState, initState, onSignIn (+5 more)

### Community 97 - "Load"
Cohesion: 0.31
Nodes (15): getEnv(), Duration, Load(), T, setRequiredEnv(), TestLoad_CustomValuesOverrideDefaults(), TestLoad_DefaultsAppliedWhenOptionalVarsUnset(), TestLoad_InvalidBackupMaxSizeMBReturnsError() (+7 more)

### Community 98 - "account_repository_impl_test.dart"
Cohesion: 0.08
Nodes (32): class MockAccountRemoteDataSource extends, class MockCloudBackupRemoteDataSource extends, Left, AuthFailure, CacheFailure, DatabaseFailure, Failure, message (+24 more)

### Community 99 - "wholesale_price_repository_impl.dart"
Cohesion: 0.12
Nodes (16): class, ../datasources/wholesale_price_local_datasource.dart, ../../domain/repositories/wholesale_price_repository.dart, db, deleteWholesalePrice, getWholesalePricesByProductId, insertWholesalePrice, WholesalePriceLocalDataSource (+8 more)

### Community 100 - "pos_bloc.dart"
Cohesion: 0.14
Nodes (13): ../../domain/usecases/checkout_usecase.dart, checkoutUseCase, getWholesalePricesUseCase, _onAddToCart, _onCheckout, _onClearCart, _onRemoveFromCart, _onSelectCustomer (+5 more)

### Community 101 - "transaction_entity.dart"
Cohesion: 0.14
Nodes (13): cashierId, createdAt, customerId, discount, id, items, paymentMethod, props (+5 more)

### Community 102 - "transaction_history_page.dart"
Cohesion: 0.15
Nodes (13): createState, _endDate, initState, _selectDateRange, _startDate, TransactionHistoryPage, _TransactionHistoryPageState, ../../../report/presentation/bloc/report_bloc.dart (+5 more)

### Community 103 - "user_add_dialog.dart"
Cohesion: 0.15
Nodes (13): build, createState, db, dispose, _handleSave, _isSaving, onSuccess, _pinController (+5 more)

### Community 104 - "report_loaded_content.dart"
Cohesion: 0.17
Nodes (11): Animation, ../bloc/report_bloc.dart, ../bloc/report_event_state.dart, ReportLoaded, fadeAnimation, state, report_app_bar.dart, report_states.dart (+3 more)

### Community 105 - "newTestApp"
Cohesion: 0.11
Nodes (27): T, newTestApp(), TestRequireAuth_ExpiredTokenReturns401(), TestRequireAuth_InvalidTokenReturns401(), TestRequireAuth_MalformedHeaderReturns401(), TestRequireAuth_MissingHeaderReturns401(), TestRequireAuth_ValidTokenPassesThroughAndSetsUserID(), Duration (+19 more)

### Community 106 - "stock_page.dart"
Cohesion: 0.17
Nodes (12): ../../../category/presentation/bloc/category_bloc.dart, ../../../category/presentation/bloc/category_event_state.dart, build, createState, dispose, _searchController, _selectedCategoryId, _stockFilter (+4 more)

### Community 107 - "cloud_backup_usecases.dart"
Cohesion: 0.20
Nodes (9): CloudBackupRepositoryImpl, CloudBackupRepository, call, DeleteBackupUseCase, DownloadCloudBackupUseCase, ListBackupsUseCase, repository, ../repositories/cloud_backup_repository.dart (+1 more)

### Community 108 - "backup_bloc_test.dart"
Cohesion: 0.15
Nodes (12): class MockDownloadCloudBackupUseCase extends, class MockUploadCloudBackupUseCase extends, package:bloc_test/bloc_test.dart, package:kasirku_sembako/features/settings/domain/usecases/cloud_backup_usecases.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_bloc.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_event.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_state.dart, buildBloc (+4 more)

### Community 109 - "SubscriptionUsecase"
Cohesion: 0.22
Nodes (11): ExpiryTime(), Time, deriveStatus(), Context, Duration, SubscriptionRepository, Time, TestDeriveStatus_ExpiredWithAutoRenewIsGracePeriod() (+3 more)

### Community 110 - "debt_bloc.dart"
Cohesion: 0.11
Nodes (17): ../../../customer/domain/repositories/customer_repository.dart, debt_event_state.dart, ../../domain/entities/debt_payment_entity.dart, ../../domain/usecases/debt_usecases.dart, ../entities/debt_payment_entity.dart, DebtPaymentModel, fromDrift, fromEntity (+9 more)

### Community 111 - "package:equatable/equatable.dart"
Cohesion: 0.14
Nodes (13): DateTime, createdAt, email, id, props, createdAt, id, notes (+5 more)

### Community 112 - "transaction_local_datasource.dart"
Cohesion: 0.11
Nodes (19): ../datasources/transaction_local_datasource.dart, ../../domain/entities/cart_item_entity.dart, ../../domain/entities/transaction_entity.dart, ../../domain/entities/transaction_item_entity.dart, ../../domain/repositories/transaction_repository.dart, db, _generateReceiptNumber, getTransactions (+11 more)

### Community 113 - "billing_local_datasource.dart"
Cohesion: 0.17
Nodes (12): InAppPurchase, BillingLocalDataSource, BillingLocalDataSourceImpl, buyPro, completePurchase, _iap, purchaseStream, queryProProduct (+4 more)

### Community 114 - "auth_local_datasource.dart"
Cohesion: 0.07
Nodes (29): ../constants/app_constants.dart, ../database/app_database.dart, build, DioClient, ActivityLogService, _db, log, _secureStorage (+21 more)

### Community 115 - "expense_state.dart"
Cohesion: 0.22
Nodes (12): ExpenseActionSuccess, ExpenseError, ExpenseInitial, ExpenseLoaded, ExpenseLoading, expenses, ExpenseState, groupedByDate (+4 more)

### Community 116 - "expense_summary_section.dart"
Cohesion: 0.15
Nodes (12): bgColor, build, color, ExpenseMiniMetric, ExpenseSummarySection, icon, itemCount, label (+4 more)

### Community 117 - "ProductEntity"
Cohesion: 0.16
Nodes (16): ../../domain/entities/product_entity.dart, fromDrift, ProductModel, toCompanion, ProductEntity, message, product, ProductError (+8 more)

### Community 118 - "Equatable"
Cohesion: 0.18
Nodes (20): Equatable, WholesalePriceBloc, AddWholesalePriceEvent, DeleteWholesalePriceEvent, id, message, prices, productId (+12 more)

### Community 119 - "home_page.dart"
Cohesion: 0.13
Nodes (20): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../bloc/home_bloc.dart, ../bloc/home_event.dart, ../bloc/home_state.dart, HomeBloc, HomeEvent (+12 more)

### Community 120 - "auth_handler.go"
Cohesion: 0.29
Nodes (8): Ctx, User, NewAuthHandler(), toUserDTO(), AuthHandler, authRequest, authResponse, userDTO

### Community 121 - "PrinterBloc"
Cohesion: 0.44
Nodes (11): PrinterBloc, ConnectPrinterEvent, DisconnectPrinterEvent, PrinterEvent, PrintReceiptEvent, PrintTestEvent, ScanPrintersEvent, build (+3 more)

### Community 122 - "report_bloc.dart"
Cohesion: 0.17
Nodes (11): ../../../../core/services/export_service.dart, exportService, getTransactionsUseCase, _onExportExcel, _onExportPdf, _onLoadReports, _onVoidTransaction, voidTransactionUseCase (+3 more)

### Community 123 - "printer_bloc.dart"
Cohesion: 0.17
Nodes (11): ../../../../core/services/printer_service.dart, _connectedMac, _devices, _onConnectPrinter, _onDisconnectPrinter, _onPrintReceipt, _onPrintTest, _onScanPrinters (+3 more)

### Community 124 - "customer_local_datasource.dart"
Cohesion: 0.09
Nodes (22): ../datasources/customer_local_datasource.dart, ../../../debt/data/models/debt_payment_model.dart, ../../domain/repositories/customer_repository.dart, CustomerLocalDataSource, CustomerLocalDataSourceImpl, db, deleteCustomer, getCustomers (+14 more)

### Community 125 - "customer_page.dart"
Cohesion: 0.22
Nodes (9): ../bloc/customer_event_state.dart, ../../../debt/presentation/bloc/debt_bloc.dart, ../../../debt/presentation/bloc/debt_event_state.dart, createState, CustomerPage, _CustomerPageState, dispose, _searchController (+1 more)

### Community 126 - "main"
Cohesion: 0.31
Nodes (5): main(), Context, New(), Client, Service

### Community 127 - "AuthBloc"
Cohesion: 0.14
Nodes (24): UserModel, UserEntity, AuthBloc, AuthEvent, CheckSessionEvent, LoginSubmittedEvent, LogoutEvent, pin (+16 more)

### Community 128 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 129 - "product_entity.dart"
Cohesion: 0.17
Nodes (11): barcode, categoryId, id, imagePath, isActive, name, props, purchasePrice (+3 more)

### Community 130 - "BackupBloc"
Cohesion: 0.33
Nodes (11): BackupBloc, BackupError, BackupInitial, BackupState, CloudBackupDownloading, CloudBackupDownloadSuccess, CloudBackupUploading, CloudBackupUploadSuccess (+3 more)

### Community 131 - "activity_log_page.dart"
Cohesion: 0.18
Nodes (11): ActivityLogPage, _ActivityLogPageState, build, createState, _db, _getColorForAction, _getIconForAction, initState (+3 more)

### Community 132 - "user_change_pin_dialog.dart"
Cohesion: 0.17
Nodes (12): ../../../../core/utils/pin_utils.dart, build, createState, db, dispose, _handleSave, _isSaving, onSuccess (+4 more)

### Community 133 - "UserRepository"
Cohesion: 0.39
Nodes (5): Context, Pool, User, NewUserRepository(), UserRepository

### Community 134 - "App"
Cohesion: 0.15
Nodes (12): Ctx, NewBackupHandler(), Ctx, Handler, RequireAuth(), UserID(), Handler, RequirePro() (+4 more)

### Community 135 - "NewAuthUsecase"
Cohesion: 0.47
Nodes (10): NewAuthUsecase(), T, newFakeUserRepo(), TestLogin_SuccessWithCorrectPassword(), TestLogin_UnknownEmailReturnsInvalidCredentialsNotNotFound(), TestLogin_WrongPasswordReturnsInvalidCredentials(), TestMe_ReturnsUserByID(), TestMe_UnknownIDReturnsNotFound() (+2 more)

### Community 136 - "category_page.dart"
Cohesion: 0.24
Nodes (8): ../bloc/category_bloc.dart, ../bloc/category_event_state.dart, CategoryPage, _CategoryPageState, createState, category, _showConfirmDeleteDialog, ../widgets/category_list_content.dart

### Community 137 - "Flutter Framework"
Cohesion: 0.21
Nodes (12): iOS Launch Screen Assets, GTK3 Dependency, Linux Build System, Flutter Linux Library, Linux Runner Executable, Flutter Framework, Getting Started, kasirku_sembako (+4 more)

### Community 138 - "account_event.dart"
Cohesion: 0.27
Nodes (10): AccountEvent, CheckAccountSessionEvent, email, LoginSubmittedEvent, LogoutEvent, password, props, RegisterSubmittedEvent (+2 more)

### Community 139 - "customer_add_page.dart"
Cohesion: 0.20
Nodes (10): build, createState, CustomerAddPage, _CustomerAddPageState, _debtController, dispose, _nameController, _notesController (+2 more)

### Community 140 - "Exception"
Cohesion: 0.36
Nodes (7): Exception, InvalidBackupFormatException, AuthException, CacheException, message, NetworkException, ServerException

### Community 141 - "ProductBloc"
Cohesion: 0.13
Nodes (28): ProductBloc, AddProductEvent, barcode, DeleteProductEvent, id, LoadProductsEvent, product, ProductEvent (+20 more)

### Community 142 - "CLAUDE.md"
Cohesion: 0.29
Nodes (5): Architecture, Commands, Project, UI/design, Workflow

### Community 143 - "transaction_item_entity.dart"
Cohesion: 0.17
Nodes (11): discount, id, price, productId, productName, props, purchasePrice, qty (+3 more)

### Community 144 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 145 - "product_repository.dart"
Cohesion: 0.29
Nodes (6): ../entities/product_entity.dart, deleteProduct, getProductByBarcode, getProducts, insertProduct, updateProduct

### Community 146 - "ExpenseBloc"
Cohesion: 0.25
Nodes (14): ExpenseBloc, AddExpenseEvent, DeleteExpenseEvent, endDate, expense, ExpenseEvent, id, LoadExpensesEvent (+6 more)

### Community 147 - "subscription_repository.dart"
Cohesion: 0.29
Nodes (6): ../entities/subscription_status_entity.dart, getCachedStatus, purchasePro, refreshStatus, restorePurchases, SubscriptionRepository

### Community 148 - "wholesale_price_list_item.dart"
Cohesion: 0.18
Nodes (10): ../bloc/wholesale_price_bloc.dart, ../bloc/wholesale_price_event_state.dart, ../../domain/entities/wholesale_price_entity.dart, fromDrift, WholesalePriceModel, WholesalePriceEntity, price, retailPrice (+2 more)

### Community 149 - "subscription_cubit.dart"
Cohesion: 0.10
Nodes (20): ../../domain/usecases/subscription_usecases.dart, call, GetCachedSubscriptionStatusUseCase, PurchaseProUseCase, RefreshSubscriptionStatusUseCase, repository, RestorePurchasesUseCase, getCachedSubscriptionStatusUseCase (+12 more)

### Community 150 - "cart_item_entity.dart"
Cohesion: 0.18
Nodes (10): double get, ../../../../features/product/domain/entities/product_entity.dart, ../../../../features/wholesale_price/domain/entities/wholesale_price_entity.dart, CartItemEntity, copyWith, product, props, quantity (+2 more)

### Community 151 - "permission_local_datasource.dart"
Cohesion: 0.40
Nodes (5): db, getUserPermission, PermissionLocalDataSource, PermissionLocalDataSourceImpl, ../models/permission_model.dart

### Community 152 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 153 - "di/injection.dart"
Cohesion: 0.22
Nodes (8): app/app.dart, di/injection.dart, features/subscription/domain/repositories/subscription_repository.dart, init, initializeDateFormatting, main, null, package:intl/date_symbol_data_local.dart

### Community 154 - "subscription_handler.go"
Cohesion: 0.36
Nodes (6): Ctx, NewSubscriptionHandler(), toStatusResponse(), SubscriptionHandler, subscriptionStatusResponse, verifyRequest

### Community 155 - "AuthUsecase"
Cohesion: 0.33
Nodes (6): Context, Duration, User, normalizeEmail(), AuthUsecase, UserRepository

### Community 156 - "kasirku_sembako backend"
Cohesion: 0.40
Nodes (4): Deploying, Google Play Developer API access, kasirku_sembako backend, Setup

### Community 157 - "../../domain/entities/subscription_status_entity.dart"
Cohesion: 0.40
Nodes (4): ../../domain/entities/subscription_status_entity.dart, fromJson, SubscriptionStatusModel, SubscriptionStatusEntity

### Community 158 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 159 - "package:flutter/material.dart"
Cohesion: 0.11
Nodes (15): app_colors.dart, double?, AppTheme, build, ProBadge, build, VoidConfirmDialog, AppButton (+7 more)

### Community 160 - "printer_service.dart"
Cohesion: 0.22
Nodes (8): ../../features/transaction/domain/entities/transaction_entity.dart, connect, disconnect, getPairedDevices, PrinterService, printReceipt, printTest, package:esc_pos_utils_plus/esc_pos_utils_plus.dart

### Community 161 - "debt_payment_entity.dart"
Cohesion: 0.22
Nodes (8): amount, cashierId, createdAt, customerId, id, notes, paymentMethod, props

### Community 162 - "cloud_backup_repository.dart"
Cohesion: 0.22
Nodes (8): CloudBackupSummary, createdAt, deleteBackup, downloadLatestBackup, id, listBackups, sizeBytes, uploadBackup

### Community 163 - "backup_event.dart"
Cohesion: 0.31
Nodes (8): BackupEvent, DownloadCloudBackupRequested, payload, props, UploadCloudBackupRequested, build, Map, main

### Community 164 - "AppIcon.appiconset"
Cohesion: 0.36
Nodes (9): AppIcon.appiconset, app_icon_1024.png, app_icon_128.png, app_icon_16.png, app_icon_256.png, app_icon_32.png, app_icon_512.png, app_icon_64.png (+1 more)

### Community 165 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 166 - "category_list_content.dart"
Cohesion: 0.25
Nodes (8): category_list_item.dart, build, categories, CategoryListContent, _CategoryListContentState, createState, dispose, _searchController

### Community 167 - "expense_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../datasources/expense_local_datasource.dart, ../../domain/entities/expense_entity.dart, ../../domain/repositories/expense_repository.dart, addExpense, deleteExpense, getExpenses, localDataSource, _mapToEntity

### Community 168 - "account_repository.dart"
Cohesion: 0.25
Nodes (7): ../entities/account_entity.dart, AccountRepositoryImpl, AccountRepository, getCachedAccount, login, logout, register

### Community 169 - "category_repository.dart"
Cohesion: 0.25
Nodes (7): ../entities/category_entity.dart, CategoryRepositoryImpl, CategoryRepository, deleteCategory, getCategories, insertCategory, updateCategory

### Community 170 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 171 - "category_add_page.dart"
Cohesion: 0.25
Nodes (8): build, CategoryAddPage, _CategoryAddPageState, createState, dispose, _nameController, _showStyledSnackBar, ../../../../shared/widgets/app_input.dart

### Community 172 - "customer_entity.dart"
Cohesion: 0.25
Nodes (7): copyWith, debtAmount, id, name, notes, phone, props

### Community 173 - "expense_entity.dart"
Cohesion: 0.25
Nodes (7): amount, category, date, ExpenseEntity, id, notes, receiptPath

### Community 174 - "printer_devices_list_section.dart"
Cohesion: 0.25
Nodes (7): build, _C, connectedMacAddress, devices, onConnect, PrinterDevicesListSection, package:print_bluetooth_thermal/print_bluetooth_thermal.dart

### Community 175 - "cart_item.dart"
Cohesion: 0.25
Nodes (7): build, CartItem, EmptyCart, item, onDecrement, onIncrement, onQtyTap

### Community 176 - "permission_entity.dart"
Cohesion: 0.25
Nodes (7): actionVoid, id, menuProduct, menuReport, menuStock, props, userId

### Community 179 - "Android Launcher Icon"
Cohesion: 0.33
Nodes (6): Android Launcher Icon, ic_launcher (hdpi), ic_launcher (mdpi), ic_launcher (xhdpi), ic_launcher (xxhdpi), ic_launcher (xxxhdpi)

### Community 180 - "fakeUserRepo"
Cohesion: 0.67
Nodes (3): Context, User, fakeUserRepo

### Community 181 - "pin_utils.dart"
Cohesion: 0.11
Nodes (17): dart:convert, dart:math, dart:typed_data, _bytesToHex, _derivedKeyLengthBytes, generateSalt, hashPinWithSalt, _hexToBytes (+9 more)

### Community 182 - "LaunchImage.imageset"
Cohesion: 0.53
Nodes (6): LaunchImage.imageset, Contents.json, LaunchImage@2x.png, LaunchImage@3x.png, LaunchImage.png (1x), README.md

### Community 183 - "home_metrics.dart"
Cohesion: 0.29
Nodes (6): expenses, HomeMetrics, lowStock, omset, props, trxCount

### Community 184 - "expense_widgets.dart"
Cohesion: 0.40
Nodes (4): add_expense_sheet.dart, expense_app_bar.dart, expense_list_section.dart, expense_summary_section.dart

### Community 185 - "repository.go"
Cohesion: 0.50
Nodes (3): BackupRepository, SubscriptionRepository, UserRepository

### Community 186 - "opencode.json"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

### Community 187 - "Icon-192.png"
Cohesion: 0.67
Nodes (4): Icon-192.png, Icon-512.png, Icon-maskable-192.png, Icon-maskable-512.png

## Knowledge Gaps
- **1631 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `github.com/dimassfeb-09/kasku_sembako/backend`, `authRequest`, `verifyRequest` (+1626 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **22 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `App` connect `App` to `DebtBloc`, `Stock Management Bloc`, `POS Cart & Checkout`, `newTestApp`, `App Router & Navigation`, `CustomerBloc`, `ProductBloc`, `Expense Management UI`, `ExpenseBloc`, `Report Bloc (Excel/PDF)`, `CategoryBloc`, `home_page.dart`, `app.dart`, `PrinterBloc`, `Equatable`, `AccountBloc`, `AuthBloc`?**
  _High betweenness centrality (0.175) - this node is a cross-community bridge._
- **Why does `NewRouter()` connect `App` to `auth_handler.go`, `subscription_handler.go`, `main`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Why does `newTestApp()` connect `newTestApp` to `App`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `github.com/dimassfeb-09/kasku_sembako/backend` to the rest of the system?**
  _1631 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Database Schema` be split into smaller, more focused modules?**
  _Cohesion score 0.013888888888888888 - nodes in this community are weakly interconnected._
- **Should `Clean Architecture Data Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Should `Platform Native Plugins` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._