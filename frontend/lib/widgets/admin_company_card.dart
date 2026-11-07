import 'package:flutter/material.dart';

import '../models/admin_company.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AdminCompanyCard extends StatelessWidget {
  final AdminCompany company;
  final VoidCallback? onTap;

  const AdminCompanyCard({
    super.key,
    required this.company,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _iconSquare(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    company.industry,
                    style: AppTextStyles.small.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${company.openJobs} open jobs',
                        style: AppTextStyles.small.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _verifiedBadge(),
          ],
        ),
      ),
    );
  }

  Widget _iconSquare() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: company.iconColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        company.initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _verifiedBadge() {
    final verified = company.verified;
    final bg = verified
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.warning.withValues(alpha: 0.12);
    final fg = verified ? AppColors.success : AppColors.warning;
    final icon = verified ? Icons.verified_outlined : Icons.access_time;
    final label = verified ? 'Verified' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.pill.copyWith(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}