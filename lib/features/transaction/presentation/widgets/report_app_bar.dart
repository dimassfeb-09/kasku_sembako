import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirku_sembako/features/transaction/presentation/widgets/report_transaction_detail_sheet.dart';
import '../../../../core/theme/app_colors.dart';

class ReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onBack;
  final VoidCallback onSelectDateRange;

  const ReportAppBar({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onBack,
    required this.onSelectDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yy');
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 18,
        ),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Penjualan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${dateFormat.format(startDate)}  →  ${dateFormat.format(endDate)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        ReportActionButton(
          icon: Icons.calendar_month_rounded,
          label: 'Periode',
          onTap: onSelectDateRange,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ReportExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ReportExportButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
