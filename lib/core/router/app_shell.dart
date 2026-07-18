import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../core/theme/app_colors.dart';

typedef _C = AppColors;

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: navigationShell,
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _tabs.length,
              (i) => _NavItem(
                icon: _tabs[i].icon,
                selectedIcon: _tabs[i].selectedIcon,
                label: _tabs[i].label,
                isSelected: i == currentIndex,
                onTap: () => navigationShell.goBranch(
                  i,
                  initialLocation: i == currentIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final List<_TabData> _tabs = const [
  _TabData(RemixIcons.home_3_line, RemixIcons.home_3_fill, 'Beranda'),
  _TabData(
    RemixIcons.shopping_cart_2_line,
    RemixIcons.shopping_cart_2_fill,
    'POS',
  ),
  _TabData(RemixIcons.database_2_line, RemixIcons.database_2_fill, 'Data'),
  _TabData(RemixIcons.bar_chart_2_line, RemixIcons.bar_chart_2_fill, 'Laporan'),
  _TabData(RemixIcons.more_2_line, RemixIcons.more_2_fill, 'Lainnya'),
];

class _TabData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _TabData(this.icon, this.selectedIcon, this.label);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 22,
              color: isSelected ? _C.primary : _C.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? _C.primary : _C.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
