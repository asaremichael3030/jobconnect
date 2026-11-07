import '../models/job.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SavedJobResult {
  final bool success;
  final String? message;
  final bool saved;

  SavedJobResult({
    required this.success,
    this.message,
    this.saved = false,
  });
}

class SavedJobsListResult {
  final bool success;
  final String? message;
  final List<Job> jobs;

  SavedJobsListResult({
    required this.success,
    this.message,
    this.jobs = const [],
  });
}

class SavedJobService {
  SavedJobService._();

  static Future<SavedJobResult> save(int jobId) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return SavedJobResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.post(
      '${ApiConstants.jobs}/$jobId/save',
      {},
      token: token,
    );

    if (!response.success) {
      return SavedJobResult(
        success: false,
        message: response.message ?? 'Failed to save job',
      );
    }

    return SavedJobResult(success: true, saved: true);
  }

  static Future<SavedJobResult> unsave(int jobId) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return SavedJobResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.delete(
      '${ApiConstants.jobs}/$jobId/save',
      token: token,
    );

    if (!response.success) {
      return SavedJobResult(
        success: false,
        message: response.message ?? 'Failed to unsave job',
      );
    }

    return SavedJobResult(success: true, saved: false);
  }

  static Future<SavedJobsListResult> fetchSavedJobs() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return SavedJobsListResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(
      ApiConstants.savedJobs,
      token: token,
    );

    if (!response.success) {
      return SavedJobsListResult(
        success: false,
        message: response.message ?? 'Failed to load saved jobs',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final list = data['savedJobs'] as List<dynamic>? ?? [];

    return SavedJobsListResult(
      success: true,
      jobs: list
          .map((s) => Job.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}