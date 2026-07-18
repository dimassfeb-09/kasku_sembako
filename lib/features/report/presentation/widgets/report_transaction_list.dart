import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'report_app_bar.dart';
import 'report_transaction_detail_sheet.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReportListHeader extends StatelessWidget {
  final int length;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;
  final VoidCallback onExportCsv;

  const ReportListHeader({
    super.key,
    required this.length,
    required this.onExportPdf,
    required this.onExportExcel,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$length Transaksi',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              ReportExportButton(
                icon: RemixIcons.file_pdf_line,
                label: 'PDF',
                color: AppColors.error,
                onTap: onExportPdf,
              ),
              const SizedBox(width: 6),
              ReportExportButton(
                icon: RemixIcons.grid_line,
                label: 'Excel',
                color: AppColors.success,
                onTap: onExportExcel,
              ),
              const SizedBox(width: 6),
              ReportExportButton(
                icon: RemixIcons.table_line,
                label: 'CSV',
                color: AppColors.primary,
                onTap: onExportCsv,
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              RemixIcons.receipt_line,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tidak ada data pada periode yang dipilih',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.only(bottom: 16),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isVoided ? AppColors.borderLight : AppColors.border,
            ),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isVoided
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isVoided
                      ? RemixIcons.close_circle_line
                      : RemixIcons.receipt_line,
                  color: isVoided ? AppColors.error : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trx.receiptNumber,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isVoided
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration: isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (isVoided) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'VOID',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                                height: 1.4,
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
                          RemixIcons.time_line,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          RemixIcons.shopping_bag_line,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${trx.items.length} item',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                trx.totalAmount.toRupiah(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isVoided ? AppColors.textMuted : AppColors.success,
                  decoration: isVoided ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
