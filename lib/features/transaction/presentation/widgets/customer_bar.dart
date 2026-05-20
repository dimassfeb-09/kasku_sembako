import 'package:flutter/material.dart';
import '../bloc/pos_event_state.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerBar extends StatelessWidget {
  final PosState state;
  final VoidCallback onTap;

  const CustomerBar({super.key, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasCustomer = state.selectedCustomer != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hasCustomer ? PosColors.primarySurface : PosColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasCustomer ? PosColors.primary : PosColors.border,
              ),
            ),
            child: Center(
              child: hasCustomer
                  ? Text(
                      state.selectedCustomer!.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PosColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: PosColors.textMuted,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCustomer ? state.selectedCustomer!.name : 'Pelanggan Umum',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PosColors.textPrimary,
                  ),
                ),
                if (hasCustomer)
                  Text(
                    state.selectedCustomer!.phone ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PosColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: PosColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              hasCustomer ? 'Ganti' : 'Pilih',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PosColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
