import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/permission_cubit.dart';

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

    final Color primaryColor = hasPermission
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;

    return InkWell(
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
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: hasPermission ? 1.0 : 0.6,
        child: Card(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 36, color: primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasPermission)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
