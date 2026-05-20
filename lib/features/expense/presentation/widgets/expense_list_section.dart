import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpenseListHeader extends StatelessWidget {
  final int groupedDays;
  const ExpenseListHeader({super.key, required this.groupedDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Riwayat Pengeluaran',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$groupedDays hari',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.money_off_rounded,
              color: Color(0xFF94A3B8), // Slate 400 minimal stroke
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Pengeluaran',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Catat pengeluaran operasional toko Anda di sini untuk memantau arus kas secara berkala.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseGroupedList extends StatelessWidget {
  final Map<String, List<ExpenseEntity>> grouped;
  final void Function(ExpenseEntity) onDelete;

  const ExpenseGroupedList({
    super.key,
    required this.grouped,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final keys = grouped.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final dateKey = keys[i];
        final items = grouped[dateKey]!;
        final dayTotal = items.fold(0.0, (s, e) => s + e.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    dayTotal.toRupiah(),
                    style: const TextStyle(
                      color: Color(0xFFEF4444), // Red 500
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Items
            ...items.map(
              (exp) => ExpenseTile(exp: exp, onDelete: () => onDelete(exp)),
            ),
          ],
        );
      },
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final ExpenseEntity exp;
  final VoidCallback onDelete;

  const ExpenseTile({required this.exp, required this.onDelete});

  // Returns category icon and colors (bgColor, iconColor)
  (IconData, Color, Color) _categoryConfig(String category) {
    switch (category.toLowerCase()) {
      case 'listrik':
        return (
          Icons.bolt_rounded,
          const Color(0xFFFFFBEB),
          const Color(0xFFD97706),
        ); // Amber
      case 'air':
        return (
          Icons.water_drop_rounded,
          const Color(0xFFEFF6FF),
          const Color(0xFF2563EB),
        ); // Blue
      case 'gaji':
        return (
          Icons.people_rounded,
          const Color(0xFFF0FDFA),
          const Color(0xFF0D9488),
        ); // Teal
      case 'sewa':
        return (
          Icons.home_rounded,
          const Color(0xFFEEF2FF),
          const Color(0xFF4F46E5),
        ); // Indigo
      case 'transport':
        return (
          Icons.local_shipping_rounded,
          const Color(0xFFFFF7ED),
          const Color(0xFFEA580C),
        ); // Orange
      default:
        return (
          Icons.receipt_outlined,
          const Color(0xFFF8FAFC),
          const Color(0xFF64748B),
        ); // Slate (Default)
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(exp.date);
    final (icon, bgColor, iconColor) = _categoryConfig(exp.category);

    return Dismissible(
      key: Key(exp.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Red 50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFEF4444), // Red 500
          size: 22,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Surface white Card
          borderRadius: BorderRadius.circular(16), // 16px corner radius
          border: Border.all(
            color: const Color(0xFFF1F5F9),
          ), // Slate 100 border
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000), // Soft ambient shadow
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon container with custom styled background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.category,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (exp.notes != null && exp.notes!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exp.notes!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount + delete button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exp.amount.toRupiah(),
                  style: const TextStyle(
                    color: Color(0xFFEF4444), // Red 500
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2), // Red 50
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), // Red 500
                      size: 16,
                    ),
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Hapus Catatan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
