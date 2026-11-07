import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SearchAnalyticsTab extends StatefulWidget {
  const SearchAnalyticsTab({super.key});

  @override
  State<SearchAnalyticsTab> createState() => _SearchAnalyticsTabState();
}

class _SearchAnalyticsTabState extends State<SearchAnalyticsTab> {
  SearchStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AnalyticsService.fetchSearchStats();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _stats = result.stats;
      } else {
        _error = result.message ?? 'Failed to load analytics';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Error loading stats', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Try Again')),
          ],
        ),
      );
    }

    final stats = _stats!;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Performance', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: 'Total Searches',
                    value: '${stats.totalSearches}',
                    icon: Icons.search,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    title: 'Avg Latency',
                    value: '${stats.averageLatency}ms',
                    icon: Icons.speed,
                    color: stats.averageLatency < 20 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: 'Cache Hit Rate',
                    value: '${stats.cacheHitRate}%',
                    icon: Icons.bolt,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                // Empty space for alignment
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 32),
            Text('Popular Searches', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            if (stats.popularSearches.isEmpty)
              Text('No search data yet.', style: AppTextStyles.bodyMuted)
            else
              Container(
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
                  children: [
                    for (int i = 0; i < stats.popularSearches.length; i++) ...[
                      ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          stats.popularSearches[i].query,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          '${stats.popularSearches[i].count} searches',
                          style: AppTextStyles.small,
                        ),
                      ),
                      if (i < stats.popularSearches.length - 1)
                        Divider(height: 1, color: AppColors.divider),
                    ]
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}