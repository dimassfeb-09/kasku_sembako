import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';

typedef _C = AppColors;

class ReceiptPreviewCard extends StatefulWidget {
  const ReceiptPreviewCard({super.key});

  @override
  State<ReceiptPreviewCard> createState() => _ReceiptPreviewCardState();
}

class _ReceiptPreviewCardState extends State<ReceiptPreviewCard> {
  String storeName = '';
  String storeAddress = '';
  String storePhone = '';
  String receiptHeader = '';
  String receiptFooter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = sl<FlutterSecureStorage>();
    final name = await s.read(key: 'STORE_NAME');
    final addr = await s.read(key: 'STORE_ADDRESS');
    final phone = await s.read(key: 'STORE_PHONE');
    final hdr = await s.read(key: 'RECEIPT_HEADER');
    final ftr = await s.read(key: 'RECEIPT_FOOTER');
    if (!mounted) return;
    setState(() {
      storeName = name ?? '';
      storeAddress = addr ?? '';
      storePhone = phone ?? '';
      receiptHeader = hdr ?? '';
      receiptFooter = ftr ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPro = isProEntitled(context);
    final showName = isPro && storeName.isNotEmpty ? storeName : 'KasirKu';
    final showAddr = isPro && storeAddress.isNotEmpty ? storeAddress : 'Download di Playstore';
    final showPhone = isPro ? storePhone : '';
    final showHeader = isPro && receiptHeader.isNotEmpty ? receiptHeader : 'Aplikasi Kasir Gratis Terbaik';
    final showFooter = isPro && receiptFooter.isNotEmpty
        ? receiptFooter
        : 'Download KasirKu sekarang juga!\ndi playstore';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(RemixIcons.receipt_line, color: Color(0xFF16A34A), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Pratinjau Struk',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
              ),
              if (!isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFE5A3)),
                  ),
                  child: const Text('FREE', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF995500))),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaper(context, isPro, showName, showAddr, showPhone, showHeader, showFooter),
        ],
      ),
    );
  }

  Widget _buildPaper(
    BuildContext context,
    bool isPro,
    String name,
    String addr,
    String phone,
    String header,
    String footer,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0EDE4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _dashedLine(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Text(name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1,
                    color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text(addr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Telp: $phone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                ],
                const SizedBox(height: 6),
                Text(header,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: isPro ? const Color(0xFF666666) : const Color(0xFF0D9488),
                    fontStyle: isPro ? FontStyle.normal : FontStyle.italic)),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                _infoRow('No', 'INV-20260716-0001'),
                _infoRow('Kasir', 'Admin'),
                _infoRow('Waktu', '16-07-2026 14:30'),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                _itemRow('Beras Premium 5kg', '1 x 75.000', '75.000'),
                _itemRow('Gula Pasir 1kg', '2 x 18.000', '36.000'),
                _itemRow('Minyak Goreng 2L', '1 x 35.000', '35.000'),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                _totalRow(),
                const SizedBox(height: 4),
                const Text('Pembayaran: Tunai',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                Text(footer,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: isPro ? const Color(0xFF666666) : const Color(0xFF0D9488),
                    fontStyle: isPro ? FontStyle.normal : FontStyle.italic,
                    fontWeight: isPro ? FontWeight.normal : FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Terima Kasih',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
          _dashedLine(),
        ],
      ),
    );
  }

  Widget _dashedLine() {
    return SizedBox(
      height: 8,
      child: CustomPaint(
        size: const Size(double.infinity, 8),
        painter: _DashPainter(),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text('$label :',
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(fontSize: 11, color: Color(0xFF333333))),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(String name, String qtyPrice, String subtotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: Text(qtyPrice,
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)))),
              Text(subtotal,
                style: const TextStyle(fontSize: 11, color: Color(0xFF333333), fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow() {
    return Row(
      children: [
        const Expanded(
          child: Text('TOTAL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
        ),
        Text(146000.toRupiah(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    const dash = 6.0, gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + dash, size.height / 2), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
