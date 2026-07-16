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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: _C.white,
        indicatorColor: _C.primaryLight,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 72,
        destinations: const [
          NavigationDestination(
            icon: Icon(RemixIcons.home_3_line, color: _C.textMuted),
            selectedIcon: Icon(RemixIcons.home_3_fill, color: _C.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(RemixIcons.shopping_cart_2_line, color: _C.textMuted),
            selectedIcon: Icon(RemixIcons.shopping_cart_2_fill, color: _C.primary),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(RemixIcons.database_2_line, color: _C.textMuted),
            selectedIcon: Icon(RemixIcons.database_2_fill, color: _C.primary),
            label: 'Data',
          ),
          NavigationDestination(
            icon: Icon(RemixIcons.bar_chart_2_line, color: _C.textMuted),
            selectedIcon: Icon(RemixIcons.bar_chart_2_fill, color: _C.primary),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(RemixIcons.more_2_line, color: _C.textMuted),
            selectedIcon: Icon(RemixIcons.more_2_fill, color: _C.primary),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}
