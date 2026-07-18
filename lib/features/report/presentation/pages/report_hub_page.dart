import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class ReportHubPage extends StatelessWidget {
  const ReportHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Laporan',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _C.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ReportCard(
              title: 'Riwayat Transaksi',
              icon: RemixIcons.receipt_line,
              route: '/history',
              color: _C.primary,
            ),
            const SizedBox(height: 10),
            _ReportCard(
              title: 'Laporan',
              icon: RemixIcons.bar_chart_grouped_line,
              route: '/reports',
              color: _C.success,
            ),
            const SizedBox(height: 10),
            _ReportCard(
              title: 'Pengeluaran',
              icon: RemixIcons.money_dollar_box_line,
              route: '/expenses',
              color: _C.danger,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
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
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: _C.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
