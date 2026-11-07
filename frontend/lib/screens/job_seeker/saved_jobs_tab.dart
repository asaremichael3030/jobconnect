import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../services/saved_job_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_job_card.dart';
import '../jobs/job_details_screen.dart';

class SavedJobsTab extends StatefulWidget {
  const SavedJobsTab({super.key});

  @override
  State<SavedJobsTab> createState() => _SavedJobsTabState();
}

class _SavedJobsTabState extends State<SavedJobsTab> {
  List<Job> _jobs = [];
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

    final result = await SavedJobService.fetchSavedJobs();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _jobs = result.jobs;
      } else {
        _error = result.message ?? 'Failed to load saved jobs';
      }
    });
  }

  Future<void> _openJob(Job job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: job.id),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _unsave(Job job) async {
    final result = await SavedJobService.unsave(job.id);
    if (!mounted) return;

    if (result.success) {
      setState(() {
        _jobs = _jobs.where((j) => j.id != job.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from saved')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to remove')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 12),
              Text('Could not load saved jobs', style: AppTextStyles.h3),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
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
                  Icons.bookmark_border,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('No saved jobs yet', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on any job to save it here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _jobs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return AppJobCard(
            job: job,
            saved: true,
            onTap: () => _openJob(job),
            onSaveToggle: () => _unsave(job),
          );
        },
      ),
    );
  }
}