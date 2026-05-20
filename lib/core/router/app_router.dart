import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_first_admin_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/product/presentation/pages/product_add_page.dart';
import '../../features/product/presentation/pages/product_edit_page.dart';
import '../../features/product/domain/entities/product_entity.dart';
import '../../features/customer/presentation/pages/customer_page.dart';
import '../../features/customer/presentation/pages/customer_add_page.dart';
import '../../features/customer/presentation/pages/customer_edit_page.dart';
import '../../features/customer/domain/entities/customer_entity.dart';
import '../../features/product/presentation/pages/category_page.dart';
import '../../features/product/presentation/pages/category_add_page.dart';
import '../../features/product/presentation/pages/category_edit_page.dart';
import '../../features/product/domain/entities/category_entity.dart';
import '../../features/product/presentation/pages/wholesale_price_page.dart';
import '../../features/product/presentation/pages/wholesale_management_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/stock/presentation/pages/stock_adjustment_page.dart';
import '../../features/stock/presentation/pages/stock_history_page.dart';
import '../../features/transaction/presentation/pages/pos_page.dart';
import '../../features/transaction/presentation/pages/report_page.dart';
import '../../features/expense/presentation/pages/expense_page.dart';
import '../../features/settings/presentation/pages/printer_settings_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/settings/presentation/pages/activity_log_page.dart';
import '../../features/settings/presentation/pages/user_management_page.dart';
import '../../features/transaction/presentation/pages/transaction_history_page.dart';
import '../../features/customer/presentation/pages/debt_management_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/transaction/presentation/bloc/pos_setup_cubit.dart';
import '../../di/injection.dart' as di;

class AppRouter {
  static const List<String> availableRoutes = [
    '/products',
    '/customers',
    '/categories',
    '/stock',
    '/pos',
    '/settings',
    '/reports',
    '/expenses',
    '/backup',
    '/logs',
    '/users',
    '/history',
    '/wholesale-management',
    '/debts',
  ];

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';
      final isSetup = state.matchedLocation == '/setup';

      if (authState is SetupRequired) {
        if (!isSetup) {
          return '/setup';
        }
        return null;
      }

      if (isSetup && authState is! SetupRequired) {
        return '/';
      }

      if (authState is Unauthenticated) {
        if (!isLoggingIn && !isSplash) {
          return '/login';
        }
      }

      if (authState is Authenticated) {
        if (isLoggingIn || isSplash) {
          return '/home';
        }

        final user = authState.user;
        if (user.role != 'admin') {
          final restrictedRoutes = ['/users', '/reports', '/backup', '/logs'];
          if (restrictedRoutes.any(
            (route) => state.matchedLocation.startsWith(route),
          )) {
            return '/home';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const RegisterFirstAdminPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductPage(),
      ),
      GoRoute(
        path: '/products/add',
        name: 'add_product',
        builder: (context, state) => const ProductAddPage(),
      ),
      GoRoute(
        path: '/products/edit',
        name: 'edit_product',
        builder: (context, state) => _safeRoute<ProductEntity>(
          state.extra,
          (product) => ProductEditPage(product: product),
        ),
      ),
      GoRoute(
        path: '/wholesale-management',
        name: 'wholesale_management',
        builder: (context, state) => const WholesaleManagementPage(),
      ),
      GoRoute(
        path: '/products/wholesale',
        name: 'wholesale_price',
        builder: (context, state) => _safeRoute<ProductEntity>(
          state.extra,
          (product) => WholesalePricePage(product: product),
        ),
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomerPage(),
      ),
      GoRoute(
        path: '/customers/add',
        name: 'add_customer',
        builder: (context, state) => const CustomerAddPage(),
      ),
      GoRoute(
        path: '/customers/edit',
        name: 'edit_customer',
        builder: (context, state) => _safeRoute<CustomerEntity>(
          state.extra,
          (customer) => CustomerEditPage(customer: customer),
        ),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        path: '/categories/add',
        name: 'add_category',
        builder: (context, state) => const CategoryAddPage(),
      ),
      GoRoute(
        path: '/categories/edit',
        name: 'edit_category',
        builder: (context, state) => _safeRoute<CategoryEntity>(
          state.extra,
          (category) => CategoryEditPage(category: category),
        ),
      ),
      GoRoute(
        path: '/stock',
        name: 'stock',
        builder: (context, state) => const StockPage(),
      ),
      GoRoute(
        path: '/stock/adjust',
        name: 'adjust_stock',
        builder: (context, state) => _safeRoute<ProductEntity>(
          state.extra,
          (product) => StockAdjustmentPage(product: product),
        ),
      ),
      GoRoute(
        path: '/stock/history',
        name: 'stock_history',
        builder: (context, state) => _safeRoute<ProductEntity>(
          state.extra,
          (product) => StockHistoryPage(product: product),
        ),
      ),
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => BlocProvider<PosSetupCubit>(
          create: (_) => di.sl<PosSetupCubit>()..load(),
          child: const PosPage(),
        ),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportPage(),
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensePage(),
      ),
      GoRoute(
        path: '/backup',
        name: 'backup',
        builder: (context, state) => const BackupPage(),
      ),
      GoRoute(
        path: '/logs',
        name: 'logs',
        builder: (context, state) => const ActivityLogPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const PrinterSettingsPage(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UserManagementPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      GoRoute(
        path: '/debts',
        name: 'debts',
        builder: (context, state) => const DebtManagementPage(),
      ),
    ],
  );

  static Widget _safeRoute<T>(Object? extra, Widget Function(T) builder) {
    if (extra is T) {
      return builder(extra);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Data tidak valid atau hilang.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => router.go('/home'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
