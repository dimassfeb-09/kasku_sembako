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

typedef _C = AppColors;

class ReceiptPreviewDialog extends StatefulWidget {
  final TransactionEntity transaction;

  const ReceiptPreviewDialog({super.key, required this.transaction});

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  String storeName = 'KASIRKU SEMBAKO';
  String storeAddress = 'Jl. Contoh No. 123, Kota';
  String storePhone = '08123456789';
  String? storeLogoPath;
  String receiptHeader = '';
  String receiptFooter = '';
  bool isLoading = true;
  bool printLogo = true;
  bool watermarkEnabled = true;
  String? _selectedPrinterMac;

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
      final header = await secureStorage.read(key: 'RECEIPT_HEADER');
      final footer = await secureStorage.read(key: 'RECEIPT_FOOTER');
      final printLogoVal =
          await secureStorage.read(key: 'PRINT_LOGO') ?? 'true';
      final watermarkVal =
          await secureStorage.read(key: 'WATERMARK_ENABLED') ?? 'true';

      setState(() {
        if (name != null && name.isNotEmpty) storeName = name;
        if (address != null && address.isNotEmpty) storeAddress = address;
        if (phone != null && phone.isNotEmpty) storePhone = phone;
        storeLogoPath = logo;
        if (header != null) receiptHeader = header;
        if (footer != null) receiptFooter = footer;
        printLogo = printLogoVal == 'true';
        watermarkEnabled = watermarkVal == 'true';
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
    String center(String text) {
      if (text.length >= 32) return text.substring(0, 32);
      return ' ' * ((32 - text.length) ~/ 2) + text;
    }

    String row(String left, String right) {
      final space = 32 - left.length - right.length;
      if (space <= 0) return '$left\n${' ' * (32 - right.length)}$right';
      return left + ' ' * space + right;
    }

    buffer.writeln(center(storeName.toUpperCase()));
    buffer.writeln(center(storeAddress));
    buffer.writeln(center('Telp: $storePhone'));
    if (receiptHeader.isNotEmpty) buffer.writeln(center(receiptHeader));
    buffer.writeln('=' * 32);
    buffer.writeln('No   : ${widget.transaction.receiptNumber}');
    buffer.writeln('Kasir: ${widget.transaction.cashierId}');
    buffer.writeln(
      'Waktu: ${DateFormat('dd-MM-yyyy HH:mm').format(widget.transaction.createdAt)}',
    );
    buffer.writeln('=' * 32);

    for (var item in widget.transaction.items) {
      buffer.writeln(item.productName);
      buffer.writeln(
        row(
          '${item.qty} x ${item.price.toRupiah(withSymbol: false)}',
          item.subtotal.toRupiah(withSymbol: false),
        ),
      );
      if (item.discount > 0) {
        buffer.writeln(
          row('', '-${item.discount.toRupiah(withSymbol: false)} (Grosir)'),
        );
      }
    }
    buffer.writeln('-' * 32);
    buffer.writeln(row('TOTAL', widget.transaction.totalAmount.toRupiah()));
    buffer.writeln(row('Pembayaran', widget.transaction.paymentMethod));
    buffer.writeln('=' * 32);
    if (receiptFooter.isNotEmpty) buffer.writeln(center(receiptFooter));
    buffer.writeln(center('Terima Kasih'));
    if (watermarkEnabled) {
      buffer.writeln('-' * 32);
      buffer.writeln(center('Dicetak via Kasirku'));
      buffer.writeln(center('Download di PlayStore'));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text(
                'Memuat...',
                style: TextStyle(fontSize: 14, color: _C.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final receipt = _generateMonospaceReceipt();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: _C.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: _C.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pratinjau Struk',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _C.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: _C.textMuted,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.borderLight),
            // Receipt content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.borderLight),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (printLogo &&
                          storeLogoPath != null &&
                          File(storeLogoPath!).existsSync())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(storeLogoPath!),
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      Text(
                        receipt,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.45,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Printer selector
            BlocBuilder<PrinterBloc, PrinterState>(
              builder: (context, pState) {
                if (pState is! PrinterLoaded || pState.printers.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cetak ke:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: pState.printers.map((p) {
                            final selected =
                                _selectedPrinterMac == p.macAddress;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedPrinterMac = p.macAddress,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected ? _C.primary : _C.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected ? _C.primary : _C.border,
                                    ),
                                  ),
                                  child: Text(
                                    p.label.isNotEmpty
                                        ? p.label
                                        : 'Printer ${p.role}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : _C.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.textSecondary,
                        side: const BorderSide(color: _C.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<PrinterBloc>().add(
                          PrintReceiptEvent(
                            widget.transaction,
                            macAddress: _selectedPrinterMac,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text(
                        'Cetak Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
