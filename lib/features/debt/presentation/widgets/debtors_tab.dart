import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/presentation/widgets/customer_list_item.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                query.isNotEmpty ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
                size: 64,
                color: query.isNotEmpty ? const Color(0xFF94A3B8) : const Color(0xFF10B981), // Slate 400 or Green 500
              ),
              const SizedBox(height: 16),
              Text(
                query.isNotEmpty ? 'Debitur Tidak Ditemukan' : 'Semua Tagihan Lunas',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                query.isNotEmpty
                    ? 'Coba cari nama pelanggan dengan ejaan yang berbeda.'
                    : 'Luar biasa! Tidak ada catatan piutang aktif dari pelanggan saat ini.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
