import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpenseSummarySection extends StatelessWidget {
  final double totalAll;
  final double totalToday;
  final double totalThisMonth;
  final int itemCount;

  const ExpenseSummarySection({
    super.key,
    required this.totalAll,
    required this.totalToday,
    required this.totalThisMonth,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total all-time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withOpacity(0.08),
                  AppColors.error.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL PENGELUARAN',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semua Transaksi Terdaftar',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  totalAll.toRupiah(),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Today & Month row
          Row(
            children: [
              ExpenseMiniMetric(
                label: 'Hari Ini',
                value: totalToday.toRupiah(),
                icon: Icons.today_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              ExpenseMiniMetric(
                label: 'Bulan Ini',
                value: totalThisMonth.toRupiah(),
                icon: Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              ExpenseMiniMetric(
                label: 'Catatan',
                value: '$itemCount Item',
                icon: Icons.receipt_long_rounded,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenseMiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ExpenseMiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 10),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
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
