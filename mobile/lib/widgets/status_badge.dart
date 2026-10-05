import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  factory StatusBadge.verified() => const StatusBadge(
        label: 'Verified',
        icon: Icons.check_circle,
        color: AppColors.success,
      );

  factory StatusBadge.pending() => const StatusBadge(
        label: 'Pending',
        icon: Icons.schedule,
        color: AppColors.warning,
      );

  factory StatusBadge.offline() => const StatusBadge(
        label: 'Pending sync',
        icon: Icons.cloud_off,
        color: AppColors.warning,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
