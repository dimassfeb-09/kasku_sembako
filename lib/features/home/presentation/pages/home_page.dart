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
        backgroundColor: const Color(0xFFF8FAFC), // Slate 50 background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          shape: const Border(
            bottom: BorderSide(
              color: Color(0xFFF1F5F9), // Slate 100 border
              width: 1,
            ),
          ),
          title: const Text(
            'Kasirku Sembako',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF0F172A), // Slate 900
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444), // Danger Red
                size: 22,
              ),
              onPressed: () {
                // Show confirmation dialog before logout (DESIGN.md Section 6.2)
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: Colors.white,
                      title: const Text(
                        'Konfirmasi Keluar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar dari aplikasi Kasirku Sembako?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AuthBloc>().add(LogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Keluar',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;
            final isAdmin = user?.role == 'admin';

            return RefreshIndicator(
              color: const Color(0xFF0D9488), // Teal primary
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
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9), // Slate 100
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x03000000), // Very soft shadow
                            offset: Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF99F6E4), // Teal 200
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(
                                  0xFFF0FDFA,
                                ), // Teal 50
                                child: Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  color: const Color(0xFF0D9488), // Teal 600
                                  size: 24,
                                ),
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
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A), // Slate 900
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? const Color(0xFFF0FDFA) // Teal 50
                                          : const Color(0xFFEFF6FF), // Blue 50
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isAdmin
                                          ? 'SUPER ADMIN STORE'
                                          : 'STAF KASIR RITEL',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: isAdmin
                                            ? const Color(
                                                0xFF0D9488,
                                              ) // Teal 600
                                            : const Color(
                                                0xFF3B82F6,
                                              ), // Blue 600
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Dashboard Panel (Khusus Admin)
                    if (isAdmin) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Toko Hari Ini',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF0F172A), // Slate 900
                              ),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state is HomeMetricsLoading ||
                                    state is HomeInitial) {
                                  return const SizedBox(
                                    height: 140,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                  );
                                }

                                if (state is HomeMetricsError) {
                                  return Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w600,
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
                                      : 1.32,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  children: [
                                    MetricCard(
                                      title: 'Omset Penjualan',
                                      value: metrics.omset.toRupiah(),
                                      icon: Icons.trending_up_rounded,
                                      color: const Color(0xFF0D9488), // Teal
                                    ),
                                    MetricCard(
                                      title: 'Jumlah Transaksi',
                                      value: '${metrics.trxCount} Nota',
                                      icon: Icons.receipt_long_rounded,
                                      color: const Color(0xFF3B82F6), // Blue
                                    ),
                                    MetricCard(
                                      title: 'Pengeluaran Toko',
                                      value: metrics.expenses.toRupiah(),
                                      icon: Icons.trending_down_rounded,
                                      color: const Color(0xFFEF4444), // Red
                                    ),
                                    MetricCard(
                                      title: 'Stok Menipis (≤5)',
                                      value: '${metrics.lowStock} Produk',
                                      icon: Icons.warning_amber_rounded,
                                      color: metrics.lowStock > 0
                                          ? const Color(0xFFF59E0B) // Amber
                                          : const Color(
                                              0xFF94A3B8,
                                            ), // Slate 400
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
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Saya Hari Ini',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state is HomeMetricsLoading ||
                                    state is HomeInitial) {
                                  return const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                  );
                                }

                                if (state is HomeMetricsError) {
                                  return Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.w600,
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
                                  childAspectRatio: 1.35,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  children: [
                                    MetricCard(
                                      title: 'Omset Saya',
                                      value: metrics.omset.toRupiah(),
                                      icon: Icons.trending_up_rounded,
                                      color: const Color(0xFF0D9488),
                                    ),
                                    MetricCard(
                                      title: 'Transaksi Saya',
                                      value: '${metrics.trxCount} Nota',
                                      icon: Icons.receipt_long_rounded,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Quick Cashier Action Panel (Khusus Kasir)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF0FDFA,
                            ), // Teal 50 background
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF99F6E4), // Teal 200 border
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x02000000),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.point_of_sale_rounded,
                                        color: Color(0xFF0D9488), // Teal 600
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Aktivitas Kasir Aktif',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Siap melayani pelanggan! Pastikan printer struk Anda sudah terhubung sebelum memulai transaksi.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Color(0xFF64748B), // Slate 500
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/pos'),
                                  icon: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Buka POS / Kasir Baru',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF0D9488,
                                    ), // Teal 600
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Menu Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Pilihan Menu',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF0F172A), // Slate 900
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9), // Slate 100
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${isAdmin ? 15 : 7} Fitur',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B), // Slate 500
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 768
                          ? 6
                          : screenWidth > 480
                          ? 4
                          : 3,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.98,
                      children: [
                        const HomeMenuCard(
                          title: 'POS Kasir',
                          icon: Icons.point_of_sale_rounded,
                          route: '/pos',
                        ),
                        const HomeMenuCard(
                          title: 'Kategori',
                          icon: Icons.category_rounded,
                          route: '/categories',
                        ),
                        const HomeMenuCard(
                          title: 'Produk',
                          icon: Icons.inventory_2_rounded,
                          route: '/products',
                        ),
                        const HomeMenuCard(
                          title: 'Stok',
                          icon: Icons.warehouse_rounded,
                          route: '/stock',
                        ),
                        const HomeMenuCard(
                          title: 'Pelanggan',
                          icon: Icons.people_rounded,
                          route: '/customers',
                        ),
                        const HomeMenuCard(
                          title: 'Hutang Piutang',
                          icon: Icons.account_balance_wallet_rounded,
                          route: '/debts',
                        ),
                        const HomeMenuCard(
                          title: 'Riwayat',
                          icon: Icons.receipt_long_rounded,
                          route: '/history',
                        ),
                        if (isAdmin) ...[
                          const HomeMenuCard(
                            title: 'Laporan',
                            icon: Icons.bar_chart_rounded,
                            route: '/reports',
                          ),
                          const HomeMenuCard(
                            title: 'Pengeluaran',
                            icon: Icons.money_off_rounded,
                            route: '/expenses',
                          ),
                          const HomeMenuCard(
                            title: 'Harga Grosir',
                            icon: Icons.discount_rounded,
                            route: '/wholesale-management',
                          ),
                          const HomeMenuCard(
                            title: 'Cadangan Data',
                            icon: Icons.backup_rounded,
                            route: '/backup',
                          ),
                          const HomeMenuCard(
                            title: 'Log Aktivitas',
                            icon: Icons.history_edu_rounded,
                            route: '/logs',
                          ),
                          const HomeMenuCard(
                            title: 'Pengguna',
                            icon: Icons.manage_accounts_rounded,
                            route: '/users',
                          ),
                          const HomeMenuCard(
                            title: 'Pengaturan',
                            icon: Icons.settings_rounded,
                            route: '/settings',
                          ),
                          const HomeMenuCard(
                            title: 'Akun Toko',
                            icon: Icons.workspace_premium_rounded,
                            route: '/account',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),
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
