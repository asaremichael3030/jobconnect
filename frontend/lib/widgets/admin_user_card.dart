import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AdminUserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback? onTap;

  const AdminUserCard({
    super.key,
    required this.user,
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
            _avatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(user.email, style: AppTextStyles.small.copyWith(fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _roleBadge(),
                      const SizedBox(width: 6),
                      _statusDot(),
                      const SizedBox(width: 4),
                      Text(
                        user.status,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 11,
                          color: user.status == 'Active'
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\u00B7  ${user.joinedAt}',
                        style: AppTextStyles.small.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: user.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _roleBadge() {
    final isSeeker = user.role == 'JOB_SEEKER';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isSeeker ? 'Seeker' : 'Employer',
        style: AppTextStyles.pill.copyWith(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusDot() {
    final isActive = user.status == 'Active';
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.success : AppColors.danger,
        shape: BoxShape.circle,
      ),
    );
  }
}