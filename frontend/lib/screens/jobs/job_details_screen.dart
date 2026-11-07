import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/saved_job_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/report_dialog.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  Job? _job;
  Map<String, dynamic>? _company;
  bool _loading = true;
  String? _error;
  bool _hasSaved = false;
  bool _hasApplied = false;
  bool _applying = false;
  bool _isSeeker = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJob();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJob() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await AuthService.readToken();
    final role = await AuthService.readRole();

    final result = await JobService.fetchJobById(widget.jobId);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _isSeeker = token != null && role == 'JOB_SEEKER';
      if (result.success) {
        _job = result.job;
        _company = result.company;
        _hasApplied = result.hasApplied;
        _hasSaved = result.hasSaved;
      } else {
        _error = result.message ?? 'Failed to load job';
      }
    });
  }

  Future<void> _submitApplication() async {
    setState(() => _applying = true);

    final result = await ApplicationService.apply(widget.jobId);

    if (!mounted) return;
    setState(() {
      _applying = false;
      if (result.success) {
        _hasApplied = true;
      }
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Application failed')),
      );
    }
  }

  Future<void> _toggleSave() async {
    final wasSaved = _hasSaved;

    setState(() => _hasSaved = !wasSaved);

    final result = wasSaved
        ? await SavedJobService.unsave(widget.jobId)
        : await SavedJobService.save(widget.jobId);

    if (!mounted) return;

    if (!result.success) {
      setState(() => _hasSaved = wasSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Could not update saved job'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.saved ? 'Job saved' : 'Removed from saved',
        ),
        backgroundColor: result.saved ? AppColors.success : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
            if (!_loading && _error == null && _job != null && _isSeeker)
              _buildApplyBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
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
              Text('Could not load job', style: AppTextStyles.h3),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJob,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final job = _job!;

    return RefreshIndicator(
      onRefresh: _loadJob,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(job),
            const SizedBox(height: 16),
            _buildInfoGrid(job),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildTabContent(job),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          if (_isSeeker)
            _circleButton(
              icon: _hasSaved ? Icons.bookmark : Icons.bookmark_border,
              onTap: _toggleSave,
              color: _hasSaved ? AppColors.primary : AppColors.textPrimary,
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'report') {
                showDialog(
                  context: context,
                  builder: (_) => ReportDialog(
                    targetType: 'JOB',
                    targetId: widget.jobId,
                    targetName: _job?.title ?? 'Job',
                  ),
                );
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing is not enabled yet')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Text('Share'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report Job', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Job job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
          _headerLogo(job),
          const SizedBox(height: 14),
          Text(
            job.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(job.companyName, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                job.location.isEmpty ? 'Location not set' : job.location,
                style: AppTextStyles.small,
              ),
            ],
          ),
          if (job.applicationDeadline != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 13,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Apply by ${_formatDate(job.applicationDeadline!)}',
                    style: AppTextStyles.pill.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerLogo(Job job) {
    if (job.companyLogoUrl != null && job.companyLogoUrl!.isNotEmpty) {
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          job.companyLogoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialLogo(job),
        ),
      );
    }
    return _initialLogo(job);
  }

  Widget _initialLogo(Job job) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: job.companyColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        job.companyInitial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildInfoGrid(Job job) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoTile(
                icon: Icons.payments_outlined,
                label: 'Salary',
                value: job.salary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoTile(
                icon: Icons.work_outline,
                label: 'Job Type',
                value: job.jobType,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InfoTile(
                icon: Icons.laptop_mac_outlined,
                label: 'Working Model',
                value: job.workingModel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InfoTile(
                icon: Icons.bar_chart_outlined,
                label: 'Level',
                value: job.experienceLevel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Company'),
          Tab(text: 'Review'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Job job) {
    return SizedBox(
      height: 340,
      child: TabBarView(
        controller: _tabController,
        children: [
          _aboutTab(job),
          _companyTab(),
          _reviewTab(),
        ],
      ),
    );
  }

  Widget _aboutTab(Job job) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this Job', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          Text(
            job.description.isEmpty
                ? 'No description provided.'
                : job.description,
            style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13),
          ),
          if (job.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Responsibilities', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            ..._bullets(job.responsibilities),
          ],
          if (job.requirements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Requirements', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            ..._bullets(job.requirements),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _bullets(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^[-*\u2022]\s*'), ''))
        .toList();

    if (lines.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 13)),
        ),
      ];
    }

    return lines.map(_bullet).toList();
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyTab() {
    final company = _company ?? {};
    final name = company['name'] as String? ?? '';
    final industry = company['industry'] as String? ?? '';
    final size = company['companySize'] as String? ?? '';
    final location = company['location'] as String? ?? '';
    final about = company['about'] as String? ?? '';
    final website = company['website'] as String? ?? '';
    final foundedYear = company['foundedYear'] as int?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Company' : name,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (industry.isNotEmpty) industry,
                        if (size.isNotEmpty) size,
                      ].join('  \u00B7  '),
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (about.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              about,
              style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          Text('Company Information', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          if (location.isNotEmpty) _bullet('Headquarters: $location'),
          if (industry.isNotEmpty) _bullet('Industry: $industry'),
          if (size.isNotEmpty) _bullet('Company size: $size'),
          if (foundedYear != null && foundedYear > 0)
            _bullet('Founded: $foundedYear'),
          if (website.isNotEmpty) _bullet('Website: $website'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _reviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 20),
              const Icon(Icons.star, color: AppColors.accent, size: 20),
              const Icon(Icons.star, color: AppColors.accent, size: 20),
              const Icon(Icons.star, color: AppColors.accent, size: 20),
              const Icon(Icons.star_border, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '4.0 out of 5',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reviews will be available in a later phase',
            style: AppTextStyles.small.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            'Company reviews are a planned feature. For now, this tab shows placeholder content.',
            style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildApplyBar() {
    final applied = _hasApplied;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: applied || _applying ? null : _submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                applied ? AppColors.textMuted : AppColors.primary,
          ),
          child: _applying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(applied ? 'Applied' : 'Apply for Job'),
        ),
      ),
    );
  }
}