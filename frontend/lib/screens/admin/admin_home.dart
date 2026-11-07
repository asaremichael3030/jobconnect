import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_stat_card.dart';
import '../notifications/notifications_screen.dart';
import 'admin_companies_tab.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_tab.dart';
import 'admin_users_tab.dart';
import 'search_analytics_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;
  int _unreadNotifications = 0;

  AdminStats? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await AdminService.fetchStats();
    final unread = await NotificationService.fetchUnreadCount();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _unreadNotifications = unread;
      _loadingStats = false;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    await _loadData();
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
    if (_currentIndex == 1) return const SafeArea(bottom: false, child: AdminUsersTab());
    if (_currentIndex == 2) return const SafeArea(bottom: false, child: AdminCompaniesTab());
    if (_currentIndex == 3) return const SafeArea(bottom: false, child: SearchAnalyticsTab());
    if (_currentIndex == 4) return const AdminSettingsTab();
    if (_currentIndex != 0) return _placeholderScreen();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(),
                    const SizedBox(height: 24),
                    Text('Platform Overview', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _buildOverviewCard(),
                    const SizedBox(height: 20),
                    Text('Pending Reports', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _buildReportsBanner(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final s = _stats ?? AdminStats(totalUsers: 0, totalCompanies: 0, totalJobs: 0, totalApplications: 0, pendingReports: 0);

    return SizedBox(
      height: 130, // Slightly taller to prevent overflow
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 120, child: AppStatCard(
            icon: Icons.people_outline,
            iconColor: AppColors.primary,
            iconBackground: const Color(0x1F1B3CC9),
            label: 'Total Users',
            value: '${s.totalUsers}',
            trend: '0%', trendUp: true,
          )),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: AppStatCard(
            icon: Icons.business_outlined,
            iconColor: const Color(0xFF10B981),
            iconBackground: const Color(0x1F10B981),
            label: 'Companies',
            value: '${s.totalCompanies}',
            trend: '0%', trendUp: true,
          )),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: AppStatCard(
            icon: Icons.work_outline,
            iconColor: const Color(0xFF8B5CF6),
            iconBackground: const Color(0x1F8B5CF6),
            label: 'Total Jobs',
            value: '${s.totalJobs}',
            trend: '0%', trendUp: true,
          )),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: AppStatCard(
            icon: Icons.description_outlined,
            iconColor: AppColors.accent,
            iconBackground: const Color(0x1FF7B733),
            label: 'Applications',
            value: '${s.totalApplications}',
            trend: '0%', trendUp: true,
          )),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: AppStatCard(
            icon: Icons.flag_outlined,
            iconColor: AppColors.danger,
            iconBackground: const Color(0x1FEF4444),
            label: 'Reports',
            value: '${s.pendingReports}',
            trend: '0%', trendUp: false,
          )),
          const SizedBox(width: 8),
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
                    Text('Hello, Admin', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Manage users, companies and platform activity',
                        style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openNotifications,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 2, top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(999)),
                          alignment: Alignment.center,
                          child: Text(_unreadNotifications > 99 ? '99+' : '$_unreadNotifications',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      )
                    else
                      Positioned(
                        right: 6, top: 6,
                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
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

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _overviewRow('Total Users', '${_stats?.totalUsers ?? 0}'),
          const Divider(height: 20),
          _overviewRow('Total Companies', '${_stats?.totalCompanies ?? 0}'),
          const Divider(height: 20),
          _overviewRow('Total Jobs', '${_stats?.totalJobs ?? 0}'),
          const Divider(height: 20),
          _overviewRow('Total Applications', '${_stats?.totalApplications ?? 0}'),
        ],
      ),
    );
  }

  Widget _overviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 14)),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _buildReportsBanner() {
    final pending = _stats?.pendingReports ?? 0;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
        );
        if (!mounted) return;
        await _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.flag_outlined, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$pending reports pending review', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Tap to review user and content reports', style: AppTextStyles.small.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.danger, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _placeholderScreen() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Settings', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text('Coming in a later phase', style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business), label: 'Companies'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}