import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _MetricCard(
                  icon: RemixIcons.line_chart_line,
                  label: 'Total Omset',
                  value: totalOmset.toRupiah(),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: RemixIcons.receipt_line,
                  label: 'Transaksi',
                  value: '$totalTrx',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: RemixIcons.close_circle_line,
                  label: 'Batal',
                  value: '$voidCount',
                  color: voidCount > 0
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProfitCard(
            totalOmset: totalOmset,
            totalHpp: totalHpp,
            totalProfit: totalProfit,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final double totalOmset;
  final double totalHpp;
  final double totalProfit;

  const _ProfitCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isProfit
                        ? RemixIcons.arrow_up_line
                        : RemixIcons.arrow_down_line,
                    size: 14,
                    color: isProfit ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(ratio * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isProfit ? AppColors.success : AppColors.error,
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
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isProfit ? AppColors.success : AppColors.error,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 5, color: AppColors.borderLight),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 5,
                    color: isProfit ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Dot(
                color: AppColors.success,
                label: 'Omset: ${totalOmset.toRupiah()}',
              ),
              const SizedBox(width: 16),
              _Dot(
                color: AppColors.primary,
                label: 'HPP: ${totalHpp.toRupiah()}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
