import 'package:flutter/material.dart';
import '../bloc/pos_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class CartSummary extends StatelessWidget {
  final PosState state;
  final VoidCallback onDiscountTap;
  final VoidCallback onTaxTap;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.state,
    required this.onDiscountTap,
    required this.onTaxTap,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = state.cartItems.isEmpty;
    final hasDiscount = state.discount > 0;
    final hasTax = state.tax > 0;

    return Container(
      decoration: BoxDecoration(
        color: PosColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: PosColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PosColors.textSecondary,
                ),
              ),
              Text(
                state.subtotal.toRupiah(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PosColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Adjustments Chips (Diskon & Pajak)
          Row(
            children: [
              // Discount Button (Lebih Besar)
              Expanded(
                child: Material(
                  color: hasDiscount
                      ? PosColors.dangerLight
                      : PosColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onDiscountTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasDiscount
                              ? PosColors.danger.withOpacity(0.3)
                              : PosColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            size: 18,
                            color: hasDiscount
                                ? PosColors.danger
                                : PosColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diskon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: hasDiscount
                                        ? PosColors.danger
                                        : PosColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasDiscount
                                      ? '-${state.discount.toRupiah()}'
                                      : 'Tambah',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: hasDiscount
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: hasDiscount
                                        ? PosColors.danger
                                        : PosColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: hasDiscount
                                ? PosColors.danger
                                : PosColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tax Button (Lebih Besar)
              Expanded(
                child: Material(
                  color: hasTax ? PosColors.successLight : PosColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onTaxTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasTax
                              ? PosColors.success.withOpacity(0.3)
                              : PosColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: hasTax
                                ? PosColors.success
                                : PosColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pajak/Biaya',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: hasTax
                                        ? PosColors.success
                                        : PosColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasTax
                                      ? '+${state.tax.toRupiah()}'
                                      : 'Tambah',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: hasTax
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: hasTax
                                        ? PosColors.success
                                        : PosColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: hasTax
                                ? PosColors.success
                                : PosColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Highlight Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: PosColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL AKHIR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: PosColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.cartItems.length} barang dipilih',
                      style: TextStyle(
                        fontSize: 12,
                        color: PosColors.primary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  state.total.toRupiah(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: PosColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkout Button (Lebih Besar & Jelas)
          ElevatedButton(
            onPressed: isEmpty
                ? null
                : state is PosCheckoutLoading
                ? null
                : onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: PosColors.primary,
              disabledBackgroundColor: PosColors.border,
              foregroundColor: PosColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: state is PosCheckoutLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: PosColors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_checkout_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEmpty ? 'Keranjang Kosong' : 'Proses Pembayaran',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
