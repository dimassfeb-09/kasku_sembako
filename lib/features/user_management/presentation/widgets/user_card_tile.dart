import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';

typedef _C = AppColors;

class UserCardTile extends StatelessWidget {
  final User user;
  final VoidCallback onEditPermissions;
  final VoidCallback onChangePin;
  final ValueChanged<bool>? onToggleStatus;

  const UserCardTile({
    super.key,
    required this.user,
    required this.onEditPermissions,
    required this.onChangePin,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isSelfAdmin = user.username == 'admin';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: user.isActive ? _C.primaryLight : _C.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              user.role == 'admin'
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              color: user.isActive ? _C.primary : _C.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _C.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: user.role == 'admin'
                            ? _C.primaryLight
                            : const Color(0xFFE6FFFA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: user.role == 'admin'
                              ? _C.primary
                              : const Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isActive ? _C.success : _C.error,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        color: user.isActive ? _C.success : _C.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                onPressed: onEditPermissions,
                tooltip: 'Edit Hak Akses',
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                onPressed: onChangePin,
                tooltip: 'Ubah PIN',
              ),
              const SizedBox(width: 4),
              Switch(
                value: user.isActive,
                activeColor: _C.primary,
                activeTrackColor: _C.primary.withOpacity(0.2),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: isSelfAdmin || onToggleStatus == null
                    ? null
                    : (val) => onToggleStatus!(val),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
