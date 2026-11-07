import 'package:flutter/material.dart';

import '../../models/application.dart';
import '../../services/application_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/application_card.dart';

class MyApplicationsTab extends StatefulWidget {
  const MyApplicationsTab({super.key});

  @override
  State<MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<MyApplicationsTab> {
  List<Application> _applications = [];
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

    final result = await ApplicationService.fetchMyApplications();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _applications = result.applications;
      } else {
        _error = result.message ?? 'Failed to load applications';
      }
    });
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
              Text('Could not load applications', style: AppTextStyles.h3),
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

    if (_applications.isEmpty) {
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
                  Icons.description_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('No applications yet', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'Jobs you apply to will appear here.',
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
        itemCount: _applications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final app = _applications[index];
          return ApplicationCard(
            application: app,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/job-details',
                arguments: app.jobId,
              );
            },
          );
        },
      ),
    );
  }
}