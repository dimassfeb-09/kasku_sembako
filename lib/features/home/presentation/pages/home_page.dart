import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';


typedef _C = AppColors;

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
            isAdmin: true,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/onboarding');
        } else if (state is Authenticated) {
          context.read<HomeBloc>().add(
            LoadHomeMetricsEvent(
              userId: state.user.id,
              isAdmin: true,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _C.background,
        appBar: AppBar(
          backgroundColor: _C.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          shape: const Border(
            bottom: BorderSide(
              color: _C.borderLight,
              width: 1,
            ),
          ),
          title: const Text(
            'Kasirku Sembako',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _C.textPrimary, // Slate 900
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: _C.danger,
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
                      backgroundColor: _C.white,
                      title: const Text(
                        'Konfirmasi Keluar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        color: _C.textPrimary,
                      ),
                    ),
                    content: const Text(
                      'Apakah Anda yakin ingin keluar dari aplikasi Kasirku Sembako?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: _C.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: _C.textSecondary,
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
                            backgroundColor: _C.danger,
                            foregroundColor: _C.white,
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

            return RefreshIndicator(
              color: _C.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(
                  LoadHomeMetricsEvent(userId: user?.id, isAdmin: true),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ─── Greeting Card ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _C.primary.withOpacity(0.08),
                              _C.primaryLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _C.primarySurface.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _C.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.primary.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                RemixIcons.store_2_line,
                                color: _C.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat ${_greeting()}, ${user?.email?.split('@').first ?? "Pengguna"}!',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: _C.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ini ringkasan toko Anda hari ini',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: _C.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Metrics ──────────────────────────────────────────
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeMetricsLoading || state is HomeInitial) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(color: _C.primary),
                              ),
                            ),
                          );
                        }

                        if (state is HomeMetricsError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: _C.errorLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: _C.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final metrics = (state as HomeMetricsLoaded).metrics;
                        final w = MediaQuery.of(context).size.width;
                        final crossAxisCount = w > 600 ? 4 : 2;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: crossAxisCount == 4 ? 1.7 : 1.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _MetricTile(
                                icon: RemixIcons.money_dollar_circle_line,
                                label: 'Omset',
                                value: metrics.omset.toRupiah(),
                                color: _C.primary,
                              ),
                              _MetricTile(
                                icon: RemixIcons.receipt_line,
                                label: 'Transaksi',
                                value: '${metrics.trxCount}',
                                color: _C.info,
                              ),
                              _MetricTile(
                                icon: RemixIcons.money_dollar_box_line,
                                label: 'Pengeluaran',
                                value: metrics.expenses.toRupiah(),
                                color: _C.danger,
                              ),
                              _MetricTile(
                                icon: RemixIcons.alert_line,
                                label: 'Stok Menipis',
                                value: '${metrics.lowStock}',
                                color: metrics.lowStock > 0 ? _C.warning : _C.textMuted,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── Quick POS Card ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _C.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _C.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _C.primaryLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                RemixIcons.shopping_cart_2_line,
                                color: _C.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mesin Kasir',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: _C.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Siap melayani transaksi baru',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: _C.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/pos'),
                                icon: const Icon(
                                  RemixIcons.add_line,
                                  size: 18,
                                  color: _C.white,
                                ),
                                label: const Text(
                                  'Buka',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _C.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _C.primary,
                                  foregroundColor: _C.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Quick Shortcuts ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            'Akses Cepat',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: _C.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _QuickChip(
                            icon: RemixIcons.inbox_2_line,
                            label: 'Produk',
                            color: _C.info,
                            onTap: () => context.push('/products'),
                          ),
                          const SizedBox(width: 10),
                          _QuickChip(
                            icon: RemixIcons.receipt_line,
                            label: 'Riwayat',
                            color: _C.primary,
                            onTap: () => context.push('/history'),
                          ),
                          const SizedBox(width: 10),
                          _QuickChip(
                            icon: RemixIcons.group_2_line,
                            label: 'Pelanggan',
                            color: const Color(0xFF0EA5E9),
                            onTap: () => context.push('/customers'),
                          ),
                        ],
                      ),
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

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'pagi';
  if (h < 15) return 'siang';
  if (h < 18) return 'sore';
  return 'malam';
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.borderLight, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: color.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
