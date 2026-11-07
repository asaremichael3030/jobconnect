import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../models/job_filters.dart';
import '../../services/job_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/active_filter_chips.dart';
import '../../widgets/app_job_card.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/filter_bottom_sheet.dart';
import 'job_details_screen.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  JobFilters _filters = const JobFilters();
  String _sortBy = 'Relevance';

  List<Job> _allJobs = [];
  bool _loading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await JobService.fetchJobs(
      search: _query.isEmpty ? null : _query,
      workingModel: _filters.workingModel,
      jobType: _filters.jobType,
      experienceLevel: _filters.experienceLevel,
      location: _filters.location,
      salaryMin: _filters.salaryMin,
      salaryMax: _filters.salaryMax,
      company: _filters.company,
      postedAfter: _filters.postedAfter,
      sort: _sortBy,
      limit: 50,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _allJobs = result.jobs;
      } else {
        _error = result.message ?? 'Failed to load jobs';
      }
    });
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadJobs();
    });
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<JobFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(initial: _filters),
    );

    if (result != null) {
      setState(() => _filters = result);
      await _loadJobs();
    }
  }

  void _removeFilter(String field) {
    setState(() {
      switch (field) {
        case 'workingModel':
          _filters = _filters.copyWith(clearWorkingModel: true);
          break;
        case 'jobType':
          _filters = _filters.copyWith(clearJobType: true);
          break;
        case 'experienceLevel':
          _filters = _filters.copyWith(clearExperienceLevel: true);
          break;
        case 'location':
          _filters = _filters.copyWith(clearLocation: true);
          break;
        case 'salary':
          _filters = _filters.copyWith(clearSalary: true);
          break;
        case 'company':
          _filters = _filters.copyWith(clearCompany: true);
          break;
        case 'postedAfter':
          _filters = _filters.copyWith(clearPostedAfter: true);
          break;
      }
    });
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            ActiveFilterChips(
              filters: _filters,
              onRemove: _removeFilter,
              onClearAll: () {
                setState(() => _filters = const JobFilters());
                _loadJobs();
              },
            ),
            _buildResultsHeader(),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: AppSearchBar(
              hint: 'Search jobs, skills, or companies...',
              controller: _searchController,
              onChanged: _onQueryChanged,
              onFilterTap: _openFilters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            _loading ? 'Searching...' : '${_allJobs.length} jobs found',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadJobs();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Relevance', child: Text('Relevance')),
              PopupMenuItem(value: 'Newest', child: Text('Newest')),
              PopupMenuItem(
                value: 'Salary: High to Low',
                child: Text('Salary: High to Low'),
              ),
              PopupMenuItem(
                value: 'Salary: Low to High',
                child: Text('Salary: Low to High'),
              ),
            ],
            child: Row(
              children: [
                Text(
                  _sortBy,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
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
              Text('Could not load jobs', style: AppTextStyles.h3),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobs,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text('No jobs found', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Try different keywords or filters',
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _allJobs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final job = _allJobs[index];
          return AppJobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailsScreen(jobId: job.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}