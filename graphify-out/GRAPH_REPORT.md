# Graph Report - .  (2026-07-15)

## Corpus Check
- 367 files · ~137,484 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3374 nodes · 5769 edges · 210 communities (193 shown, 17 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 102 edges (avg confidence: 0.81)
- Token cost: 10 input · 25 output

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
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132
- Community 133
- Community 134
- Community 135
- Community 136
- Community 137
- Community 138
- Community 139
- Community 140
- Community 141
- Community 142
- Community 143
- Community 144
- Community 145
- Community 146
- Community 147
- Community 148
- Community 149
- Community 150
- Community 151
- Community 152
- Community 153
- Community 154
- Community 155
- Community 156
- Community 157
- Community 158
- Community 159
- Community 160
- Community 161
- Community 162
- Community 163
- Community 164
- Community 165
- Community 166
- Community 167
- Community 168
- Community 169
- Community 170
- Community 171
- Community 172
- Community 173
- Community 174
- Community 175
- Community 176
- Community 177
- Community 178
- Community 179
- Community 180
- Community 181
- Community 182
- Community 183
- Community 184
- Community 185
- Community 186
- Community 187
- Community 188
- Community 189
- Community 190
- Community 191
- Community 192
- Community 193
- Community 195
- Community 199
- Community 200
- Community 202
- Community 204
- Community 205
- Community 206
- Community 207
- Community 208
- Community 209

## God Nodes (most connected - your core abstractions)
1. `ProductBloc` - 43 edges
2. `PosBloc` - 41 edges
3. `CategoryBloc` - 33 edges
4. `CustomerBloc` - 31 edges
5. `AuthBloc` - 30 edges
6. `AppDatabase` - 26 edges
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
- `project graphify configuration and workflow rules` --references--> `graphify knowledge graph builder`  [EXTRACTED]
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

## Communities (210 total, 17 thin omitted)

### Community 0 - "Database Schema"
Cohesion: 0.01
Nodes (137): class SubscriptionCache extends, ColumnFilters, ColumnOrderings, GeneratedColumn, GeneratedDatabase, int get, Iterable, _openConnection (+129 more)

### Community 1 - "Clean Architecture Data Layer"
Cohesion: 0.03
Nodes (65): ../core/network/dio_client.dart, ../features/account/data/datasources/account_remote_datasource.dart, ../features/account/data/repositories/account_repository_impl.dart, ../features/account/domain/repositories/account_repository.dart, ../features/account/domain/usecases/account_usecases.dart, ../features/auth/data/datasources/auth_local_datasource.dart, ../features/auth/data/repositories/auth_repository_impl.dart, ../features/auth/domain/repositories/auth_repository.dart (+57 more)

### Community 2 - "Platform Native Plugins"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 3 - "Database Table Columns"
Cohesion: 0.04
Nodes (55): BoolColumn get, DateTimeColumn get, IntColumn get, action, actionVoid, amount, barcode, cashierId (+47 more)

### Community 4 - "Go Backend Subscriptions"
Cohesion: 0.08
Nodes (36): Duration, Time, ExpiryTime(), Context, Time, New(), Context, Pool (+28 more)

### Community 5 - "macOS/iOS Platform Bridges"
Cohesion: 0.05
Nodes (33): Any, Cocoa, file_picker, file_selector_macos, Flutter, flutter_secure_storage_darwin, FlutterAppDelegate, FlutterImplicitEngineBridge (+25 more)

### Community 6 - "Go Backend Backups"
Cohesion: 0.09
Nodes (24): RawMessage, Time, Context, Pool, NewBackupRepository(), Context, RawMessage, NewBackupUsecase() (+16 more)

### Community 7 - "Stock Management Bloc"
Cohesion: 0.07
Nodes (42): ../bloc/stock_bloc.dart, ../bloc/stock_event_state.dart, ../../domain/usecases/stock_usecases.dart, adjustStockUseCase, getStockHistoryUseCase, _onAdjustStock, _onLoadStockHistory, StockBloc (+34 more)

### Community 8 - "POS Cart & Checkout"
Cohesion: 0.10
Nodes (40): PosBloc, AddToCartEvent, cartItems, cashReceived, CheckoutEvent, ClearCartEvent, customer, discount (+32 more)

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
Cohesion: 0.07
Nodes (26): app_colors.dart, ../../core/theme/app_colors.dart, ../../../customer/presentation/widgets/customer_list_item.dart, AppTheme, build, customers, DebtorsTab, isLoading (+18 more)

### Community 13 - "Expense Management UI"
Cohesion: 0.09
Nodes (27): build, _categoryConfig, exp, ExpenseEmptyState, ExpenseGroupedList, ExpenseListHeader, ExpenseTile, grouped (+19 more)

### Community 14 - "Product Card Widget"
Cohesion: 0.07
Nodes (29): _animController, availableStock, build, _controller, createState, currentQty, dispose, FloatingPlusOne (+21 more)

### Community 15 - "Account Auth Bloc"
Cohesion: 0.09
Nodes (26): ../bloc/account_bloc.dart, ../bloc/account_event.dart, ../bloc/account_state.dart, AccountHomePage, email, onSignIn, _SignedOutView, AccountLoginPage (+18 more)

### Community 16 - "Subscription Mock Tests"
Cohesion: 0.08
Nodes (27): class MockGetCachedSubscriptionStatusUseCase extends, class MockRefreshSubscriptionStatusUseCase extends, class MockRestorePurchasesUseCase extends, ../entities/subscription_status_entity.dart, call, GetCachedSubscriptionStatusUseCase, PurchaseProUseCase, RefreshSubscriptionStatusUseCase (+19 more)

### Community 17 - "Account Remote DataSource"
Cohesion: 0.08
Nodes (26): ../constants/app_constants.dart, ../../../../core/constants/app_constants.dart, ../datasources/account_remote_datasource.dart, ../../domain/entities/account_entity.dart, ../../domain/repositories/account_repository.dart, build, DioClient, AccountRemoteDataSource (+18 more)

### Community 18 - "Database Companion Models"
Cohesion: 0.13
Nodes (29): Insertable, UpdateCompanion, ActivityLog, ActivityLogsCompanion, CategoriesCompanion, Category, Customer, CustomersCompanion (+21 more)

### Community 19 - "Report Bloc (Excel/PDF)"
Cohesion: 0.14
Nodes (28): ReportBloc, endDate, ExportExcelEvent, ExportPdfEvent, LoadReportsEvent, message, props, ReportError (+20 more)

### Community 20 - "Community 20"
Cohesion: 0.08
Nodes (24): class MockBillingLocalDataSource extends, class MockSubscriptionRemoteDataSource extends, SubscriptionRepositoryImpl, package:drift/native.dart, package:flutter_test/flutter_test.dart, package:kasirku_sembako/app/app.dart, package:kasirku_sembako/core/database/app_database.dart, package:kasirku_sembako/core/database/database_json_codec.dart (+16 more)

### Community 21 - "Community 21"
Cohesion: 0.08
Nodes (26): dart:async, ../datasources/billing_local_datasource.dart, ../datasources/subscription_remote_datasource.dart, Dio, ../../domain/repositories/subscription_repository.dart, dio, getStatus, _mapDioException (+18 more)

### Community 22 - "Community 22"
Cohesion: 0.15
Nodes (27): CategoryBloc, AddCategoryEvent, categories, category, CategoryError, CategoryEvent, CategoryInitial, CategoryLoaded (+19 more)

### Community 23 - "Community 23"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 24 - "Community 24"
Cohesion: 0.10
Nodes (22): _, @DriftDatabase, ../../../../core/database/app_database.dart, ../../domain/entities/home_metrics.dart, AppDatabase, fromDrift, addExpense, db (+14 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (25): _barcodeController, build, _categories, _commonUnits, createState, _customUnitController, dispose, _imageDeleted (+17 more)

### Community 26 - "Community 26"
Cohesion: 0.10
Nodes (23): account_event.dart, account_state.dart, ../../domain/usecases/account_usecases.dart, call, GetCachedAccountUseCase, LoginAccountUseCase, LogoutAccountUseCase, RegisterAccountUseCase (+15 more)

### Community 27 - "Community 27"
Cohesion: 0.09
Nodes (23): ../bloc/auth_bloc.dart, ../bloc/auth_state.dart, ../../../../core/utils/pin_utils.dart, build, build, _confirmPinController, createState, dispose (+15 more)

### Community 28 - "Community 28"
Cohesion: 0.10
Nodes (21): ../bloc/customer_bloc.dart, ../bloc/customer_event_state.dart, ../../domain/entities/customer_entity.dart, CustomerModel, fromDrift, CustomerEntity, build, createState (+13 more)

### Community 29 - "Community 29"
Cohesion: 0.08
Nodes (21): build, label, onChanged, selectedValue, StockFilterChip, value, build, isSaving (+13 more)

### Community 30 - "Community 30"
Cohesion: 0.09
Nodes (20): ../../../../core/utils/currency_formatter.dart, dashed_divider.dart, TransactionEntity, build, CartSummary, onCheckout, onDiscountTap, onTaxTap (+12 more)

### Community 31 - "Community 31"
Cohesion: 0.10
Nodes (21): ../../domain/usecases/product_usecases.dart, call, DeleteProductUseCase, GetProductByBarcodeUseCase, GetProductsUseCase, InsertProductUseCase, repository, UpdateProductUseCase (+13 more)

### Community 32 - "Community 32"
Cohesion: 0.17
Nodes (22): LoadCustomersEvent, CustomerListItem, _showPayDebtDialog, DebtBloc, amount, customerId, DebtError, DebtEvent (+14 more)

### Community 33 - "Community 33"
Cohesion: 0.09
Nodes (21): build, ExpenseAppBar, ExpenseFAB, onBack, onTap, preferredSize, build, color (+13 more)

### Community 34 - "Community 34"
Cohesion: 0.11
Nodes (21): LoadProductsEvent, build, product, StockProductListItem, build, initState, createState, _db (+13 more)

### Community 35 - "Community 35"
Cohesion: 0.09
Nodes (22): project graphify configuration and workflow rules, URL ingestion and file watching, graph export formats (Wiki/Neo4j/FalkorDB/SVG/GraphML/MCP), edge confidence score rubric, node ID format convention, extraction subagent specification, GitHub clone and cross-repo merge, post-commit hook and CLAUDE.md integration (+14 more)

### Community 36 - "Community 36"
Cohesion: 0.10
Nodes (20): app_database.dart, Exception, DatabaseJsonCodec, _deleteAllFor, exportToJson, importFromJson, _insertAllFor, InvalidBackupFormatException (+12 more)

### Community 37 - "Community 37"
Cohesion: 0.11
Nodes (20): auth_event.dart, auth_state.dart, ../../domain/usecases/auth_usecases.dart, call, GetSessionUseCase, HasUsersUseCase, LoginUseCase, LogoutUseCase (+12 more)

### Community 38 - "Community 38"
Cohesion: 0.10
Nodes (21): ../bloc/debt_bloc.dart, ../bloc/debt_event_state.dart, ../../../customer/presentation/bloc/customer_bloc.dart, ../../../customer/presentation/bloc/customer_event_state.dart, build, createState, _customers, DebtManagementPage (+13 more)

### Community 39 - "Community 39"
Cohesion: 0.10
Nodes (18): ../../../../core/error/failures.dart, ../datasources/home_local_datasource.dart, ../../domain/repositories/home_repository.dart, ../entities/home_metrics.dart, getHomeMetrics, HomeRepositoryImpl, localDataSource, getHomeMetrics (+10 more)

### Community 40 - "Community 40"
Cohesion: 0.10
Nodes (21): _barcodeController, build, _categories, _commonUnits, createState, _customUnitController, dispose, _imagePath (+13 more)

### Community 41 - "Community 41"
Cohesion: 0.20
Nodes (21): PrinterBloc, connectedMacAddress, ConnectPrinterEvent, devices, DisconnectPrinterEvent, macAddress, message, PrinterError (+13 more)

### Community 42 - "Community 42"
Cohesion: 0.10
Nodes (20): ../bloc/expense_bloc.dart, ../bloc/expense_event.dart, ../bloc/expense_state.dart, _accentRed, _amountController, _animController, _bg, build (+12 more)

### Community 43 - "Community 43"
Cohesion: 0.11
Nodes (17): ../datasources/permission_local_datasource.dart, ../../domain/repositories/permission_repository.dart, ../entities/permission_entity.dart, ../entities/wholesale_price_entity.dart, getUserPermission, localDataSource, PermissionRepositoryImpl, getUserPermission (+9 more)

### Community 44 - "Community 44"
Cohesion: 0.12
Nodes (17): ../entities/cart_item_entity.dart, ../entities/transaction_entity.dart, TransactionRepositoryImpl, checkout, getTransactions, TransactionRepository, voidTransaction, call (+9 more)

### Community 45 - "Community 45"
Cohesion: 0.19
Nodes (20): CustomerBloc, AddCustomerEvent, customer, CustomerError, CustomerEvent, CustomerInitial, CustomerLoaded, CustomerLoading (+12 more)

### Community 46 - "Community 46"
Cohesion: 0.10
Nodes (20): build, createState, dispose, _DropdownSearchSheet, _DropdownSearchSheetState, _filteredItems, hint, initState (+12 more)

### Community 47 - "Community 47"
Cohesion: 0.10
Nodes (19): ../bloc/printer_bloc.dart, ../bloc/printer_event_state.dart, _addressController, createState, dispose, initState, _loadStoreProfile, _logoPath (+11 more)

### Community 48 - "Community 48"
Cohesion: 0.12
Nodes (18): ../../../../core/services/activity_log_service.dart, ../database/app_database.dart, FlutterSecureStorage, ActivityLogService, _db, log, _secureStorage, adjustStock (+10 more)

### Community 49 - "Community 49"
Cohesion: 0.12
Nodes (16): ../entities/expense_entity.dart, ExpenseRepositoryImpl, addExpense, deleteExpense, ExpenseRepository, getExpenses, AddExpenseUseCase, call (+8 more)

### Community 50 - "Community 50"
Cohesion: 0.11
Nodes (17): NullableRupiahExtension, RupiahExtension, toRupiah, build, customers, DebtPaymentsTab, isLoading, payments (+9 more)

### Community 51 - "Community 51"
Cohesion: 0.11
Nodes (18): ../bloc/backup_bloc.dart, ../bloc/backup_event.dart, ../bloc/backup_state.dart, ../../../../core/database/database_json_codec.dart, _applyRestoreJson, _backupDatabase, BackupPage, createState (+10 more)

### Community 52 - "Community 52"
Cohesion: 0.15
Nodes (18): ../../../category/domain/entities/category_entity.dart, ../../../category/domain/usecases/category_usecases.dart, Cubit, AppRouter, categories, customers, getCategoriesUseCase, getCustomersUseCase (+10 more)

### Community 53 - "Community 53"
Cohesion: 0.12
Nodes (17): category_event_state.dart, ../../domain/usecases/category_usecases.dart, call, DeleteCategoryUseCase, GetCategoriesUseCase, InsertCategoryUseCase, repository, UpdateCategoryUseCase (+9 more)

### Community 54 - "Community 54"
Cohesion: 0.11
Nodes (17): Color, activeBg, activeColor, AdjustmentTypeCard, build, icon, onChanged, selectedValue (+9 more)

### Community 55 - "Community 55"
Cohesion: 0.12
Nodes (17): ../../../../core/error/exceptions.dart, ../datasources/cloud_backup_remote_datasource.dart, ../../domain/repositories/cloud_backup_repository.dart, CloudBackupRemoteDataSource, CloudBackupRemoteDataSourceImpl, deleteBackup, dio, downloadLatestBackup (+9 more)

### Community 56 - "Community 56"
Cohesion: 0.11
Nodes (18): ../core/theme/app_theme.dart, ../features/account/presentation/bloc/account_bloc.dart, ../features/account/presentation/bloc/account_event.dart, ../../features/auth/presentation/bloc/auth_bloc.dart, ../features/auth/presentation/bloc/auth_event.dart, ../../features/auth/presentation/bloc/auth_state.dart, ../features/category/presentation/bloc/category_bloc.dart, ../features/customer/presentation/bloc/customer_bloc.dart (+10 more)

### Community 57 - "Community 57"
Cohesion: 0.12
Nodes (17): customer_event_state.dart, ../../domain/usecases/customer_usecases.dart, call, DeleteCustomerUseCase, GetCustomersUseCase, InsertCustomerUseCase, repository, UpdateCustomerUseCase (+9 more)

### Community 58 - "Community 58"
Cohesion: 0.11
Nodes (17): ../datasources/auth_local_datasource.dart, ../../domain/entities/user_entity.dart, ../../domain/repositories/auth_repository.dart, ../entities/user_entity.dart, AuthRepositoryImpl, getCachedSession, hasUsers, localDataSource (+9 more)

### Community 59 - "Community 59"
Cohesion: 0.18
Nodes (18): Equatable, HomeMetrics, HomeBloc, HomeEvent, LoadHomeMetricsEvent, HomeInitial, HomeMetricsError, HomeMetricsLoaded (+10 more)

### Community 60 - "Community 60"
Cohesion: 0.11
Nodes (18): AddExpenseSheet, AddExpenseSheetState, amountController, build, categoryController, controller, createState, ExpenseDarkTextField (+10 more)

### Community 61 - "Community 61"
Cohesion: 0.11
Nodes (18): build, createState, _db, initState, _isLoading, _loadData, _showAddUserDialog, _showChangePinDialog (+10 more)

### Community 62 - "Community 62"
Cohesion: 0.11
Nodes (16): amount_dialog.dart, checkout_bottom_sheet.dart, customer_selection_dialog.dart, build, _C, NoConnectedDeviceSection, _C, showCheckoutDialog (+8 more)

### Community 63 - "Community 63"
Cohesion: 0.12
Nodes (16): backup_event.dart, backup_state.dart, ../../domain/usecases/cloud_backup_usecases.dart, call, DeleteBackupUseCase, DownloadCloudBackupUseCase, ListBackupsUseCase, repository (+8 more)

### Community 64 - "Community 64"
Cohesion: 0.11
Nodes (16): ../../../customer/domain/repositories/customer_repository.dart, ../../../debt/domain/entities/debt_payment_entity.dart, ../entities/customer_entity.dart, ../entities/debt_payment_entity.dart, CustomerRepositoryImpl, CustomerRepository, deleteCustomer, getCustomers (+8 more)

### Community 65 - "Community 65"
Cohesion: 0.11
Nodes (16): ../datasources/product_local_datasource.dart, ../../domain/repositories/product_repository.dart, ../entities/product_entity.dart, deleteProduct, getProductByBarcode, getProducts, insertProduct, localDataSource (+8 more)

### Community 66 - "Community 66"
Cohesion: 0.12
Nodes (15): ../datasources/stock_local_datasource.dart, ../../domain/repositories/stock_repository.dart, ../entities/stock_history_entity.dart, adjustStock, getStockHistory, localDataSource, StockRepositoryImpl, adjustStock (+7 more)

### Community 67 - "Community 67"
Cohesion: 0.11
Nodes (15): DateTime, AccountModel, fromJson, AccountEntity, createdAt, email, id, props (+7 more)

### Community 68 - "Community 68"
Cohesion: 0.12
Nodes (17): categories, createState, dispose, _getCategoryIcon, initState, _onSearchFocusChange, PosProductCatalogPane, _PosProductCatalogPaneState (+9 more)

### Community 69 - "Community 69"
Cohesion: 0.19
Nodes (17): WholesalePriceBloc, AddWholesalePriceEvent, LoadWholesalePricesEvent, WholesalePriceEvent, build, createState, dispose, initState (+9 more)

### Community 70 - "Community 70"
Cohesion: 0.12
Nodes (17): backend clean architecture (internal/domain/usecase/repository/delivery/platform), JSON snapshot cloud backup, Go Fiber + PostgreSQL backend, Google Play Billing subscription verification, clean architecture (feature-first layers), dartz Either/Failure error handling, Drift SQLite persistence, GoRouter centralized routing with auth guards (+9 more)

### Community 71 - "Community 71"
Cohesion: 0.12
Nodes (15): ../bloc/pos_bloc.dart, ../bloc/pos_event_state.dart, cart_item.dart, cart_summary.dart, customer_bar.dart, build, CustomerBar, onTap (+7 more)

### Community 72 - "Community 72"
Cohesion: 0.13
Nodes (15): ../datasources/category_local_datasource.dart, ../../domain/repositories/category_repository.dart, CategoryLocalDataSource, CategoryLocalDataSourceImpl, db, deleteCategory, getCategories, insertCategory (+7 more)

### Community 73 - "Community 73"
Cohesion: 0.18
Nodes (15): ../../domain/entities/subscription_status_entity.dart, fromJson, SubscriptionStatusModel, SubscriptionStatusEntity, SubscriptionCubit, message, previous, props (+7 more)

### Community 74 - "Community 74"
Cohesion: 0.12
Nodes (16): ../../domain/usecases/add_expense_usecase.dart, ../../domain/usecases/delete_expense_usecase.dart, ../../domain/usecases/get_expenses_usecase.dart, expense_event.dart, expense_state.dart, addExpenseUseCase, _calculateTotalThisMonth, _calculateTotalToday (+8 more)

### Community 75 - "Community 75"
Cohesion: 0.12
Nodes (16): FocusNode, appendDigit, clearDigits, controller, createState, deleteDigit, dispose, focusNode (+8 more)

### Community 76 - "Community 76"
Cohesion: 0.13
Nodes (14): color, id, name, props, isAdmin, props, userId, id (+6 more)

### Community 77 - "Community 77"
Cohesion: 0.12
Nodes (16): accent, build, color, flex, icon, label, ReportLabeledDot, ReportMetricTile (+8 more)

### Community 78 - "Community 78"
Cohesion: 0.12
Nodes (16): build, createState, icon, isBold, isVoided, label, onTap, onVoid (+8 more)

### Community 79 - "Community 79"
Cohesion: 0.13
Nodes (16): PrintReceiptEvent, build, createState, _generateMonospaceReceipt, initState, isLoading, _loadStoreData, ReceiptPreviewDialog (+8 more)

### Community 80 - "Community 80"
Cohesion: 0.12
Nodes (16): actionVoid, build, createState, db, _handleSave, initState, _isSaving, menuProduct (+8 more)

### Community 81 - "Community 81"
Cohesion: 0.13
Nodes (15): ../bloc/pos_setup_cubit.dart, createState, _getCartPane, PosPage, _PosPageState, _showCheckoutDialog, _showCheckoutSuccessDialog, _showClearCartDialog (+7 more)

### Community 82 - "Community 82"
Cohesion: 0.13
Nodes (14): ../bloc/quick_customer_cubit.dart, ../../../customer/domain/entities/customer_entity.dart, build, customers, DebtSummaryCards, _C, createState, customers (+6 more)

### Community 83 - "Community 83"
Cohesion: 0.14
Nodes (14): ../../domain/usecases/wholesale_price_usecases.dart, call, DeleteWholesalePriceUseCase, GetWholesalePricesUseCase, InsertWholesalePriceUseCase, repository, deleteWholesalePriceUseCase, getWholesalePricesUseCase (+6 more)

### Community 84 - "Community 84"
Cohesion: 0.12
Nodes (14): IconData?, build, color, icon, MetricCard, subtitle, title, value (+6 more)

### Community 86 - "Community 86"
Cohesion: 0.14
Nodes (14): AnimationController, _animController, build, createState, dispose, _endDate, _fadeAnim, initState (+6 more)

### Community 87 - "Community 87"
Cohesion: 0.25
Nodes (15): @DataClassName, ActivityLogs, Categories, Customers, DebtPayments, Expenses, Permissions, Products (+7 more)

### Community 88 - "Community 88"
Cohesion: 0.14
Nodes (13): ../bloc/product_event.dart, ../../domain/entities/product_entity.dart, fromDrift, ProductModel, toCompanion, ProductEntity, build, product (+5 more)

### Community 89 - "Community 89"
Cohesion: 0.13
Nodes (14): class MockGetCachedAccountUseCase extends, class MockRegisterAccountUseCase extends, package:kasirku_sembako/features/account/domain/entities/account_entity.dart, package:kasirku_sembako/features/account/domain/usecases/account_usecases.dart, package:kasirku_sembako/features/account/presentation/bloc/account_bloc.dart, package:kasirku_sembako/features/account/presentation/bloc/account_event.dart, package:kasirku_sembako/features/account/presentation/bloc/account_state.dart, buildBloc (+6 more)

### Community 90 - "Community 90"
Cohesion: 0.14
Nodes (14): ../../../../core/utils/cash_suggestion_helper.dart, _BackupPageBodyState, cashController, cashReceived, CheckoutBottomSheetContent, _CheckoutBottomSheetContentState, createState, customers (+6 more)

### Community 91 - "Community 91"
Cohesion: 0.15
Nodes (13): ../../domain/entities/category_entity.dart, CategoryModel, fromDrift, CategoryEntity, build, category, CategoryEditPage, _CategoryEditPageState (+5 more)

### Community 92 - "Community 92"
Cohesion: 0.13
Nodes (14): int?, AppInput, build, controller, hintText, keyboardType, label, maxLines (+6 more)

### Community 93 - "Community 93"
Cohesion: 0.13
Nodes (14): accountAccessTokenKey, accountCreatedAtKey, accountEmailKey, accountIdKey, apiBaseUrl, AppConstants, appName, currentUserIdKey (+6 more)

### Community 94 - "Community 94"
Cohesion: 0.24
Nodes (14): AccountBloc, account, AccountError, AccountInitial, AccountLoading, AccountSignedIn, AccountSignedOut, AccountState (+6 more)

### Community 95 - "Community 95"
Cohesion: 0.13
Nodes (13): build, controller, DebtSearchField, onChanged, AmountDialog, build, controller, icon (+5 more)

### Community 96 - "Community 96"
Cohesion: 0.15
Nodes (13): ../../../account/presentation/bloc/account_bloc.dart, ../../../account/presentation/bloc/account_state.dart, ../cubit/subscription_cubit.dart, ../cubit/subscription_state.dart, build, createState, initState, onSignIn (+5 more)

### Community 97 - "Community 97"
Cohesion: 0.34
Nodes (12): getEnv(), Duration, Load(), T, setRequiredEnv(), TestLoad_CustomValuesOverrideDefaults(), TestLoad_DefaultsAppliedWhenOptionalVarsUnset(), TestLoad_InvalidBackupMaxSizeMBReturnsError() (+4 more)

### Community 98 - "Community 98"
Cohesion: 0.14
Nodes (13): class MockAccountRemoteDataSource extends, Left, package:kasirku_sembako/core/constants/app_constants.dart, package:kasirku_sembako/core/error/exceptions.dart, package:kasirku_sembako/features/account/data/datasources/account_remote_datasource.dart, package:kasirku_sembako/features/account/data/models/account_model.dart, package:kasirku_sembako/features/account/data/repositories/account_repository_impl.dart, main (+5 more)

### Community 99 - "Community 99"
Cohesion: 0.14
Nodes (12): ../datasources/wholesale_price_local_datasource.dart, ../../domain/entities/wholesale_price_entity.dart, ../../domain/repositories/wholesale_price_repository.dart, fromDrift, WholesalePriceModel, deleteWholesalePrice, getWholesalePricesByProductId, insertWholesalePrice (+4 more)

### Community 100 - "Community 100"
Cohesion: 0.14
Nodes (13): ../../domain/usecases/checkout_usecase.dart, checkoutUseCase, getWholesalePricesUseCase, _onAddToCart, _onCheckout, _onClearCart, _onRemoveFromCart, _onSelectCustomer (+5 more)

### Community 101 - "Community 101"
Cohesion: 0.14
Nodes (13): cashierId, createdAt, customerId, discount, id, items, paymentMethod, props (+5 more)

### Community 102 - "Community 102"
Cohesion: 0.15
Nodes (13): createState, _endDate, initState, _selectDateRange, _startDate, TransactionHistoryPage, _TransactionHistoryPageState, ../../../report/presentation/bloc/report_bloc.dart (+5 more)

### Community 103 - "Community 103"
Cohesion: 0.15
Nodes (13): build, createState, db, dispose, _handleSave, _isSaving, onSuccess, _pinController (+5 more)

### Community 104 - "Community 104"
Cohesion: 0.17
Nodes (11): Animation, ../bloc/report_bloc.dart, ../bloc/report_event_state.dart, ReportLoaded, fadeAnimation, state, report_app_bar.dart, report_states.dart (+3 more)

### Community 105 - "Community 105"
Cohesion: 0.31
Nodes (11): Duration, Issue(), T, TestIssueAndVerify_RoundTripPreservesClaims(), TestVerify_EmptyTokenFails(), TestVerify_ExpiredTokenFails(), TestVerify_MalformedTokenFails(), TestVerify_WrongSecretFails() (+3 more)

### Community 106 - "Community 106"
Cohesion: 0.17
Nodes (12): ../../../category/presentation/bloc/category_bloc.dart, ../../../category/presentation/bloc/category_event_state.dart, build, createState, dispose, _searchController, _selectedCategoryId, _stockFilter (+4 more)

### Community 107 - "Community 107"
Cohesion: 0.15
Nodes (12): class MockCloudBackupRemoteDataSource extends, CloudBackupRepositoryImpl, CloudBackupRepository, package:kasirku_sembako/core/error/failures.dart, package:kasirku_sembako/features/settings/data/datasources/cloud_backup_remote_datasource.dart, package:kasirku_sembako/features/settings/data/repositories/cloud_backup_repository_impl.dart, package:mocktail/mocktail.dart, main (+4 more)

### Community 108 - "Community 108"
Cohesion: 0.15
Nodes (12): class MockDownloadCloudBackupUseCase extends, class MockUploadCloudBackupUseCase extends, package:bloc_test/bloc_test.dart, package:kasirku_sembako/features/settings/domain/usecases/cloud_backup_usecases.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_bloc.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_event.dart, package:kasirku_sembako/features/settings/presentation/bloc/backup_state.dart, buildBloc (+4 more)

### Community 109 - "Community 109"
Cohesion: 0.26
Nodes (12): ../../../customer/domain/usecases/customer_usecases.dart, addCustomer, customer, insertCustomerUseCase, message, props, QuickCustomerCubit, QuickCustomerError (+4 more)

### Community 110 - "Community 110"
Cohesion: 0.15
Nodes (11): debt_event_state.dart, ../../domain/entities/debt_payment_entity.dart, ../../domain/usecases/debt_usecases.dart, DebtPaymentModel, fromDrift, fromEntity, DebtPaymentEntity, getDebtPaymentsUseCase (+3 more)

### Community 111 - "Community 111"
Cohesion: 0.15
Nodes (11): ../../domain/entities/stock_history_entity.dart, fromDrift, StockHistoryModel, createdAt, id, notes, productId, props (+3 more)

### Community 112 - "Community 112"
Cohesion: 0.17
Nodes (12): ../../domain/entities/transaction_item_entity.dart, db, _generateReceiptNumber, getTransactions, logService, saveTransaction, secureStorage, TransactionLocalDataSource (+4 more)

### Community 113 - "Community 113"
Cohesion: 0.17
Nodes (12): InAppPurchase, BillingLocalDataSource, BillingLocalDataSourceImpl, buyPro, completePurchase, _iap, purchaseStream, queryProProduct (+4 more)

### Community 114 - "Community 114"
Cohesion: 0.17
Nodes (12): AuthLocalDataSource, AuthLocalDataSourceImpl, cacheSession, clearSession, db, getCachedSession, hasUsers, login (+4 more)

### Community 115 - "Community 115"
Cohesion: 0.22
Nodes (12): ExpenseActionSuccess, ExpenseError, ExpenseInitial, ExpenseLoaded, ExpenseLoading, expenses, ExpenseState, groupedByDate (+4 more)

### Community 116 - "Community 116"
Cohesion: 0.15
Nodes (12): bgColor, build, color, ExpenseMiniMetric, ExpenseSummarySection, icon, itemCount, label (+4 more)

### Community 117 - "Community 117"
Cohesion: 0.29
Nodes (12): ProductBloc, message, product, ProductError, ProductInitial, ProductLoaded, ProductLoading, ProductOperationSuccess (+4 more)

### Community 118 - "Community 118"
Cohesion: 0.22
Nodes (12): id, message, prices, productId, props, wholesalePrice, WholesalePriceError, WholesalePriceInitial (+4 more)

### Community 119 - "Community 119"
Cohesion: 0.18
Nodes (11): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../bloc/home_bloc.dart, ../bloc/home_event.dart, ../bloc/home_state.dart, createState, HomePage (+3 more)

### Community 120 - "Community 120"
Cohesion: 0.29
Nodes (8): Ctx, User, NewAuthHandler(), toUserDTO(), AuthHandler, authRequest, authResponse, userDTO

### Community 121 - "Community 121"
Cohesion: 0.20
Nodes (11): ../bloc/auth_event.dart, _onLogin, createState, dispose, LoginPage, _LoginPageState, _obscurePin, _onLogin (+3 more)

### Community 122 - "Community 122"
Cohesion: 0.17
Nodes (11): ../../../../core/services/export_service.dart, exportService, getTransactionsUseCase, _onExportExcel, _onExportPdf, _onLoadReports, _onVoidTransaction, voidTransactionUseCase (+3 more)

### Community 123 - "Community 123"
Cohesion: 0.17
Nodes (11): ../../../../core/services/printer_service.dart, _connectedMac, _devices, _onConnectPrinter, _onDisconnectPrinter, _onPrintReceipt, _onPrintTest, _onScanPrinters (+3 more)

### Community 124 - "Community 124"
Cohesion: 0.17
Nodes (11): ../datasources/customer_local_datasource.dart, ../../../debt/data/models/debt_payment_model.dart, ../../domain/repositories/customer_repository.dart, deleteCustomer, getCustomers, getDebtPayments, insertCustomer, localDataSource (+3 more)

### Community 125 - "Community 125"
Cohesion: 0.18
Nodes (11): ../../../debt/presentation/bloc/debt_bloc.dart, ../../../debt/presentation/bloc/debt_event_state.dart, build, createState, CustomerPage, _CustomerPageState, dispose, initState (+3 more)

### Community 126 - "Community 126"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 127 - "Community 127"
Cohesion: 0.33
Nodes (11): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, message, props (+3 more)

### Community 128 - "Community 128"
Cohesion: 0.18
Nodes (11): CustomerLocalDataSource, CustomerLocalDataSourceImpl, db, deleteCustomer, getCustomers, getDebtPayments, insertCustomer, logService (+3 more)

### Community 129 - "Community 129"
Cohesion: 0.17
Nodes (11): barcode, categoryId, id, imagePath, isActive, name, props, purchasePrice (+3 more)

### Community 130 - "Community 130"
Cohesion: 0.33
Nodes (11): BackupBloc, BackupError, BackupInitial, BackupState, CloudBackupDownloading, CloudBackupDownloadSuccess, CloudBackupUploading, CloudBackupUploadSuccess (+3 more)

### Community 131 - "Community 131"
Cohesion: 0.18
Nodes (11): ActivityLogPage, _ActivityLogPageState, build, createState, _db, _getColorForAction, _getIconForAction, initState (+3 more)

### Community 132 - "Community 132"
Cohesion: 0.18
Nodes (11): build, createState, db, dispose, _handleSave, _isSaving, onSuccess, _pinController (+3 more)

### Community 133 - "Community 133"
Cohesion: 0.29
Nodes (6): main(), Context, Pool, User, NewUserRepository(), UserRepository

### Community 134 - "Community 134"
Cohesion: 0.35
Nodes (5): Ctx, NewBackupHandler(), Ctx, UserID(), BackupHandler

### Community 135 - "Community 135"
Cohesion: 0.53
Nodes (10): NewAuthUsecase(), T, newFakeUserRepo(), TestLogin_SuccessWithCorrectPassword(), TestLogin_UnknownEmailReturnsInvalidCredentialsNotNotFound(), TestLogin_WrongPasswordReturnsInvalidCredentials(), TestMe_ReturnsUserByID(), TestMe_UnknownIDReturnsNotFound() (+2 more)

### Community 136 - "Community 136"
Cohesion: 0.24
Nodes (9): ../bloc/category_bloc.dart, ../bloc/category_event_state.dart, CategoryPage, _CategoryPageState, createState, category, _showConfirmDeleteDialog, package:go_router/go_router.dart (+1 more)

### Community 137 - "Community 137"
Cohesion: 0.25
Nodes (11): iOS Launch Screen Assets, GTK3 Dependency, Linux Build System, Flutter Linux Library, Linux Runner Executable, Flutter Framework, kasirku_sembako, Web Entry Point (+3 more)

### Community 138 - "Community 138"
Cohesion: 0.27
Nodes (10): AccountEvent, CheckAccountSessionEvent, email, LoginSubmittedEvent, LogoutEvent, password, props, RegisterSubmittedEvent (+2 more)

### Community 139 - "Community 139"
Cohesion: 0.20
Nodes (10): build, createState, CustomerAddPage, _CustomerAddPageState, _debtController, dispose, _nameController, _notesController (+2 more)

### Community 140 - "Community 140"
Cohesion: 0.20
Nodes (10): db, deleteProduct, getProductByBarcode, getProducts, insertProduct, logService, ProductLocalDataSource, ProductLocalDataSourceImpl (+2 more)

### Community 141 - "Community 141"
Cohesion: 0.25
Nodes (10): AddProductEvent, barcode, DeleteProductEvent, id, product, ProductEvent, props, SearchProductByBarcodeEvent (+2 more)

### Community 142 - "Community 142"
Cohesion: 0.18
Nodes (10): addressController, build, _C, logoPath, nameController, onPickLogo, onRemoveLogo, onSaveProfile (+2 more)

### Community 143 - "Community 143"
Cohesion: 0.18
Nodes (10): discount, id, price, productId, productName, props, purchasePrice, qty (+2 more)

### Community 144 - "Community 144"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 145 - "Community 145"
Cohesion: 0.22
Nodes (7): Handler, RequireAuth(), Handler, RequirePro(), NewRouter(), Dependencies, App

### Community 146 - "Community 146"
Cohesion: 0.40
Nodes (10): Bloc, ExpenseBloc, AddExpenseEvent, DeleteExpenseEvent, ExpenseEvent, LoadExpensesEvent, _deleteExpense, _ExpensePageState (+2 more)

### Community 147 - "Community 147"
Cohesion: 0.22
Nodes (9): ../bloc/product_bloc.dart, ../bloc/product_state.dart, build, createState, initState, ProductPage, _ProductPageState, Route /products/add (+1 more)

### Community 148 - "Community 148"
Cohesion: 0.22
Nodes (9): ../bloc/wholesale_price_bloc.dart, ../bloc/wholesale_price_event_state.dart, DeleteWholesalePriceEvent, build, price, retailPrice, _showConfirmDeleteDialog, unit (+1 more)

### Community 149 - "Community 149"
Cohesion: 0.20
Nodes (9): ../../domain/usecases/subscription_usecases.dart, getCachedSubscriptionStatusUseCase, loadStatus, purchasePro, purchaseProUseCase, refreshSubscriptionStatusUseCase, restorePurchases, restorePurchasesUseCase (+1 more)

### Community 150 - "Community 150"
Cohesion: 0.20
Nodes (9): double get, ../../../../features/product/domain/entities/product_entity.dart, ../../../../features/wholesale_price/domain/entities/wholesale_price_entity.dart, copyWith, product, props, quantity, subtotal (+1 more)

### Community 151 - "Community 151"
Cohesion: 0.33
Nodes (9): AuthFailure, CacheFailure, DatabaseFailure, Failure, message, NetworkFailure, props, ServerFailure (+1 more)

### Community 152 - "Community 152"
Cohesion: 0.29
Nodes (9): AuthEvent, CheckSessionEvent, LoginSubmittedEvent, LogoutEvent, pin, props, RegisterFirstAdminEvent, username (+1 more)

### Community 153 - "Community 153"
Cohesion: 0.22
Nodes (8): app/app.dart, di/injection.dart, features/subscription/domain/repositories/subscription_repository.dart, init, initializeDateFormatting, main, null, package:intl/date_symbol_data_local.dart

### Community 154 - "Community 154"
Cohesion: 0.36
Nodes (6): Ctx, NewSubscriptionHandler(), toStatusResponse(), SubscriptionHandler, subscriptionStatusResponse, verifyRequest

### Community 155 - "Community 155"
Cohesion: 0.33
Nodes (5): Context, Duration, User, AuthUsecase, UserRepository

### Community 156 - "Community 156"
Cohesion: 0.25
Nodes (8): class, db, deleteWholesalePrice, getWholesalePricesByProductId, insertWholesalePrice, WholesalePriceLocalDataSource, WholesalePriceLocalDataSourceImpl, ../models/wholesale_price_model.dart

### Community 157 - "Community 157"
Cohesion: 0.22
Nodes (8): dart:io, ExportService, exportToExcel, exportToPdf, package:excel/excel.dart, package:path_provider/path_provider.dart, package:pdf/widgets.dart, package:share_plus/share_plus.dart

### Community 158 - "Community 158"
Cohesion: 0.22
Nodes (8): ../datasources/transaction_local_datasource.dart, ../../domain/entities/cart_item_entity.dart, ../../domain/entities/transaction_entity.dart, ../../domain/repositories/transaction_repository.dart, checkout, getTransactions, localDataSource, voidTransaction

### Community 159 - "Community 159"
Cohesion: 0.22
Nodes (8): double?, AppButton, build, isLoading, isOutline, onPressed, text, width

### Community 160 - "Community 160"
Cohesion: 0.22
Nodes (8): ../../features/transaction/domain/entities/transaction_entity.dart, connect, disconnect, getPairedDevices, PrinterService, printReceipt, printTest, package:esc_pos_utils_plus/esc_pos_utils_plus.dart

### Community 161 - "Community 161"
Cohesion: 0.22
Nodes (8): amount, cashierId, createdAt, customerId, id, notes, paymentMethod, props

### Community 162 - "Community 162"
Cohesion: 0.22
Nodes (8): CloudBackupSummary, createdAt, deleteBackup, downloadLatestBackup, id, listBackups, sizeBytes, uploadBackup

### Community 163 - "Community 163"
Cohesion: 0.31
Nodes (8): BackupEvent, DownloadCloudBackupRequested, payload, props, UploadCloudBackupRequested, build, Map, main

### Community 164 - "Community 164"
Cohesion: 0.36
Nodes (9): AppIcon.appiconset, app_icon_1024.png, app_icon_128.png, app_icon_16.png, app_icon_256.png, app_icon_32.png, app_icon_512.png, app_icon_64.png (+1 more)

### Community 165 - "Community 165"
Cohesion: 0.57
Nodes (7): T, newTestApp(), TestRequireAuth_ExpiredTokenReturns401(), TestRequireAuth_InvalidTokenReturns401(), TestRequireAuth_MalformedHeaderReturns401(), TestRequireAuth_MissingHeaderReturns401(), TestRequireAuth_ValidTokenPassesThroughAndSetsUserID()

### Community 166 - "Community 166"
Cohesion: 0.29
Nodes (7): category_list_item.dart, categories, CategoryListContent, _CategoryListContentState, createState, dispose, _searchController

### Community 167 - "Community 167"
Cohesion: 0.25
Nodes (7): ../datasources/expense_local_datasource.dart, ../../domain/repositories/expense_repository.dart, addExpense, deleteExpense, getExpenses, localDataSource, _mapToEntity

### Community 168 - "Community 168"
Cohesion: 0.25
Nodes (7): ../entities/account_entity.dart, AccountRepositoryImpl, AccountRepository, getCachedAccount, login, logout, register

### Community 169 - "Community 169"
Cohesion: 0.25
Nodes (7): ../entities/category_entity.dart, CategoryRepositoryImpl, CategoryRepository, deleteCategory, getCategories, insertCategory, updateCategory

### Community 170 - "Community 170"
Cohesion: 0.25
Nodes (7): UserModel, id, isActive, props, role, UserEntity, username

### Community 171 - "Community 171"
Cohesion: 0.29
Nodes (7): build, CategoryAddPage, _CategoryAddPageState, createState, dispose, _nameController, _showStyledSnackBar

### Community 172 - "Community 172"
Cohesion: 0.25
Nodes (7): copyWith, debtAmount, id, name, notes, phone, props

### Community 173 - "Community 173"
Cohesion: 0.25
Nodes (7): amount, category, date, ExpenseEntity, id, notes, receiptPath

### Community 174 - "Community 174"
Cohesion: 0.25
Nodes (7): build, _C, connectedMacAddress, devices, onConnect, PrinterDevicesListSection, package:print_bluetooth_thermal/print_bluetooth_thermal.dart

### Community 175 - "Community 175"
Cohesion: 0.25
Nodes (7): build, CartItem, EmptyCart, item, onDecrement, onIncrement, onQtyTap

### Community 176 - "Community 176"
Cohesion: 0.25
Nodes (7): actionVoid, id, menuProduct, menuReport, menuStock, props, userId

### Community 177 - "Community 177"
Cohesion: 0.29
Nodes (6): ../../domain/entities/expense_entity.dart, endDate, expense, id, props, startDate

### Community 178 - "Community 178"
Cohesion: 0.29
Nodes (6): ../../domain/usecases/get_home_metrics_usecase.dart, home_event.dart, home_state.dart, getHomeMetricsUseCase, _onLoadHomeMetrics, package:flutter_bloc/flutter_bloc.dart

### Community 179 - "Community 179"
Cohesion: 0.33
Nodes (6): Android Launcher Icon, ic_launcher (hdpi), ic_launcher (mdpi), ic_launcher (xhdpi), ic_launcher (xxhdpi), ic_launcher (xxxhdpi)

### Community 180 - "Community 180"
Cohesion: 0.67
Nodes (3): Context, User, fakeUserRepo

### Community 181 - "Community 181"
Cohesion: 0.33
Nodes (5): dart:convert, hashPin, isValidPin, PinUtils, package:crypto/crypto.dart

### Community 182 - "Community 182"
Cohesion: 0.53
Nodes (6): LaunchImage.imageset, Contents.json, LaunchImage@2x.png, LaunchImage@3x.png, LaunchImage.png (1x), README.md

### Community 183 - "Community 183"
Cohesion: 0.33
Nodes (5): expenses, lowStock, omset, props, trxCount

### Community 184 - "Community 184"
Cohesion: 0.40
Nodes (4): add_expense_sheet.dart, expense_app_bar.dart, expense_list_section.dart, expense_summary_section.dart

### Community 185 - "Community 185"
Cohesion: 0.50
Nodes (3): BackupRepository, SubscriptionRepository, UserRepository

### Community 186 - "Community 186"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

### Community 187 - "Community 187"
Cohesion: 0.67
Nodes (4): Icon-192.png, Icon-512.png, Icon-maskable-192.png, Icon-maskable-512.png

## Knowledge Gaps
- **1512 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `github.com/dimassfeb-09/kasku_sembako/backend`, `authRequest`, `verifyRequest` (+1507 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `App` connect `Community 145` to `Community 32`, `Community 165`, `Community 69`, `Stock Management Bloc`, `POS Cart & Checkout`, `Community 41`, `App Router & Navigation`, `Community 45`, `Expense Management UI`, `Community 146`, `Report Bloc (Excel/PDF)`, `Community 117`, `Community 22`, `Community 56`, `Community 59`, `Community 94`, `Community 127`?**
  _High betweenness centrality (0.149) - this node is a cross-community bridge._
- **Why does `NewRouter()` connect `Community 145` to `Go Backend Subscriptions`, `Community 133`, `Community 134`, `Community 120`, `Community 154`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Why does `AppDatabase` connect `Community 24` to `Database Schema`, `Clean Architecture Data Layer`, `Community 128`, `Community 131`, `Community 132`, `Community 140`, `Community 20`, `Community 21`, `Community 25`, `Community 156`, `Community 34`, `Community 48`, `Community 51`, `Community 61`, `Community 72`, `Community 80`, `Community 103`, `Community 112`, `Community 114`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `github.com/dimassfeb-09/kasku_sembako/backend` to the rest of the system?**
  _1512 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Database Schema` be split into smaller, more focused modules?**
  _Cohesion score 0.014492753623188406 - nodes in this community are weakly interconnected._
- **Should `Clean Architecture Data Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.030303030303030304 - nodes in this community are weakly interconnected._
- **Should `Platform Native Plugins` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._