import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class VerificationBadge extends StatelessWidget {
  final String status;

  const VerificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    late final Color color;
    late final IconData icon;
    late final String label;

    switch (upper) {
      case 'VERIFIED':
        color = AppColors.success;
        icon = Icons.verified_outlined;
        label = 'Verified';
        break;
      case 'REJECTED':
        color = AppColors.danger;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      case 'PENDING':
      default:
        color = AppColors.warning;
        icon = Icons.access_time;
        label = 'Pending review';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.pill.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}