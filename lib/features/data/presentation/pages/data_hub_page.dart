import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class DataHubPage extends StatelessWidget {
  const DataHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final crossAxisCount = w > 480 ? 3 : 2;
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Data',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _C.textPrimary,
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
        children: [
          _DataCard(title: 'Produk', icon: RemixIcons.inbox_2_line, route: '/products', color: _C.info),
          _DataCard(title: 'Pelanggan', icon: RemixIcons.group_2_line, route: '/customers', color: _C.primary),
          _DataCard(title: 'Kategori', icon: RemixIcons.price_tag_3_line, route: '/categories', color: _C.warning),
          _DataCard(title: 'Stok', icon: RemixIcons.water_flash_line, route: '/stock', color: const Color(0xFF8B5CF6)),
          _DataCard(title: 'Hutang Piutang', icon: RemixIcons.wallet_3_line, route: '/debts', color: const Color(0xFFD97706)),
          _DataCard(title: 'Harga Grosir', icon: RemixIcons.discount_percent_line, route: '/wholesale-management', color: const Color(0xFFF43F5E), isPro: true),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final bool isPro;

  const _DataCard({required this.title, required this.icon, required this.route, required this.color, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.08),
          highlightColor: color.withOpacity(0.04),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
                if (isPro) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _C.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _C.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
