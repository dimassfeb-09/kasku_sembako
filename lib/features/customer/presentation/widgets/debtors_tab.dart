import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import 'customer_list_item.dart';

class DebtorsTab extends StatelessWidget {
  final List<CustomerEntity> customers;
  final String searchQuery;
  final bool isLoading;

  const DebtorsTab({
    super.key,
    required this.customers,
    required this.searchQuery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    var debtors = customers.where((c) => c.debtAmount > 0).toList();

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      debtors = debtors
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    if (isLoading && debtors.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (debtors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              query.isNotEmpty
                  ? 'Debitur tidak ditemukan'
                  : 'Luar biasa! Tidak ada piutang aktif.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debtors.length,
      itemBuilder: (context, index) {
        return CustomerListItem(customer: debtors[index]);
      },
    );
  }
}
