import 'package:flutter/material.dart';

import '../models/job_posting.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class JobPostingCard extends StatelessWidget {
  final JobPosting posting;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const JobPostingCard({
    super.key,
    required this.posting,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconSquare(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    posting.title,
                    style: AppTextStyles.h3.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${posting.workingModel}  \u00B7  ${posting.jobType}',
                    style: AppTextStyles.small.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${posting.applicantCount} applicants',
                        style: AppTextStyles.small.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusBadge(),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onMore,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconSquare() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: posting.iconBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(posting.icon, color: posting.iconColor, size: 22),
    );
  }

  Widget _statusBadge() {
    final isActive = posting.status.toLowerCase() == 'active';
    final bg = isActive
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.textMuted.withValues(alpha: 0.12);
    final fg = isActive ? AppColors.success : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        posting.status,
        style: AppTextStyles.pill.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}