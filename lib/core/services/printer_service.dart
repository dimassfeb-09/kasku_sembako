import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:intl/intl.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';

class PrinterService {
  Future<bool> printReceipt(
    TransactionEntity transaction, {
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? receiptHeader,
    String? receiptFooter,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      storeName ?? 'KASIRKU SEMBAKO',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      storeAddress ?? 'Jl. Contoh No. 123, Kota',
      styles: const PosStyles(align: PosAlign.center),
    );
    if (storePhone != null && storePhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $storePhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    } else {
      bytes += generator.text(
        'Telp: 08123456789',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (receiptHeader != null && receiptHeader.isNotEmpty) {
      bytes += generator.text(receiptHeader,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.hr();

    // Transaction Info
    bytes += generator.text('No   : ${transaction.receiptNumber}');
    bytes += generator.text(
      'Kasir: ${transaction.cashierId}',
    ); // Bisa diganti nama kasir asli jika digabungkan
    bytes += generator.text(
      'Waktu: ${DateFormat('dd-MM-yyyy HH:mm').format(transaction.createdAt)}',
    );
    bytes += generator.hr();

    // Items
    for (var item in transaction.items) {
      bytes += generator.text(
        item.productName,
        styles: const PosStyles(bold: true),
      );

      final qtyPrice =
          '${item.qty} x ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.price)}';
      final subtotal = NumberFormat.currency(
        locale: 'id',
        symbol: '',
        decimalDigits: 0,
      ).format(item.subtotal);

      bytes += generator.row([
        PosColumn(text: qtyPrice, width: 8),
        PosColumn(
          text: subtotal,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (item.discount > 0) {
        final discText =
            '-${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.discount)} (Grosir)';
        bytes += generator.row([
          PosColumn(text: '', width: 8),
          PosColumn(
            text: discText,
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }
    bytes += generator.hr();

    // Totals
    final totalFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: totalFormat.format(transaction.totalAmount),
        width: 6,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
      'Pembayaran: ${transaction.paymentMethod}',
      styles: const PosStyles(align: PosAlign.right),
    );
    bytes += generator.hr();
    if (receiptFooter != null && receiptFooter.isNotEmpty) {
      bytes += generator.text(receiptFooter,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);

    final bool result = await PrintBluetoothThermal.writeBytes(bytes);
    return result;
  }

  Future<bool> printTest() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      'TEST PRINTER BERHASIL',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);

    return await PrintBluetoothThermal.writeBytes(bytes);
  }
}
