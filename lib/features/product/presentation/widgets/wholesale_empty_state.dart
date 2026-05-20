import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WholesaleEmptyState extends StatelessWidget {
  const WholesaleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sell_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Harga Grosir',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Atur potongan harga khusus berdasarkan kuantitas beli untuk menarik pelanggan grosir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
