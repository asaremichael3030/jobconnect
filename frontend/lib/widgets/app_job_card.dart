import 'package:flutter/material.dart';

import '../models/job.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_pill.dart';

class AppJobCard extends StatelessWidget {
  final Job job;
  final bool saved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;

  const AppJobCard({
    super.key,
    required this.job,
    this.saved = false,
    this.onTap,
    this.onSaveToggle,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _companyLogo(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: AppTextStyles.h3.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.companyName,
                        style: AppTextStyles.bodyMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // THIS IS WHERE THE BADGE IS RENDERED
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (job.matchScore != null) _matchBadge(job.matchScore!),
                    const SizedBox(height: 6),
                    IconButton(
                      onPressed: onSaveToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                        color:
                            saved ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location.isEmpty ? 'Location not set' : job.location,
                    style: AppTextStyles.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AppPill(label: job.jobType),
                AppPill(label: job.workingModel),
                AppPill(label: job.experienceLevel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.applicants > 0
                        ? '${job.applicants} Applicants'
                        : 'Be the first to apply',
                    style: AppTextStyles.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  job.salary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // THIS DRAWS THE BADGE
  Widget _matchBadge(int score) {
    final Color color;
    if (score >= 90) {
      color = AppColors.success; // Green
    } else if (score >= 70) {
      color = AppColors.primary; // Blue
    } else {
      color = AppColors.textMuted; // Gray
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score% Match',
        style: AppTextStyles.pill.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _companyLogo() {
    if (job.companyLogoUrl != null && job.companyLogoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          job.companyLogoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialLogo(),
        ),
      );
    }
    return _initialLogo();
  }

  Widget _initialLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: job.companyColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        job.companyInitial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}