import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../di/injection.dart' as di;
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/product/presentation/bloc/product_bloc.dart';
import '../features/product/presentation/bloc/category_bloc.dart';
import '../features/product/presentation/bloc/wholesale_price_bloc.dart';
import '../features/customer/presentation/bloc/customer_bloc.dart';
import '../features/customer/presentation/bloc/debt_bloc.dart';
import '../features/stock/presentation/bloc/stock_bloc.dart';
import '../features/transaction/presentation/bloc/pos_bloc.dart';
import '../features/transaction/presentation/bloc/report_bloc.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/settings/presentation/bloc/printer_bloc.dart';
import '../features/auth/presentation/bloc/permission_cubit.dart';
import '../features/expense/presentation/bloc/expense_bloc.dart';

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
        BlocProvider<PosBloc>(create: (_) => di.sl<PosBloc>()),
        BlocProvider<PrinterBloc>(create: (_) => di.sl<PrinterBloc>()),
        BlocProvider<ReportBloc>(create: (_) => di.sl<ReportBloc>()),
        BlocProvider<HomeBloc>(create: (_) => di.sl<HomeBloc>()),
        BlocProvider<PermissionCubit>(create: (_) => di.sl<PermissionCubit>()),
        BlocProvider<ExpenseBloc>(create: (_) => di.sl<ExpenseBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<PermissionCubit>().checkPermissions(
              role: state.user.role,
              userId: state.user.id,
            );
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
