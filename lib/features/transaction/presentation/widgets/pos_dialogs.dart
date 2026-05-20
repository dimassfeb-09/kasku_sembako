import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import 'amount_dialog.dart';
import 'checkout_bottom_sheet.dart';
import 'customer_selection_dialog.dart';
import 'qty_adjust_dialog.dart';
import 'receipt_preview_dialog.dart';

typedef _C = AppColors;

class PosDialogs {
  const PosDialogs._();

  static void showCustomerSelectionDialog({
    required BuildContext context,
    required PosState posState,
    required List<CustomerEntity> customers,
    required Function(CustomerEntity) onCustomerAdded,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomerSelectionDialog(
        posState: posState,
        customers: customers,
        onCustomerAdded: onCustomerAdded,
      ),
    );
  }

  static void showCheckoutDialog({
    required BuildContext context,
    required List<CustomerEntity> customers,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => CheckoutBottomSheetContent(customers: customers),
    );
  }

  static void showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: _C.dangerLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: _C.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kosongkan Keranjang?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua produk dalam keranjang akan dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _C.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PosBloc>().add(ClearCartEvent());
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.danger,
                        foregroundColor: _C.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kosongkan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showDiscountDialog({
    required BuildContext context,
    required PosState posState,
  }) {
    final controller = TextEditingController(
      text: posState.discount.toString(),
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AmountDialog(
        title: 'Potongan Diskon',
        icon: Icons.local_offer_rounded,
        iconColor: _C.danger,
        iconBg: _C.dangerLight,
        controller: controller,
        onApply: () {
          final disc = double.tryParse(controller.text) ?? 0.0;
          context.read<PosBloc>().add(SetDiscountEvent(disc));
        },
      ),
    );
  }

  static void showTaxDialog({
    required BuildContext context,
    required PosState posState,
  }) {
    final controller = TextEditingController(text: posState.tax.toString());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AmountDialog(
        title: 'Pajak / Biaya Tambahan',
        icon: Icons.receipt_long_rounded,
        iconColor: _C.success,
        iconBg: _C.successLight,
        controller: controller,
        onApply: () {
          final tax = double.tryParse(controller.text) ?? 0.0;
          context.read<PosBloc>().add(SetTaxEvent(tax));
        },
      ),
    );
  }

  static void showQtyEditDialog({
    required BuildContext context,
    required dynamic item,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => QtyEditDialog(item: item),
    );
  }

  static void showCheckoutSuccessDialog({
    required BuildContext context,
    required PosCheckoutSuccess state,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: _C.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _C.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _C.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No. Struk: ${state.transaction.receiptNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _C.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingin mencetak struk sekarang?',
                style: TextStyle(fontSize: 13, color: _C.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _C.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Nanti',
                        style: TextStyle(
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => ReceiptPreviewDialog(
                            transaction: state.transaction,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Cetak Struk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: _C.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
