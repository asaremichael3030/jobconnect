import 'package:flutter/material.dart';

import '../../models/job_posting.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_stat_card.dart';
import '../../widgets/job_posting_card.dart';
import '../../widgets/section_header.dart';
import '../notifications/notifications_screen.dart';
import 'job_applicants_screen.dart';

class EmployerHome extends StatefulWidget {
  const EmployerHome({super.key});

  @override
  State<EmployerHome> createState() => _EmployerHomeState();
}

class _EmployerHomeState extends State<EmployerHome> {
  int _currentIndex = 0;

  List<JobPosting> _myPostings = [];
  int _unreadNotifications = 0;
  bool _loadingJobs = true;
  String? _jobsError;

  @override
  void initState() {
    super.initState();
    _loadMyJobs();
    _loadUnreadCount();
  }

  Future<void> _loadMyJobs() async {
    setState(() {
      _loadingJobs = true;
      _jobsError = null;
    });

    final result = await JobService.fetchMyJobs();

    if (!mounted) return;
    setState(() {
      _loadingJobs = false;
      if (result.success) {
        _myPostings = result.jobs;
      } else {
        _jobsError = result.message ?? 'Failed to load jobs';
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

  Future<void> _openCreateJob() async {
    final created = await Navigator.pushNamed(context, '/create-job');
    if (created == true) {
      await _loadMyJobs();
    }
  }

  Future<void> _openJobApplicants(JobPosting posting) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobApplicantsScreen(
          jobId: posting.id,
          jobTitle: posting.title,
        ),
      ),
    );
    if (!mounted) return;
    await _loadMyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: _openCreateJob,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Post a Job'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 1) {
      // Jobs Tab
      return SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMyJobs,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'My Job Postings', onSeeAll: () {}),
                      const SizedBox(height: 12),
                      _buildJobPostings(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_currentIndex == 2) {
      // Applicants Tab
      return SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMyJobs,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select a job to view its applicants', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      _buildJobPostings(), // Renders the clickable list
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentIndex == 3) {
      // Analytics Tab
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hiring Analytics', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text('Overview of your recruitment activity', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
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
                    _analyticsRow(
                      Icons.work_outline,
                      'Active Job Postings',
                      '${_myPostings.length}',
                      AppColors.primary,
                    ),
                    const Divider(height: 24),
                    _analyticsRow(
                      Icons.people_outline,
                      'Total Applicants',
                      '0', // Will be dynamic in a future update
                      AppColors.success,
                    ),
                    const Divider(height: 24),
                    _analyticsRow(
                      Icons.check_circle_outline,
                      'Positions Filled',
                      '0',
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentIndex == 4) {
      // Settings / Logout Tab
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text('Employer Account', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Manage your company and job postings.',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/company-profile');
                    if (!mounted) return;
                    await _loadMyJobs(); // Refresh dashboard if company was created
                  },
                  icon: const Icon(Icons.domain),
                  label: const Text('My Company Profile'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    // Dashboard Tab (Index 0)
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMyJobs,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(),
                    const SizedBox(height: 24),
                    SectionHeader(title: 'My Job Postings', onSeeAll: () => setState(() => _currentIndex = 1)),
                    const SizedBox(height: 12),
                    _buildJobPostings(),
                    const SizedBox(height: 14),
                    SectionHeader(title: 'Recent Applicants', onSeeAll: () => setState(() => _currentIndex = 2)),
                    const SizedBox(height: 12),
                    _buildApplicantsCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ),
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
      ],
    );
  }

  Widget _buildJobPostings() {
    if (_loadingJobs) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_jobsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.danger,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(_jobsError!, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadMyJobs,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_myPostings.isEmpty) {
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
            Text('No job postings yet', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Tap "Post a Job" to publish your first opening.',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _myPostings
          .map(
            (posting) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: JobPostingCard(
                posting: posting,
                onTap: () => _openJobApplicants(posting),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildApplicantsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Icon(
            Icons.people_outline,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text('View applicants per job', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Tap any job posting to review its applicants.',
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
                      'Hello, TechCorp Ltd.',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your job postings and find the best talent',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
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
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
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
            value: '${_myPostings.length}',
            trend: '0%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.people_outline,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primary.withValues(alpha: 0.12),
            label: 'Applicants',
            value: '0',
            trend: '0%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBackground: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            label: 'Viewed',
            value: '0',
            trend: '0%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppStatCard(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
            iconBackground: AppColors.success.withValues(alpha: 0.12),
            label: 'Hired',
            value: '0',
            trend: '0%',
            trendUp: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Applicants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}