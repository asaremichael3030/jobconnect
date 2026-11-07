import '../models/application.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ApplicationResult {
  final bool success;
  final String? message;
  final Application? application;

  ApplicationResult({required this.success, this.message, this.application});
}

class ApplicationsListResult {
  final bool success;
  final String? message;
  final List<Application> applications;

  ApplicationsListResult({
    required this.success,
    this.message,
    this.applications = const [],
  });
}

class ApplicationService {
  ApplicationService._();

  static Future<ApplicationResult> apply(
    int jobId, {
    String? coverLetter,
  }) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ApplicationResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final body = <String, dynamic>{};
    if (coverLetter != null && coverLetter.trim().isNotEmpty) {
      body['coverLetter'] = coverLetter.trim();
    }

    final response = await ApiService.post(
      '${ApiConstants.jobs}/$jobId/apply',
      body,
      token: token,
    );

    if (!response.success) {
      return ApplicationResult(
        success: false,
        message: response.message ?? 'Failed to submit application',
      );
    }

    return ApplicationResult(success: true);
  }

  static Future<ApplicationsListResult> fetchMyApplications() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ApplicationsListResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(
      ApiConstants.applicationsMe,
      token: token,
    );

    if (!response.success) {
      return ApplicationsListResult(
        success: false,
        message: response.message ?? 'Failed to load applications',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final list = data['applications'] as List<dynamic>? ?? [];
    return ApplicationsListResult(
      success: true,
      applications: list
          .map((a) =>
              Application.fromSeekerJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApplicationsListResult> fetchJobApplications(
    int jobId,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ApplicationsListResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(
      '${ApiConstants.jobs}/$jobId/applications',
      token: token,
    );

    if (!response.success) {
      return ApplicationsListResult(
        success: false,
        message: response.message ?? 'Failed to load applicants',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final list = data['applications'] as List<dynamic>? ?? [];
    return ApplicationsListResult(
      success: true,
      applications: list
          .map((a) =>
              Application.fromEmployerJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApplicationResult> updateStatus(
    int applicationId,
    String status,
  ) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return ApplicationResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.patch(
      '${ApiConstants.applications}/$applicationId/status',
      {'status': status},
      token: token,
    );

    if (!response.success) {
      return ApplicationResult(
        success: false,
        message: response.message ?? 'Failed to update status',
      );
    }

    return ApplicationResult(success: true);
  }
}