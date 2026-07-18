import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

IconData _paymentIcon(String method) {
  final m = method.toUpperCase();
  if (m == 'TUNAI' || m == 'CASH') return Icons.money_rounded;
  if (m == 'QRIS') return Icons.qr_code_scanner_rounded;
  if (m == 'HUTANG' || m == 'DEBT') return Icons.bookmark_rounded;
  if (m == 'TRANSFER' || m == 'BANK') return Icons.account_balance_rounded;
  return Icons.receipt_long_rounded;
}

class TransactionHistoryItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;

  const TransactionHistoryItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVoided = transaction.status == 'VOID';
    final time = DateFormat('HH:mm').format(transaction.createdAt);
    final date = DateFormat('dd/MM/yy').format(transaction.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
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
              // Payment icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isVoided
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVoided
                      ? Icons.cancel_outlined
                      : _paymentIcon(transaction.paymentMethod),
                  size: 20,
                  color: isVoided ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction.receiptNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VOID',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                                height: 1.3,
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
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$date $time',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (transaction.customerId != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.person_outline_rounded,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Member',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.totalAmount.toRupiah(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isVoided
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _paymentMethodChip(transaction.paymentMethod),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodChip(String method) {
    final Color bg;
    final Color fg;
    final String label;

    switch (method.toUpperCase()) {
      case 'TUNAI':
      case 'CASH':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF16A34A);
        label = 'Tunai';
      case 'QRIS':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'QRIS';
      case 'HUTANG':
      case 'DEBT':
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFEA580C);
        label = 'Hutang';
      case 'TRANSFER':
      case 'BANK':
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF7C3AED);
        label = 'Transfer';
      default:
        bg = AppColors.background;
        fg = AppColors.textSecondary;
        label = method;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1.3,
        ),
      ),
    );
  }
}
