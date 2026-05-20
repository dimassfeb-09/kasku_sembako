import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../di/injection.dart';
import '../../../settings/presentation/bloc/printer_bloc.dart';
import '../../../settings/presentation/bloc/printer_event_state.dart';
import '../../domain/entities/transaction_entity.dart';
import 'dashed_divider.dart';

typedef _C = AppColors;

class ReceiptPreviewDialog extends StatefulWidget {
  final TransactionEntity transaction;

  const ReceiptPreviewDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  String storeName = 'KASIRKU SEMBAKO';
  String storeAddress = 'Jl. Contoh No. 123, Kota';
  String storePhone = '08123456789';
  String? storeLogoPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final secureStorage = sl<FlutterSecureStorage>();
      final name = await secureStorage.read(key: 'STORE_NAME');
      final address = await secureStorage.read(key: 'STORE_ADDRESS');
      final phone = await secureStorage.read(key: 'STORE_PHONE');
      final logo = await secureStorage.read(key: 'STORE_LOGO_PATH');

      setState(() {
        if (name != null && name.isNotEmpty) storeName = name;
        if (address != null && address.isNotEmpty) storeAddress = address;
        if (phone != null && phone.isNotEmpty) storePhone = phone;
        storeLogoPath = logo;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateMonospaceReceipt() {
    final buffer = StringBuffer();

    // Helper untuk merata-tengahkan teks (center)
    String centerText(String text) {
      if (text.length >= 32) return text.substring(0, 32);
      final padding = (32 - text.length) ~/ 2;
      return ' ' * padding + text;
    }

    // Helper untuk membuat baris kiri-kanan (row)
    String formatRow(String left, String right) {
      final space = 32 - left.length - right.length;
      if (space <= 0) return '$left\n${' ' * (32 - right.length)}$right';
      return left + ' ' * space + right;
    }

    buffer.writeln(centerText(storeName.toUpperCase()));
    buffer.writeln(centerText(storeAddress));
    buffer.writeln(centerText('Telp: $storePhone'));
    buffer.writeln('=' * 32);
    buffer.writeln('No   : ${widget.transaction.receiptNumber}');
    buffer.writeln('Kasir: ${widget.transaction.cashierId}');
    buffer.writeln(
      'Waktu: ${DateFormat('dd-MM-yyyy HH:mm').format(widget.transaction.createdAt)}',
    );
    buffer.writeln('=' * 32);

    for (var item in widget.transaction.items) {
      buffer.writeln(item.productName);
      final qtyPrice =
          '${item.qty} x ${item.price.toRupiah(withSymbol: false)}';
      final subtotal = item.subtotal.toRupiah(withSymbol: false);

      buffer.writeln(formatRow(qtyPrice, subtotal));

      if (item.discount > 0) {
        final discText =
            '-${item.discount.toRupiah(withSymbol: false)} (Grosir)';
        buffer.writeln(formatRow('', discText));
      }
    }
    buffer.writeln('-' * 32);
    buffer.writeln(
      formatRow(
        'TOTAL',
        widget.transaction.totalAmount.toRupiah(),
      ),
    );
    buffer.writeln(formatRow('Pembayaran', widget.transaction.paymentMethod));
    buffer.writeln('=' * 32);
    buffer.writeln(centerText('Terima Kasih'));
    buffer.writeln(centerText('Barang yang sudah dibeli'));
    buffer.writeln(centerText('tidak dapat ditukar'));

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Memuat pratinjau...'),
            ],
          ),
        ),
      );
    }

    final rawReceipt = _generateMonospaceReceipt();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kertas Struk
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7), // Off-white premium
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ripped paper top dashed line
                      const DashedDivider(
                        height: 6,
                        color: _C.border,
                        dashWidth: 6,
                        dashGap: 4,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.receipt_long_rounded,
                            color: _C.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pratinjau Struk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _C.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const Divider(height: 1, color: _C.border),
                      // Receipt Monospace Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF0EDE4)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (storeLogoPath != null && File(storeLogoPath!).existsSync())
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Center(
                                      child: Image.file(
                                        File(storeLogoPath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                Text(
                                  rawReceipt,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Ripped paper bottom dashed line
                      const DashedDivider(
                        height: 6,
                        color: _C.border,
                        dashWidth: 6,
                        dashGap: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PrinterBloc>().add(
                        PrintReceiptEvent(widget.transaction),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Cetak Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
