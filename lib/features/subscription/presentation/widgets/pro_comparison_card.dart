import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class ProComparisonCard extends StatelessWidget {
  const ProComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          ..._features.map((f) => _FeatureRow(f: f)),
        ],
      ),
    );
  }
}

const _features = [
  _F('Produk', 'Maks 20', '∞ Tak terbatas'),
  _F('Riwayat Transaksi', '30 hari', '∞ Selamanya'),
  _F('Riwayat Stok', '30 hari', '∞ Selamanya'),
  _F('Laporan & Export Data', '—', '✓'),
  _F('Backup Cloud', '—', '✓'),
  _F('Kustom Struk (Logo, dll)', '—', '✓'),
  _F('Harga Grosir', '—', '✓'),
  _F('Void / Cetak Ulang Struk', '—', '✓'),
  _F('Penyesuaian Stok', '—', '✓'),
  _F('Log Aktivitas', '—', '✓'),
];

class _F {
  final String label;
  final String free;
  final String pro;
  const _F(this.label, this.free, this.pro);
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _C.borderLight)),
      ),
      child: Row(
        children: [
          const Text(
            'Bandingkan Fitur',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary),
          ),
          const Spacer(),
          _HBadge(label: 'Free', color: _C.textMuted, bg: _C.borderLight),
          const SizedBox(width: 10),
          _HBadge(label: 'Pro', color: Color(0xFF995500), bg: Color(0xFFFFF3D6)),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

class _HBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _HBadge({required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _F f;
  const _FeatureRow({required this.f});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _C.borderLight.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(f.label, style: const TextStyle(fontSize: 12.5, color: _C.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: _Cell(value: f.free, isPro: false),
          ),
          Expanded(
            flex: 2,
            child: _ProCell(value: f.pro),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final bool isPro;
  const _Cell({required this.value, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    final bool isCheck = value == '✓';
    final bool isCross = value == '—';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: isPro ? const Color(0xFFFFF8E7) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isPro ? FontWeight.w700 : FontWeight.w500,
          color: isCheck ? _C.success : isCross ? _C.textMuted : isPro ? const Color(0xFF995500) : _C.textSecondary,
        ),
      ),
    );
  }
}

class _ProCell extends StatelessWidget {
  final String value;
  const _ProCell({required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isCheck = value == '✓';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D6), Color(0xFFFFF8E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFE5A3)),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isCheck ? const Color(0xFF995500) : const Color(0xFF995500),
        ),
      ),
    );
  }
}
