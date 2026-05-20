import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportSummarySection extends StatelessWidget {
  final double totalOmset;
  final double totalHpp;
  final double totalProfit;
  final int totalTrx;
  final int voidCount;

  const ReportSummarySection({
    super.key,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalProfit,
    required this.totalTrx,
    required this.voidCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top metrics row
          Row(
            children: [
              ReportMetricTile(
                label: 'Total Omset',
                value: totalOmset.toRupiah(),
                icon: Icons.trending_up_rounded,
                accent: AppColors.success,
                flex: 2,
              ),
              const SizedBox(width: 10),
              ReportMetricTile(
                label: 'Transaksi',
                value: '$totalTrx nota',
                icon: Icons.receipt_long_rounded,
                accent: AppColors.primary,
                flex: 1,
              ),
              const SizedBox(width: 10),
              ReportMetricTile(
                label: 'Dibatalkan',
                value: '$voidCount void',
                icon: Icons.cancel_outlined,
                accent: voidCount > 0
                    ? AppColors.error
                    : AppColors.textSecondary,
                flex: 1,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Profit bar
          ReportProfitBar(
            totalOmset: totalOmset,
            totalHpp: totalHpp,
            totalProfit: totalProfit,
          ),
        ],
      ),
    );
  }
}

class ReportProfitBar extends StatelessWidget {
  final double totalOmset;
  final double totalHpp;
  final double totalProfit;

  const ReportProfitBar({
    super.key,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalProfit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = totalOmset > 0
        ? (totalProfit / totalOmset).clamp(0.0, 1.0)
        : 0.0;
    final isProfit = totalProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Laba Bersih',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isProfit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: isProfit ? AppColors.success : AppColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(ratio * 100).toStringAsFixed(1)}% margin',
                    style: TextStyle(
                      color: isProfit ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            totalProfit.toRupiah(),
            style: TextStyle(
              color: isProfit ? AppColors.success : AppColors.error,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: AppColors.border),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isProfit
                            ? [
                                AppColors.success.withValues(alpha: 0.6),
                                AppColors.success,
                              ]
                            : [
                                AppColors.error.withValues(alpha: 0.6),
                                AppColors.error,
                              ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReportLabeledDot(
                color: AppColors.primary,
                label: 'HPP: ${totalHpp.toRupiah()}',
              ),
              ReportLabeledDot(
                color: AppColors.success,
                label: 'Omset: ${totalOmset.toRupiah()}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final int flex;

  const ReportMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ReportLabeledDot extends StatelessWidget {
  final Color color;
  final String label;

  const ReportLabeledDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

