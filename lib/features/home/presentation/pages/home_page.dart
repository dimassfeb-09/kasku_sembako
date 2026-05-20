import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/metric_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<HomeBloc>().add(
          LoadHomeMetricsEvent(
            userId: authState.user.id,
            isAdmin: authState.user.role == 'admin',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        } else if (state is Authenticated) {
          context.read<HomeBloc>().add(
            LoadHomeMetricsEvent(
              userId: state.user.id,
              isAdmin: state.user.role == 'admin',
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kasirku Sembako'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
              tooltip: 'Keluar',
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            final isAdmin = user?.role == 'admin';

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(
                  LoadHomeMetricsEvent(userId: user?.id, isAdmin: isAdmin),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.indigo.withOpacity(0.1),
                            child: Icon(
                              isAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: Colors.indigo,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.username ?? "Pengguna"} 👋',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAdmin
                                      ? 'Masuk sebagai Super Admin Store'
                                      : 'Masuk sebagai Staf Kasir Ritel',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dashboard Panel (Khusus Admin)
                    if (isAdmin) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Hari Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state is HomeMetricsLoading ||
                                    state is HomeInitial) {
                                  return const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (state is HomeMetricsError) {
                                  return SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final metrics =
                                    (state as HomeMetricsLoaded).metrics;

                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: screenWidth > 600 ? 4 : 2,
                                  childAspectRatio: screenWidth > 600
                                      ? 1.6
                                      : 1.3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  children: [
                                    MetricCard(
                                      title: 'Omset Penjualan',
                                      value: metrics.omset.toRupiah(),
                                      icon: Icons.trending_up,
                                      color: Colors.teal,
                                    ),
                                    MetricCard(
                                      title: 'Jumlah Transaksi',
                                      value: '${metrics.trxCount} Nota',
                                      icon: Icons.receipt_long,
                                      color: Colors.indigo,
                                    ),
                                    MetricCard(
                                      title: 'Pengeluaran Toko',
                                      value: metrics.expenses.toRupiah(),
                                      icon: Icons.trending_down,
                                      color: Colors.red,
                                    ),
                                    MetricCard(
                                      title: 'Stok Menipis (≤5)',
                                      value: '${metrics.lowStock} Produk',
                                      icon: Icons.warning_amber_rounded,
                                      color: metrics.lowStock > 0
                                          ? Colors.amber
                                          : Colors.grey,
                                      subtitle: metrics.lowStock > 0
                                          ? 'Butuh restock'
                                          : 'Semua aman',
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Ringkasan Transaksi Saya (Khusus Kasir)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Saya Hari Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state is HomeMetricsLoading ||
                                    state is HomeInitial) {
                                  return const SizedBox(
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (state is HomeMetricsError) {
                                  return SizedBox(
                                    height: 90,
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final metrics =
                                    (state as HomeMetricsLoaded).metrics;

                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  children: [
                                    MetricCard(
                                      title: 'Omset Saya',
                                      value: metrics.omset.toRupiah(),
                                      icon: Icons.trending_up,
                                      color: Colors.teal,
                                    ),
                                    MetricCard(
                                      title: 'Transaksi Saya',
                                      value: '${metrics.trxCount} Nota',
                                      icon: Icons.receipt_long,
                                      color: Colors.indigo,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quick Cashier Action Panel (Khusus Kasir)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.indigo.withOpacity(0.2),
                            ),
                          ),
                          color: Colors.indigo.withOpacity(0.02),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.point_of_sale,
                                      color: Colors.indigo,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Aktivitas Kasir Aktif',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Siap melayani pelanggan! Pastikan koneksi printer struk Anda sudah terhubung sebelum memulai shift.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/pos'),
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Buka POS / Kasir Baru',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Menu Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Pilihan Menu',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 768
                          ? 6
                          : screenWidth > 480
                          ? 4
                          : 3,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                      children: [
                        const HomeMenuCard(
                          title: 'POS Kasir',
                          icon: Icons.point_of_sale,
                          route: '/pos',
                        ),
                        const HomeMenuCard(
                          title: 'Kategori',
                          icon: Icons.category,
                          route: '/categories',
                        ),
                        const HomeMenuCard(
                          title: 'Produk',
                          icon: Icons.inventory_2,
                          route: '/products',
                        ),
                        const HomeMenuCard(
                          title: 'Stok',
                          icon: Icons.warehouse,
                          route: '/stock',
                        ),
                        const HomeMenuCard(
                          title: 'Pelanggan',
                          icon: Icons.people,
                          route: '/customers',
                        ),
                        const HomeMenuCard(
                          title: 'Hutang Piutang',
                          icon: Icons.account_balance_wallet_outlined,
                          route: '/debts',
                        ),
                        const HomeMenuCard(
                          title: 'Riwayat',
                          icon: Icons.receipt_long,
                          route: '/history',
                        ),
                        if (isAdmin) ...[
                          const HomeMenuCard(
                            title: 'Laporan',
                            icon: Icons.bar_chart,
                            route: '/reports',
                          ),
                          const HomeMenuCard(
                            title: 'Pengeluaran',
                            icon: Icons.money_off,
                            route: '/expenses',
                          ),
                          const HomeMenuCard(
                            title: 'Harga Grosir',
                            icon: Icons.discount_outlined,
                            route: '/wholesale-management',
                          ),
                          const HomeMenuCard(
                            title: 'Cadangan Data',
                            icon: Icons.backup,
                            route: '/backup',
                          ),
                          const HomeMenuCard(
                            title: 'Log Aktivitas',
                            icon: Icons.history_edu,
                            route: '/logs',
                          ),
                          const HomeMenuCard(
                            title: 'Pengguna',
                            icon: Icons.manage_accounts,
                            route: '/users',
                          ),
                          const HomeMenuCard(
                            title: 'Pengaturan',
                            icon: Icons.settings,
                            route: '/settings',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
