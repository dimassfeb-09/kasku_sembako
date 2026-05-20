import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirku_sembako/features/transaction/presentation/widgets/report_app_bar.dart';
import 'package:kasirku_sembako/features/transaction/presentation/widgets/report_transaction_detail_sheet.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportListHeader extends StatelessWidget {
  final int length;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  const ReportListHeader({
    super.key,
    required this.length,
    required this.onExportPdf,
    required this.onExportExcel,
  });

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
          Text(
            '$length Transaksi',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              ReportExportButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                color: AppColors.error,
                onTap: onExportPdf,
              ),
              const SizedBox(width: 8),
              ReportExportButton(
                icon: Icons.grid_on_rounded,
                label: 'Excel',
                color: AppColors.success,
                onTap: onExportExcel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportEmptyState extends StatelessWidget {
  const ReportEmptyState({super.key});

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
              Icons.receipt_long_rounded,
              color: AppColors.textSecondary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada transaksi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tidak ada data pada periode yang dipilih',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ReportTransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final void Function(String id) onVoid;

  const ReportTransactionList({
    super.key,
    required this.transactions,
    required this.onVoid,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final trx = transactions[index];
        return ReportTransactionTile(
          trx: trx,
          onTap: () {
            final isVoided = trx.status == 'VOID';
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => ReportTransactionDetailSheet(
                trx: trx,
                isVoided: isVoided,
                onVoid: () {
                  Navigator.pop(ctx);
                  onVoid(trx.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class ReportTransactionTile extends StatelessWidget {
  final TransactionEntity trx;
  final VoidCallback onTap;

  const ReportTransactionTile({
    super.key,
    required this.trx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVoided = trx.status == 'VOID';
    final dateStr = DateFormat('dd MMM · HH:mm').format(trx.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVoided
                ? AppColors.error.withValues(alpha: 0.2)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isVoided
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isVoided
                      ? AppColors.error.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                isVoided ? Icons.cancel_rounded : Icons.receipt_long_rounded,
                color: isVoided ? AppColors.error : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        trx.receiptNumber,
                        style: TextStyle(
                          color: isVoided
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: isVoided
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (isVoided) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VOID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trx.items.length} item',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              trx.totalAmount.toRupiah(),
              style: TextStyle(
                color: isVoided ? AppColors.textSecondary : AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                decoration: isVoided ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
