import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class CartItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onQtyTap;

  const CartItem({
    super.key,
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQtyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Informasi Produk (Sisi Kiri)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: PosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      (item.unitPrice as num).toRupiah(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: PosColors.primary,
                      ),
                    ),
                    Text(
                      ' / ${item.product.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (item.unitPrice < item.product.sellingPrice) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: PosColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          size: 11,
                          color: PosColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Grosir (-${((item.product.sellingPrice - item.unitPrice) as num).toRupiah()})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: PosColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Eceran: ${(item.product.sellingPrice as num).toRupiah()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: PosColors.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 2. Subtotal & Tombol Kuantitas (Sisi Kanan)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (item.subtotal as num).toRupiah(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: PosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDecrement,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: PosColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PosColors.border, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.remove_rounded,
                        size: 16,
                        color: PosColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onQtyTap,
                    child: Container(
                      width: 44,
                      height: 32,
                      decoration: BoxDecoration(
                        color: PosColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PosColors.border, width: 1),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: PosColors.textPrimary,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 3,
                            bottom: 3,
                            child: Icon(
                              Icons.edit_rounded,
                              size: 8,
                              color: PosColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onIncrement,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: PosColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: PosColors.textMuted,
              ),
              SizedBox(height: 12),
              Text(
                'Keranjang Masih Kosong',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: PosColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap produk di katalog untuk menambahkan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: PosColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
