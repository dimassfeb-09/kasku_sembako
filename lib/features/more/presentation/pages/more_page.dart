import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/database/debug_seed.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart' as di;
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';

typedef _C = AppColors;

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final subState = context.watch<SubscriptionCubit>().state;
    final isPro =
        subState is SubscriptionStatusLoaded && subState.status.isEntitled;

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Lainnya',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _C.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Pengaturan',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: RemixIcons.store_2_line,
            title: 'Profil Bisnis',
            color: const Color(0xFF0D9488),
            onTap: () => context.push('/business-profile'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.printer_line,
            title: 'Pengaturan Printer',
            color: const Color(0xFF475569),
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.qr_code_line,
            title: 'QRIS',
            color: const Color(0xFF0891B2),
            onTap: () => context.push('/qris-setting'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.cloud_line,
            title: 'Cadangan Data',
            color: const Color(0xFF6366F1),
            onTap: () => context.push('/backup'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.history_line,
            title: 'Log Aktivitas',
            color: _C.textSecondary,
            isPro: !isPro,
            onTap: () async {
              if (!isPro) {
                context.push('/subscription/upgrade');
                return;
              }
              if (context.mounted) context.push('/logs');
            },
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.user_2_line,
            title: 'Karyawan',
            color: const Color(0xFF0D9488),
            onTap: () => context.push('/cashiers'),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Akun',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: RemixIcons.user_3_line,
            title: 'Akun Toko',
            color: _C.primary,
            onTap: () => context.push('/account'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.medal_2_line,
            title: 'Langganan Pro',
            color: _C.warning,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isPro ? _C.successLight : _C.warningLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPro ? _C.success : Colors.amber.shade200,
                ),
              ),
              child: Text(
                isPro ? 'Aktif' : 'Rp10rb/bln',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPro ? _C.success : Colors.amber.shade800,
                ),
              ),
            ),
            onTap: () => context.push('/subscription/upgrade'),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Debug',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _DebugPanel(),
          ],
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool isPro;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.color,
    this.isPro = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          splashColor: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 8),
                        const _ProBadge(),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (trailing == null)
                  const Icon(Icons.chevron_right_rounded, color: _C.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DebugTile(
          icon: RemixIcons.medal_2_fill,
          title: 'Toggle Pro (local)',
          subtitle: 'Insert/remove local Pro cache',
          onTap: () => _togglePro(context),
        ),
        const SizedBox(height: 10),
        _DebugTile(
          icon: RemixIcons.refresh_line,
          title: 'Refresh subscription',
          subtitle: 'Force reload status from cache',
          onTap: () => context.read<SubscriptionCubit>().loadStatus(),
        ),
        const SizedBox(height: 10),
        _DebugTile(
          icon: RemixIcons.database_2_line,
          title: 'Seed Data',
          subtitle: 'Isi data contoh (kategori, produk, transaksi)',
          onTap: () => _seedData(context),
        ),
        const SizedBox(height: 10),
        _DebugTile(
          icon: RemixIcons.close_circle_line,
          title: 'Reset All Data',
          subtitle: 'Hapus semua data dari database',
          onTap: () => _resetData(context),
        ),
      ],
    );
  }

  Future<void> _togglePro(BuildContext context) async {
    final db = di.sl<AppDatabase>();
    final existing = await db.select(db.subscriptionCaches).get();

    if (existing.any((row) => row.tier == 'pro' && row.isActive)) {
      await db.delete(db.subscriptionCaches).go();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pro dinonaktifkan (local)')),
        );
      }
    } else {
      await db
          .into(db.subscriptionCaches)
          .insertOnConflictUpdate(
            SubscriptionCachesCompanion.insert(
              id: 'current',
              tier: 'pro',
              isActive: const Value(true),
              lastVerifiedAt: DateTime.now(),
              expiresAt: Value<DateTime?>(
                DateTime.now().add(const Duration(days: 30)),
              ),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pro diaktifkan (local) — tap Refresh')),
        );
      }
    }
    if (!context.mounted) return;
    if (context.mounted) context.read<SubscriptionCubit>().loadCachedOnly();
  }

  Future<void> _seedData(BuildContext context) async {
    final db = di.sl<AppDatabase>();
    await seedDebugData(db);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data contoh berhasil ditambahkan')),
    );
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Semua data akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = di.sl<AppDatabase>();
    await resetDebugData(db);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua data berhasil direset')),
    );
  }
}

class _DebugTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DebugTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _C.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 12, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.amber.shade800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
