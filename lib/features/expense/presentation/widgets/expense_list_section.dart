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
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Riwayat Pengeluaran',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$groupedDays hari',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.money_off_rounded,
              color: AppColors.textSecondary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pengeluaran',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap tombol Tambah untuk mencatat\npengeluaran operasional toko',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
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
                    dateKey,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    dayTotal.toRupiah(),
                    style: const TextStyle(
                      color: AppColors.error,
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

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'listrik':
        return Icons.bolt_rounded;
      case 'air':
        return Icons.water_drop_rounded;
      case 'gaji':
        return Icons.people_rounded;
      case 'sewa':
        return Icons.home_rounded;
      case 'transport':
        return Icons.local_shipping_rounded;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(exp.date);

    return Dismissible(
      key: Key(exp.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(exp.category),
                color: AppColors.error,
                size: 20,
              ),
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
                      fontWeight: FontWeight.bold,
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
            // Amount + delete
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exp.amount.toRupiah(),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.textSecondary,
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

