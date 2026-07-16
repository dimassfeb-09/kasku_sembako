import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/presentation/widgets/pro_badge.dart';

typedef _C = AppColors;

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final subState = context.watch<SubscriptionCubit>().state;
    final isPro = subState is SubscriptionStatusLoaded && subState.status.isEntitled;

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
            child: Text('Pengaturan', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: _C.textSecondary)),
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: RemixIcons.printer_line,
            title: 'Pengaturan Printer',
            color: const Color(0xFF475569),
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 10),
          _SettingTile(
            icon: RemixIcons.cloud_line,
            title: 'Cadangan Data',
            color: const Color(0xFF6366F1),
            isPro: !isPro,
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text('Akun', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: _C.textSecondary)),
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
          splashColor: color.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
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
                        const ProBadge(),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
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
