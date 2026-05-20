import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StockFilterChip extends StatelessWidget {
  final String value;
  final String label;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const StockFilterChip({
    super.key,
    required this.value,
    required this.label,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;
    Color activeColor = AppColors.primary;
    Color activeBg = AppColors.primaryLight;
    if (value == 'OUT_OF_STOCK') {
      activeColor = AppColors.danger;
      activeBg = AppColors.dangerLight;
    } else if (value == 'LOW_STOCK') {
      activeColor = AppColors.warning;
      activeBg = AppColors.warningLight;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeBg : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
