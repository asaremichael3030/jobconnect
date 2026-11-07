class ApiConstants {
  ApiConstants._();

  // Android emulator uses 10.0.2.2 instead of localhost.
  // iOS simulator, Chrome, and desktop all use localhost.
  // On a physical device, replace with your computer's LAN IP.
  static const String baseUrl = 'http://localhost:5000';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  // Users
  static const String userMe = '/api/users/me';

  // Companies
  static const String companyMe = '/api/companies/me';

  // Jobs
  static const String jobs = '/api/jobs';
  static const String jobsMe = '/api/jobs/me';

  // Applications
  static const String applications = '/api/applications';
  static const String applicationsMe = '/api/applications/me';

  // Saved jobs
  static const String savedJobs = '/api/saved-jobs';

  // Notifications
  static const String notifications = '/api/notifications';

  // Analytics
  static const String searchAnalytics = '/api/analytics/searches';

    // Admin
  static const String admin = '/api/admin';

    // Reports
  static const String reports = '/api/reports';
  static const String adminReports = '/api/admin/reports';
}
