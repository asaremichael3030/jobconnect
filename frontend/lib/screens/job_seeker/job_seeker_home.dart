import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../services/job_service.dart';
import '../../services/notification_service.dart';
import '../../services/saved_job_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_job_card.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_stat_card.dart';
import '../../widgets/section_header.dart';
import '../jobs/job_details_screen.dart';
import '../notifications/notifications_screen.dart';
import 'my_applications_tab.dart';
import 'saved_jobs_tab.dart';

class JobSeekerHome extends StatefulWidget {
  const JobSeekerHome({super.key});

  @override
  State<JobSeekerHome> createState() => _JobSeekerHomeState();
}

class _JobSeekerHomeState extends State<JobSeekerHome> {
  int _currentIndex = 0;

  List<Job> _recommendedJobs = [];
  List<Job> _recentJobs = [];
  int _totalJobs = 0;
  int _savedCount = 0;
  int _unreadNotifications = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadUnreadCount();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final jobsResult = await JobService.fetchJobs(limit: 50);
    final savedResult = await SavedJobService.fetchSavedJobs();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (jobsResult.success) {
        _totalJobs = jobsResult.total;
        _recommendedJobs = jobsResult.jobs.take(2).toList();
        _recentJobs = jobsResult.jobs.skip(2).take(2).toList();
      } else {
        _error = jobsResult.message ?? 'Failed to load jobs';
      }
      if (savedResult.success) {
        _savedCount = savedResult.jobs.length;
      }
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.fetchUnreadCount();
    if (!mounted) return;
    setState(() => _unreadNotifications = count);
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
    if (!mounted) return;
    await _loadUnreadCount();
  }

  void _openJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: job.id),
      ),
    ).then((_) => _loadJobs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 1) {
      // Explore Tab
      return SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Find jobs by category', style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _categoryCard(context, 'Design', Icons.design_services, Colors.purple),
                    _categoryCard(context, 'Engineering', Icons.code, Colors.blue),
                    _categoryCard(context, 'Marketing', Icons.campaign, Colors.orange),
                    _categoryCard(context, 'Finance', Icons.attach_money, Colors.green),
                    _categoryCard(context, 'Sales', Icons.trending_up, Colors.red),
                    _categoryCard(context, 'Support', Icons.headset_mic, Colors.teal),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentIndex == 2) {
      return SafeArea(bottom: false, child: const SavedJobsTab());
    }
    if (_currentIndex == 3) {
      return SafeArea(bottom: false, child: const MyApplicationsTab());
    }
    
    // Home Tab (Index 0)
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildScrollBody()),
        ],
      ),
    );
  }

  Widget _categoryCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/job-search');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollBody() {
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

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStats(),
            const SizedBox(height: 24),
            SectionHeader(title: 'Recommended Jobs', onSeeAll: () {}),
            const SizedBox(height: 12),
            if (_recommendedJobs.isEmpty)
              _emptyJobsPlaceholder()
            else
              ..._recommendedJobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppJobCard(
                    job: job,
                    onTap: () => _openJobDetails(job),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SectionHeader(title: 'Recent Jobs', onSeeAll: () {}),
            const SizedBox(height: 12),
            if (_recentJobs.isEmpty)
              _emptyJobsPlaceholder()
            else
              ..._recentJobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppJobCard(
                    job: job,
                    onTap: () => _openJobDetails(job),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 12),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _emptyJobsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text('No jobs posted yet', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'New openings will appear here.',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Michael',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your next opportunity',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openNotifications,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _unreadNotifications > 99
                                ? '99+'
                                : '$_unreadNotifications',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppSearchBar(
            hint: 'Search jobs, skills, or companies...',
            onTap: () => Navigator.pushNamed(context, '/job-search'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: AppStatCard(
            icon: Icons.work_outline,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primary.withValues(alpha: 0.12),
            label: 'Total Jobs',
            value: '$_totalJobs',
            trend: '12%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.bookmark_border,
            iconColor: AppColors.success,
            iconBackground: AppColors.success.withValues(alpha: 0.12),
            label: 'Saved Jobs',
            value: '$_savedCount',
            trend: '8%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBackground: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            label: 'Applications',
            value: '0',
            trend: '0%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.favorite_border,
            iconColor: AppColors.danger,
            iconBackground: AppColors.danger.withValues(alpha: 0.12),
            label: 'Interviews',
            value: '0',
            trend: '0%',
            trendUp: false,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        icon: Icons.search,
        label: 'Search Jobs',
        onTap: () => Navigator.pushNamed(context, '/job-search'),
      ),
      (
        icon: Icons.bookmark_border,
        label: 'Saved',
        onTap: () => setState(() => _currentIndex = 2),
      ),
      (
        icon: Icons.description_outlined,
        label: 'Applications',
        onTap: () => setState(() => _currentIndex = 3),
      ),
      (
        icon: Icons.person_outline,
        label: 'Profile',
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: action.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        action.icon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 4) {
          Navigator.pushNamed(context, '/profile');
          return;
        }
        setState(() => _currentIndex = index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}