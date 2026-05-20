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
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sell_outlined,
              color: AppColors.textMuted,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Harga Grosir',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Atur potongan harga khusus berdasarkan kuantitas beli untuk menarik pelanggan grosir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
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
