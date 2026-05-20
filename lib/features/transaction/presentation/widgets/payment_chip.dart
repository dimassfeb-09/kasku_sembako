import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PaymentChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? PosColors.primary : PosColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? PosColors.primary : PosColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? PosColors.white : PosColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? PosColors.white : PosColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
