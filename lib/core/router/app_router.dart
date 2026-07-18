import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/app_intro_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/business_setup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/business_profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/product/presentation/pages/product_add_page.dart';
import '../../features/product/presentation/pages/product_edit_page.dart';
import '../../features/product/domain/entities/product_entity.dart';
import '../../features/customer/presentation/pages/customer_page.dart';
import '../../features/customer/presentation/pages/customer_add_page.dart';
import '../../features/customer/presentation/pages/customer_edit_page.dart';
import '../../features/customer/domain/entities/customer_entity.dart';
import '../../features/category/presentation/pages/category_page.dart';
import '../../features/category/presentation/pages/category_add_page.dart';
import '../../features/category/presentation/pages/category_edit_page.dart';
import '../../features/category/domain/entities/category_entity.dart';
import '../../features/wholesale_price/presentation/pages/wholesale_price_page.dart';
import '../../features/wholesale_price/presentation/pages/wholesale_management_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/stock/presentation/pages/stock_adjustment_page.dart';
import '../../features/stock/presentation/pages/stock_history_page.dart';
import '../../features/transaction/presentation/pages/pos_page.dart';
import '../../features/report/presentation/pages/report_page.dart';
import '../../features/expense/presentation/pages/expense_page.dart';
import '../../features/settings/presentation/pages/printer_settings_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/settings/presentation/pages/qris_setting_page.dart';
import '../../features/settings/presentation/pages/activity_log_page.dart';
import '../../features/settings/presentation/pages/cashier_management_page.dart';
import '../../features/transaction/presentation/pages/transaction_history_page.dart';
import '../../features/debt/presentation/pages/debt_management_page.dart';
import '../../features/account/presentation/pages/account_login_page.dart';
import '../../features/account/presentation/pages/account_register_page.dart';
import '../../features/account/presentation/pages/account_home_page.dart';
import '../../features/subscription/presentation/pages/subscription_upgrade_page.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../../features/subscription/presentation/cubit/subscription_state.dart';
import '../../features/data/presentation/pages/data_hub_page.dart';
import '../../features/report/presentation/pages/report_hub_page.dart';
import '../../features/more/presentation/pages/more_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/password_reset_bloc.dart';
import '../../features/transaction/presentation/bloc/pos_setup_cubit.dart';
import '../../di/injection.dart' as di;
import 'app_shell.dart';

class AppRouter {
  /// Pro-only routes that a non-entitled user is hard-redirected away from
  /// (backstop for deep links / direct navigation). Client-side gate only —
  /// these are local features with no server enforcement.
  static const List<String> proRedirectRoutes = [
    '/logs',
    '/wholesale-management',
    '/products/wholesale',
  ];

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';
      final isIntro = state.matchedLocation == '/intro';
      final isRegister = state.matchedLocation == '/register';
      final isForgotPassword = state.matchedLocation == '/forgot-password';
      final isVerifyOtp = state.matchedLocation == '/verify-otp';
      final isResetPassword = state.matchedLocation == '/reset-password';

      // Steps 2 and 3 are only reachable by carrying the previous step's result
      // (email, then reset token) in `extra`. A deep link or restart arrives
      // without it, so send the user back to the start of the flow.
      final hasHandoff =
          state.extra is String && (state.extra as String).isNotEmpty;
      if ((isVerifyOtp || isResetPassword) && !hasHandoff) {
        return '/forgot-password';
      }

      if (authState is Unauthenticated || authState is AuthInitial) {
        if (!isSplash &&
            !isIntro &&
            !isLoggingIn &&
            !isRegister &&
            !isForgotPassword &&
            !isVerifyOtp &&
            !isResetPassword) {
          return '/login';
        }
      }

      if (authState is Authenticated) {
        if (isSplash || isIntro) {
          return '/home';
        }
        if (isRegister) {
          return '/business-setup';
        }
        if (isLoggingIn) {
          return '/home';
        }

        final subState = context.read<SubscriptionCubit>().state;
        final isPro =
            subState is SubscriptionStatusLoaded && subState.status.isEntitled;
        if (!isPro &&
            proRedirectRoutes.any(
              (route) => state.matchedLocation.startsWith(route),
            )) {
          return '/subscription/upgrade';
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
        path: '/intro',
        name: 'intro',
        builder: (context, state) => const AppIntroPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/business-setup',
        name: 'business-setup',
        builder: (context, state) => const BusinessSetupPage(),
      ),
      // One bloc for the whole forgot -> verify OTP -> reset flow: the three
      // pages are steps in a single transaction, so a per-route provider would
      // hand each step a fresh Initial state.
      ShellRoute(
        builder: (context, state, child) => BlocProvider<PasswordResetBloc>(
          create: (_) => di.sl<PasswordResetBloc>(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
          GoRoute(
            path: '/verify-otp',
            name: 'verify-otp',
            builder: (context, state) => _safeRoute<String>(
              state.extra,
              (email) => VerifyOtpPage(email: email),
            ),
          ),
          GoRoute(
            path: '/reset-password',
            name: 'reset-password',
            builder: (context, state) => _safeRoute<String>(
              state.extra,
              (resetToken) => ResetPasswordPage(resetToken: resetToken),
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ─── Tab 0: Beranda ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // ─── Tab 1: POS ──────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pos',
                name: 'pos',
                builder: (context, state) => BlocProvider<PosSetupCubit>(
                  create: (_) => di.sl<PosSetupCubit>()..load(),
                  child: PosPage(),
                ),
              ),
            ],
          ),
          // ─── Tab 2: Data ─────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/data',
                name: 'data',
                builder: (context, state) => const DataHubPage(),
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
                path: '/debts',
                name: 'debts',
                builder: (context, state) => const DebtManagementPage(),
              ),
            ],
          ),
          // ─── Tab 3: Laporan ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/laporan',
                name: 'laporan',
                builder: (context, state) => const ReportHubPage(),
              ),
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const TransactionHistoryPage(),
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
            ],
          ),
          // ─── Tab 4: Lainnya ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                builder: (context, state) => const MorePage(),
              ),
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const PrinterSettingsPage(),
              ),
              GoRoute(
                path: '/cashiers',
                name: 'cashiers',
                builder: (context, state) => const CashierManagementPage(),
              ),
              GoRoute(
                path: '/business-profile',
                name: 'business-profile',
                builder: (context, state) => const BusinessProfilePage(),
              ),
              GoRoute(
                path: '/qris-setting',
                name: 'qris-setting',
                builder: (context, state) => const QrisSettingPage(),
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
                path: '/account',
                name: 'account',
                builder: (context, state) => const AccountHomePage(),
              ),
              GoRoute(
                path: '/account/login',
                name: 'account_login',
                builder: (context, state) => const AccountLoginPage(),
              ),
              GoRoute(
                path: '/account/register',
                name: 'account_register',
                builder: (context, state) => const AccountRegisterPage(),
              ),
              GoRoute(
                path: '/subscription/upgrade',
                name: 'subscription_upgrade',
                builder: (context, state) => BlocProvider<SubscriptionCubit>(
                  create: (_) => di.sl<SubscriptionCubit>(),
                  child: const SubscriptionUpgradePage(),
                ),
              ),
            ],
          ),
        ],
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
