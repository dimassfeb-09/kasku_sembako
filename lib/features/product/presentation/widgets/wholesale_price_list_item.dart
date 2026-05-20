import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/wholesale_price_entity.dart';
import '../bloc/wholesale_price_bloc.dart';
import '../bloc/wholesale_price_event_state.dart';
import '../../../../core/theme/app_colors.dart';

class WholesalePriceListItem extends StatelessWidget {
  final WholesalePriceEntity price;
  final double retailPrice;
  final String unit;

  const WholesalePriceListItem({
    Key? key,
    required this.price,
    required this.retailPrice,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savings = retailPrice - price.price;
    final savingsPercent = retailPrice > 0 
        ? (savings / retailPrice * 100).toStringAsFixed(0) 
        : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
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
              Icons.sell_outlined,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembelian ≥ ${price.minQty} $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price.price.toRupiah(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Hemat ${savings.toRupiah()} ($savingsPercent%)',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 22,
            ),
            onPressed: () {
              context.read<WholesalePriceBloc>().add(DeleteWholesalePriceEvent(price.id));
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.dangerLight,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
