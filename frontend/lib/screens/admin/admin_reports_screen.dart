import 'package:flutter/material.dart';

import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<Report> _reports = [];
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
    
    try {
      final reports = await ReportService.fetchReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(Report report, String status) async {
    final success = await ReportService.updateStatus(report.id, status);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report marked as $status')),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorState()
              : _reports.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.danger.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          report.targetType,
                                          style: AppTextStyles.pill.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          report.targetName,
                                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Reported by: ${report.reporterName}',
                                    style: AppTextStyles.small.copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(report.reason, style: AppTextStyles.body.copyWith(fontSize: 13)),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (report.status == 'PENDING') ...[
                                        TextButton(
                                          onPressed: () => _updateStatus(report, 'REVIEWED'),
                                          child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _updateStatus(report, 'RESOLVED'),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(100, 36),
                                            backgroundColor: AppColors.primary,
                                          ),
                                          child: const Text('Resolve'),
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            report.status,
                                            style: AppTextStyles.pill.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Error Loading Reports', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('All caught up!', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'There are no pending reports to review.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}