import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../../core/theme/app_colors.dart';

class StockProductListItem extends StatelessWidget {
  final ProductEntity product;

  const StockProductListItem({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.warehouse, color: AppColors.primary),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Stok Saat Ini: ${product.stock} ${product.unit}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: AppColors.textSecondary),
              tooltip: 'Riwayat Stok',
              onPressed: () {
                context.push('/stock/history', extra: product);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppColors.primary),
              tooltip: 'Sesuaikan Stok',
              onPressed: () async {
                final result = await context.push(
                  '/stock/adjust',
                  extra: product,
                );
                if (result == true && context.mounted) {
                  // Refresh product list so new stock reflects
                  context.read<ProductBloc>().add(LoadProductsEvent());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
