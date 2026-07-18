import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../features/product/domain/entities/product_entity.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';
import '../utils/currency_formatter.dart';

class PrinterService {
  Future<List<int>> buildReceiptBytes(
    TransactionEntity transaction, {
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeLogoPath,
    String? receiptHeader,
    String? receiptFooter,
    String paperSize = '58',
    bool printLogo = true,
    bool watermarkEnabled = true,
    bool isPro = false,
  }) async {
    final profile = await CapabilityProfile.load();
    final size = paperSize == '80' ? PaperSize.mm80 : PaperSize.mm58;
    final generator = Generator(size, profile);
    List<int> bytes = [];

    if (printLogo &&
        storeLogoPath != null &&
        File(storeLogoPath).existsSync()) {
      final file = File(storeLogoPath);
      final Uint8List imageBytes = await file.readAsBytes();
      final decoded = img.decodeImage(imageBytes);
      if (decoded != null) {
        bytes += generator.image(decoded, align: PosAlign.center);
      }
    }

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
    }
    if (receiptHeader != null && receiptHeader.isNotEmpty) {
      bytes += generator.text(
        receiptHeader,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.hr();

    bytes += generator.text('No   : ${transaction.receiptNumber}');
    bytes += generator.text('Kasir: ${transaction.cashierId}');
    bytes += generator.text(
      'Waktu: ${DateFormat('dd-MM-yyyy HH:mm').format(transaction.createdAt)}',
    );
    bytes += generator.hr();

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
      bytes += generator.text(
        receiptFooter,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    if (!isPro || watermarkEnabled) {
      bytes += generator.feed(1);
      bytes += generator.hr();
      bytes += generator.text(
        'Dicetak via Kasirku',
        styles: const PosStyles(align: PosAlign.center, bold: false),
      );
      bytes += generator.text(
        'Download di PlayStore',
        styles: const PosStyles(align: PosAlign.center, bold: false),
      );
    }

    bytes += generator.feed(2);
    return bytes;
  }

  Future<bool> printBarcodeLabel(ProductEntity product, {int qty = 1}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    for (int i = 0; i < qty; i++) {
      final barcode = Barcode.code128(product.barcode.split(''));
      bytes += generator.barcode(
        barcode,
        width: 2,
        height: 80,
        textPos: BarcodeText.below,
      );
      bytes += generator.text(
        product.name,
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        product.sellingPrice.toRupiah(),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(2);
    }

    return await PrintBluetoothThermal.writeBytes(bytes);
  }
}
