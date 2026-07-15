import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/cash_suggestion_helper.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event_state.dart';
import 'payment_chip.dart';
import 'pos_dialogs.dart';

typedef _C = AppColors;

class CheckoutBottomSheetContent extends StatefulWidget {
  final List<CustomerEntity> customers;

  const CheckoutBottomSheetContent({super.key, required this.customers});

  @override
  State<CheckoutBottomSheetContent> createState() =>
      _CheckoutBottomSheetContentState();
}

class _CheckoutBottomSheetContentState
    extends State<CheckoutBottomSheetContent> {
  String paymentMethod = 'CASH';
  double cashReceived = 0.0;
  late final TextEditingController cashController;

  @override
  void initState() {
    super.initState();
    cashController = TextEditingController();
  }

  @override
  void dispose() {
    cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        final change = cashReceived >= state.total
            ? cashReceived - state.total
            : 0.0;

        return Container(
          decoration: const BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Total card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(fontSize: 12, color: _C.primary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Yang harus dibayar',
                            style: TextStyle(fontSize: 11, color: _C.primary),
                          ),
                        ],
                      ),
                      Text(
                        state.total.toRupiah(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _C.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Payment method label
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Payment method pills
                Row(
                  children: [
                    PaymentChip(
                      label: 'Tunai',
                      icon: Icons.payments_rounded,
                      selected: paymentMethod == 'CASH',
                      onTap: () => setState(() => paymentMethod = 'CASH'),
                    ),
                    const SizedBox(width: 8),
                    PaymentChip(
                      label: 'QRIS',
                      icon: Icons.qr_code_rounded,
                      selected: paymentMethod == 'QRIS',
                      onTap: () => setState(() => paymentMethod = 'QRIS'),
                    ),
                    const SizedBox(width: 8),
                    PaymentChip(
                      label: 'Hutang',
                      icon: Icons.account_balance_wallet_rounded,
                      selected: paymentMethod == 'HUTANG',
                      onTap: () => setState(() => paymentMethod = 'HUTANG'),
                    ),
                  ],
                ),
                if (paymentMethod == 'CASH') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: cashController,
                    decoration: InputDecoration(
                      labelText: 'Uang Diterima',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: _C.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(
                      () => cashReceived = double.tryParse(val) ?? 0.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Cash suggestions chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: CashSuggestionHelper.getSuggestions(state.total)
                          .map((suggestion) {
                            final isSelected = cashReceived == suggestion;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text(
                                  suggestion.toRupiah(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? _C.white
                                        : _C.textSecondary,
                                  ),
                                ),
                                backgroundColor: isSelected
                                    ? _C.primary
                                    : _C.surface,
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : _C.border,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isSelected) {
                                      cashReceived = 0.0;
                                      cashController.clear();
                                    } else {
                                      cashReceived = suggestion;
                                      cashController.text = suggestion % 1 == 0
                                          ? suggestion.toInt().toString()
                                          : suggestion.toString();
                                    }
                                  });
                                },
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cashReceived >= state.total
                          ? _C.successLight
                          : _C.dangerLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kembalian',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cashReceived >= state.total
                                ? _C.success
                                : _C.danger,
                          ),
                        ),
                        Text(
                          change.toRupiah(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cashReceived >= state.total
                                ? _C.success
                                : _C.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (paymentMethod == 'HUTANG') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Pelanggan untuk Hutang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (state.selectedCustomer != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _C.successLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _C.success.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: _C.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.selectedCustomer!.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _C.textPrimary,
                                  ),
                                ),
                                if (state.selectedCustomer!.phone != null &&
                                    state.selectedCustomer!.phone!.isNotEmpty)
                                  Text(
                                    state.selectedCustomer!.phone!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _C.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              PosDialogs.showCustomerSelectionDialog(
                                context: context,
                                posState: state,
                                customers: widget.customers,
                                onCustomerAdded: (newCustomer) {
                                  widget.customers.add(newCustomer);
                                  context.read<PosBloc>().add(
                                    SelectCustomerEvent(
                                      CustomerEntity(
                                        id: newCustomer.id,
                                        name: newCustomer.name,
                                        phone: newCustomer.phone,
                                        notes: newCustomer.notes,
                                        debtAmount: newCustomer.debtAmount,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              backgroundColor: _C.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: _C.success),
                              ),
                            ),
                            child: const Text(
                              'Ganti',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _C.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _C.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _C.danger.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: _C.danger,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Transaksi hutang wajib mencantumkan nama pelanggan!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _C.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                PosDialogs.showCustomerSelectionDialog(
                                  context: context,
                                  posState: state,
                                  customers: widget.customers,
                                  onCustomerAdded: (newCustomer) {
                                    widget.customers.add(newCustomer);
                                    context.read<PosBloc>().add(
                                      SelectCustomerEvent(
                                        CustomerEntity(
                                          id: newCustomer.id,
                                          name: newCustomer.name,
                                          phone: newCustomer.phone,
                                          notes: newCustomer.notes,
                                          debtAmount: newCustomer.debtAmount,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.person_add_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Pilih Pelanggan Sekarang',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.danger,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (paymentMethod == 'HUTANG' &&
                        state.selectedCustomer == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pilih pelanggan terlebih dahulu untuk transaksi hutang.',
                          ),
                        ),
                      );
                      return;
                    }
                    if (paymentMethod == 'CASH' && cashReceived < state.total) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Jumlah uang diterima kurang dari total belanja.',
                          ),
                        ),
                      );
                      return;
                    }
                    context.read<PosBloc>().add(
                      CheckoutEvent(
                        paymentMethod,
                        (paymentMethod == 'CASH') ? cashReceived : 0,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: _C.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
