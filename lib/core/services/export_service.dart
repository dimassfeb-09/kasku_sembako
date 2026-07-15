import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';

class ExportService {
  Future<void> exportToPdf(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalOmset = transactions.fold(
      0.0,
      (sum, trx) => sum + trx.totalAmount,
    );

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text(
              'Laporan Penjualan',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Periode: ${dateFormat.format(start)} - ${dateFormat.format(end)}',
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Ringkasan:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Total Transaksi: ${transactions.length}'),
            pw.Text('Total Omset: ${currencyFormat.format(totalOmset)}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Tanggal', 'No. Struk', 'Pembayaran', 'Total'],
              data: transactions
                  .map(
                    (t) => [
                      DateFormat('dd/MM/yy HH:mm').format(t.createdAt),
                      t.receiptNumber,
                      t.paymentMethod,
                      currencyFormat.format(t.totalAmount),
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_penjualan.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Penjualan PDF');
  }

  Future<void> exportToExcel(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) async {
    var excel = Excel.createExcel();
    var sheet = excel['Laporan Penjualan'];
    excel.setDefaultSheet('Laporan Penjualan');

    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('No Struk'),
      TextCellValue('Kasir'),
      TextCellValue('Pembayaran'),
      TextCellValue('Total'),
    ]);

    for (var trx in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(trx.createdAt)),
        TextCellValue(trx.receiptNumber),
        TextCellValue(trx.cashierId),
        TextCellValue(trx.paymentMethod),
        DoubleCellValue(trx.totalAmount),
      ]);
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/laporan_penjualan.xlsx');
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Laporan Penjualan Excel');
    }
  }
}
