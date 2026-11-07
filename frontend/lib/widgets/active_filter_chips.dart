import 'package:flutter/material.dart';

import '../models/job_filters.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ActiveFilterChips extends StatelessWidget {
  final JobFilters filters;
  final void Function(String field) onRemove;
  final VoidCallback onClearAll;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    final entries = <MapEntry<String, String>>[];
    if (filters.workingModel != null) {
      entries.add(MapEntry('workingModel', filters.workingModel!));
    }
    if (filters.jobType != null) {
      entries.add(MapEntry('jobType', filters.jobType!));
    }
    if (filters.experienceLevel != null) {
      entries.add(MapEntry('experienceLevel', filters.experienceLevel!));
    }
    if (filters.location != null) {
      entries.add(MapEntry('location', filters.location!));
    }
    if (filters.salaryMin != null || filters.salaryMax != null) {
      final min = filters.salaryMin;
      final max = filters.salaryMax;
      String label;
      if (min != null && max != null) {
        label = '\$${_compact(min)} - \$${_compact(max)}';
      } else if (min != null) {
        label = 'From \$${_compact(min)}';
      } else {
        label = 'Up to \$${_compact(max!)}';
      }
      entries.add(MapEntry('salary', label));
    }
    if (filters.company != null) {
      entries.add(MapEntry('company', filters.company!));
    }
    if (filters.postedAfter != null) {
      entries.add(MapEntry('postedAfter', 'Recent'));
    }

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                label: entry.value,
                onTap: () => onRemove(entry.key),
              ),
            ),
          ),
          _clearChip(),
        ],
      ),
    );
  }

  static String _compact(int value) {
    if (value >= 1000) {
      final k = value / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return '$value';
  }

  Widget _chip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.pill.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _clearChip() {
    return GestureDetector(
      onTap: onClearAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              'Clear all',
              style: AppTextStyles.pill.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}