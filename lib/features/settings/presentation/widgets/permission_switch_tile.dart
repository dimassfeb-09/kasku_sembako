import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class PermissionSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  const PermissionSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSaving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _C.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _C.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            activeColor: _C.primary,
            activeTrackColor: _C.primary.withOpacity(0.2),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: isSaving ? null : onChanged,
          ),
        ],
      ),
    );
  }
}
