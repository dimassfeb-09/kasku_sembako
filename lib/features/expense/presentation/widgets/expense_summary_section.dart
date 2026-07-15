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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.transparent, // Blends into Slate 50 background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total all-time (Red 50 / Red 100 soft themed container)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Red 50
              borderRadius: BorderRadius.circular(16), // 16px corners
              border: Border.all(
                color: const Color(0xFFFEE2E2),
                width: 1,
              ), // Red 100 border
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
                        color: Color(0xFFB91C1C), // Red 700
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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
                    color: Color(0xFFDC2626), // Red 600
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
                color: const Color(0xFFF59E0B), // Amber 500
                bgColor: const Color(0xFFFFFBEB), // Amber 50
              ),
              const SizedBox(width: 8),
              ExpenseMiniMetric(
                label: 'Bulan Ini',
                value: totalThisMonth.toRupiah(),
                icon: Icons.calendar_month_rounded,
                color: AppColors.primary, // Teal
                bgColor: const Color(0xFFF0FDFA), // Teal 50
              ),
              const SizedBox(width: 8),
              ExpenseMiniMetric(
                label: 'Catatan',
                value: '$itemCount Item',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF10B981), // Green 500
                bgColor: const Color(0xFFECFDF5), // Green 50
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
  final Color bgColor;

  const ExpenseMiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Surface white Card
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
          ), // Slate 100 border
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000), // Soft ambient shadow
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor, // Custom light background
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
                      fontWeight: FontWeight.w600,
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
