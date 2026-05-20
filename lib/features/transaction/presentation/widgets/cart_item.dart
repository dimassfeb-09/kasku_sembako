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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PosColors.successLight,
                      borderRadius: BorderRadius.circular(4),
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
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: onDecrement,
                    iconColor: PosColors.danger,
                    bgColor: PosColors.dangerLight,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onQtyTap,
                    child: Container(
                      width: 48,
                      height: 36,
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
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: PosColors.textPrimary,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Icon(
                              Icons.edit_rounded,
                              size: 10,
                              color: PosColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    onTap: onIncrement,
                    iconColor: PosColors.success,
                    bgColor: PosColors.successLight,
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: PosColors.textMuted,
            ),
            SizedBox(height: 6),
            Text(
              'Keranjang masih kosong',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: PosColors.textSecondary,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Tap produk untuk menambahkan',
              style: TextStyle(fontSize: 11, color: PosColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
