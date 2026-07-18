import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/database/app_database.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../di/injection.dart' as di;
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/product/presentation/bloc/product_bloc.dart';
import '../features/category/presentation/bloc/category_bloc.dart';
import '../features/wholesale_price/presentation/bloc/wholesale_price_bloc.dart';
import '../features/customer/presentation/bloc/customer_bloc.dart';
import '../features/debt/presentation/bloc/debt_bloc.dart';
import '../features/stock/presentation/bloc/stock_bloc.dart';
import '../features/transaction/presentation/bloc/pos_bloc.dart';
import '../features/report/presentation/bloc/report_bloc.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/settings/presentation/bloc/printer_bloc.dart';
import '../features/expense/presentation/bloc/expense_bloc.dart';
import '../features/account/presentation/bloc/account_bloc.dart';
import '../features/account/presentation/bloc/account_event.dart';
import '../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../features/subscription/presentation/cubit/subscription_state.dart';
import '../core/services/backup_scheduler_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckSessionEvent()),
        ),
        BlocProvider<ProductBloc>(create: (_) => di.sl<ProductBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => di.sl<CustomerBloc>()),
        BlocProvider<DebtBloc>(create: (_) => di.sl<DebtBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => di.sl<CategoryBloc>()),
        BlocProvider<WholesalePriceBloc>(
          create: (_) => di.sl<WholesalePriceBloc>(),
        ),
        BlocProvider<StockBloc>(create: (_) => di.sl<StockBloc>()),
        BlocProvider<SubscriptionCubit>(
          create: (_) => di.sl<SubscriptionCubit>(),
        ),
        BlocProvider<PosBloc>(
          create: (ctx) => PosBloc(
            checkoutUseCase: di.sl(),
            getWholesalePricesUseCase: di.sl(),
            database: di.sl<AppDatabase>(),
            isWholesaleAllowed: () {
              final subState = ctx.read<SubscriptionCubit>().state;
              return subState is SubscriptionStatusLoaded &&
                  subState.status.isEntitled;
            },
          ),
        ),
        BlocProvider<PrinterBloc>(create: (_) => di.sl<PrinterBloc>()),
        BlocProvider<ReportBloc>(create: (_) => di.sl<ReportBloc>()),
        BlocProvider<HomeBloc>(create: (_) => di.sl<HomeBloc>()),
        BlocProvider<ExpenseBloc>(create: (_) => di.sl<ExpenseBloc>()),
        BlocProvider<AccountBloc>(
          create: (_) => di.sl<AccountBloc>()..add(CheckAccountSessionEvent()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<SubscriptionCubit>().loadStatus();
            di.sl<BackupSchedulerService>().init();
          }
        },
        child: MaterialApp.router(
          title: 'Kasirku Sembako',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
