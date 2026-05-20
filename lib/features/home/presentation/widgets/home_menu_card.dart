import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../user_management/presentation/bloc/permission_cubit.dart';

class HomeMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const HomeMenuCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.route,
  }) : super(key: key);

  Color _getRouteColor(String route) {
    switch (route) {
      case '/pos':
        return const Color(0xFF0D9488); // Teal
      case '/categories':
        return const Color(0xFFF59E0B); // Amber
      case '/products':
        return const Color(0xFF3B82F6); // Blue
      case '/stock':
        return const Color(0xFF8B5CF6); // Violet / Purple
      case '/customers':
        return const Color(0xFF0EA5E9); // Sky / Cyan
      case '/debts':
        return const Color(0xFFD97706); // Dark Amber
      case '/history':
        return const Color(0xFF14B8A6); // Light Teal
      case '/reports':
        return const Color(0xFF10B981); // Emerald
      case '/expenses':
        return const Color(0xFFEF4444); // Red
      case '/wholesale-management':
        return const Color(0xFFF43F5E); // Rose
      case '/backup':
        return const Color(0xFF6366F1); // Indigo
      case '/logs':
        return const Color(0xFF64748B); // Slate
      case '/users':
        return const Color(0xFF06B6D4); // Cyan
      case '/settings':
        return const Color(0xFF475569); // Dark Slate
      default:
        return const Color(0xFF0D9488);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = context.watch<PermissionCubit>().state;
    bool hasPermission = true;

    if (permissionState is PermissionLoaded) {
      if (!permissionState.isAdmin) {
        if (route == '/products' ||
            route == '/categories' ||
            route == '/wholesale-management') {
          hasPermission = permissionState.canMenuProduct;
        } else if (route == '/stock') {
          hasPermission = permissionState.canMenuStock;
        } else if (route == '/reports') {
          hasPermission = permissionState.canMenuReport;
        }
      }
    }

    final Color routeColor = _getRouteColor(route);
    final Color primaryColor = hasPermission ? routeColor : const Color(0xFF94A3B8); // Slate 400 when locked
    final Color pastelBgColor = hasPermission ? routeColor.withOpacity(0.08) : const Color(0xFFF1F5F9); // Slate 100 when locked

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9), // Slate 100
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000), // Soft ambient shadow
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!hasPermission) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Akses Ditutup: Anda tidak memiliki izin untuk membuka menu ini.',
                  ),
                  backgroundColor: AppColors.danger,
                ),
              );
              return;
            }

            if (AppRouter.availableRoutes.contains(route)) {
              context.push(route);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu belum tersedia')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFF0FDFA), // Very light Teal splash
          highlightColor: const Color(0xFFF0FDFA).withOpacity(0.5),
          child: Opacity(
            opacity: hasPermission ? 1.0 : 0.65,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pastelBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 26,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A), // Slate 900
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!hasPermission)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2), // Red 50
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: Color(0xFFEF4444), // Red 500
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

