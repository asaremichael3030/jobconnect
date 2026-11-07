import 'package:flutter/material.dart';

import 'screens/admin/admin_home.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/employer/employer_home.dart';
import 'screens/job_seeker/job_seeker_home.dart';
import 'screens/jobs/job_search_screen.dart';
import 'screens/profile/company_profile_screen.dart';
import 'screens/profile/seeker_profile_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';
import 'screens/employer/create_job_screen.dart';
import 'screens/notifications/notifications_screen.dart';

void main() {
  runApp(const JobConnectApp());
}

class JobConnectApp extends StatelessWidget {
  const JobConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/job-seeker/home': (context) => const JobSeekerHome(),
        '/employer/home': (context) => const EmployerHome(),
        '/admin/home': (context) => const AdminHome(),
        '/job-search': (context) => const JobSearchScreen(),
        '/profile': (context) => const SeekerProfileScreen(),
        '/company-profile': (context) => const CompanyProfileScreen(),
        '/create-job': (context) => const CreateJobScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final hasSession = await AuthService.hasSession();

    if (!hasSession) {
      _goTo('/login');
      return;
    }

    final restored = await AuthService.restoreSession();

    if (!restored.success) {
      _goTo('/login');
      return;
    }

    _routeByRole(restored.role);
  }

  void _routeByRole(String? role) {
    switch (role) {
      case 'JOB_SEEKER':
        _goTo('/job-seeker/home');
        break;
      case 'EMPLOYER':
        _goTo('/employer/home');
        break;
      case 'ADMIN':
        _goTo('/admin/home');
        break;
      default:
        _goTo('/login');
    }
  }

  void _goTo(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_outline,
              size: 72,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'JobConnect',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}