import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customer/domain/entities/customer_entity.dart';

class DebtSummaryCards extends StatelessWidget {
  final List<CustomerEntity> customers;

  const DebtSummaryCards({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    final activeDebtors = customers.where((c) => c.debtAmount > 0).toList();
    final totalPiutang = activeDebtors.fold<double>(
      0.0,
      (sum, c) => sum + c.debtAmount,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.transparent, // Blends into Scaffold background
      child: Row(
        children: [
          // Total Piutang Card (Amber warning theme)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Amber 50
                borderRadius: BorderRadius.circular(16), // 16px corner radius
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1,
                ), // Amber 200 border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PIUTANG TOKO',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFB45309), // Amber 700
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalPiutang.toRupiah(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706), // Amber 600
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Active Debtors Card (Teal theme)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA), // Teal 50
                borderRadius: BorderRadius.circular(16), // 16px corner radius
                border: Border.all(
                  color: const Color(0xFFCCFBF1),
                  width: 1,
                ), // Teal 100 border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PELANGGAN BERHUTANG',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF0F766E), // Teal 700
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${activeDebtors.length} Pelanggan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D9488), // Teal 600
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
