import '../models/report.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ReportService {
  ReportService._();

  static Future<bool> submitReport({
    required String targetType,
    required int targetId,
    required String reason,
  }) async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.post(
      ApiConstants.reports,
      {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
      },
      token: token,
    );
    return response.success;
  }

  static Future<List<Report>> fetchReports() async {
    final token = await AuthService.readToken();
    if (token == null) return [];

    final response = await ApiService.get(ApiConstants.adminReports, token: token);
    if (!response.success) return [];

    final list = (response.data as Map<String, dynamic>)['reports'] as List<dynamic>? ?? [];
    return list.map((r) => Report.fromJson(r as Map<String, dynamic>)).toList();
  }

  static Future<bool> updateStatus(int reportId, String status) async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.patch(
      '${ApiConstants.adminReports}/$reportId/status',
      {'status': status},
      token: token,
    );
    return response.success;
  }
}