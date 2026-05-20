import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../customer/domain/entities/customer_entity.dart';

class DebtPaymentsTab extends StatelessWidget {
  final List<CustomerEntity> customers;
  final dynamic payments;
  final String searchQuery;
  final bool isLoading;

  const DebtPaymentsTab({
    super.key,
    required this.customers,
    required this.payments,
    required this.searchQuery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final customerMap = {for (var c in customers) c.id: c.name};

    var filteredPayments = [];
    if (payments is List) {
      filteredPayments = List.from(payments);
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredPayments = filteredPayments.where((p) {
        final custName = customerMap[p.customerId]?.toLowerCase() ?? '';
        return custName.contains(query);
      }).toList();
    }

    if (isLoading && filteredPayments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (filteredPayments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_rounded, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Belum ada riwayat cicilan.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        final custName =
            customerMap[payment.customerId] ?? 'Pelanggan Terhapus';
        final formattedDate = DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(payment.createdAt);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      custName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Memo: ${payment.notes}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.amount.toRupiah(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      payment.paymentMethod,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
