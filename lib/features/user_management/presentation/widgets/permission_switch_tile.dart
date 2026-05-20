import 'package:flutter/material.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSaving ? null : () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFF0FDFA), // Teal 50
        highlightColor: const Color(0xFFF0FDFA).withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
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
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A), // Slate 900
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF64748B), // Slate 500
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                activeColor: const Color(0xFF0D9488), // Teal 600
                activeTrackColor: const Color(0xFF99F6E4), // Teal 200
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0), // Slate 200
                onChanged: isSaving ? null : onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
