import '../models/admin_company.dart';
import '../models/admin_user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AdminStats {
  final int totalUsers;
  final int totalCompanies;
  final int totalJobs;
  final int totalApplications;
  final int pendingReports;

  AdminStats({
    required this.totalUsers,
    required this.totalCompanies,
    required this.totalJobs,
    required this.totalApplications,
    required this.pendingReports,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalCompanies: json['totalCompanies'] as int? ?? 0,
      totalJobs: json['totalJobs'] as int? ?? 0,
      totalApplications: json['totalApplications'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
    );
  }
}

class AdminService {
  AdminService._();

  static Future<AdminStats?> fetchStats() async {
    final token = await AuthService.readToken();
    if (token == null) return null;

    final response = await ApiService.get('${ApiConstants.admin}/stats', token: token);
    if (!response.success) return null;

    return AdminStats.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<AdminUser>> fetchUsers() async {
    final token = await AuthService.readToken();
    if (token == null) return [];

    final response = await ApiService.get('${ApiConstants.admin}/users', token: token);
    if (!response.success) return [];

    final list = (response.data as Map<String, dynamic>)['users'] as List<dynamic>? ?? [];
    return list.map((u) => AdminUser.fromJson(u as Map<String, dynamic>)).toList();
  }

  static Future<bool> updateUserStatus(int userId, String status) async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.patch(
      '${ApiConstants.admin}/users/$userId/status',
      {'status': status},
      token: token,
    );
    return response.success;
  }

  static Future<List<AdminCompany>> fetchCompanies() async {
    final token = await AuthService.readToken();
    if (token == null) return [];

    final response = await ApiService.get('${ApiConstants.admin}/companies', token: token);
    if (!response.success) return [];

    final list = (response.data as Map<String, dynamic>)['companies'] as List<dynamic>? ?? [];
    return list.map((c) => AdminCompany.fromJson(c as Map<String, dynamic>)).toList();
  }

  static Future<bool> updateCompanyVerification(int companyId, String status) async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.patch(
      '${ApiConstants.admin}/companies/$companyId/verify',
      {'status': status},
      token: token,
    );
    return response.success;
  }
}