import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Pengeluaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Catat pengeluaran operasional toko\nuntuk memantau arus kas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final dateKey = keys[i];
        final items = grouped[dateKey]!;
        final dayTotal = items.fold(0.0, (s, e) => s + e.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    dayTotal.toRupiah(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
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

  const ExpenseTile({super.key, required this.exp, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(exp.date);
    final (icon, bgColor, iconColor) = _categoryConfig(exp.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (exp.notes != null && exp.notes!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            exp.notes!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exp.amount.toRupiah(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 14,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

(IconData, Color, Color) _categoryConfig(String category) {
  switch (category.toLowerCase()) {
    case 'listrik':
      return (
        Icons.bolt_rounded,
        const Color(0xFFFFFBEB),
        const Color(0xFFD97706),
      );
    case 'air':
      return (
        Icons.water_drop_rounded,
        const Color(0xFFEFF6FF),
        const Color(0xFF2563EB),
      );
    case 'gaji':
      return (
        Icons.people_rounded,
        const Color(0xFFF0FDFA),
        const Color(0xFF0D9488),
      );
    case 'sewa':
      return (
        Icons.home_rounded,
        const Color(0xFFEEF2FF),
        const Color(0xFF4F46E5),
      );
    case 'transport':
      return (
        Icons.local_shipping_rounded,
        const Color(0xFFFFF7ED),
        const Color(0xFFEA580C),
      );
    default:
      return (
        Icons.receipt_outlined,
        const Color(0xFFF8FAFC),
        const Color(0xFF64748B),
      );
  }
}
