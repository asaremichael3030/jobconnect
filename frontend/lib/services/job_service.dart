import '../models/job.dart';
import '../models/job_posting.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class JobResult {
  final bool success;
  final String? message;
  final JobPosting? job;

  JobResult({required this.success, this.message, this.job});
}

class JobsListResult {
  final bool success;
  final String? message;
  final List<JobPosting> jobs;

  JobsListResult({
    required this.success,
    this.message,
    this.jobs = const [],
  });
}

class JobListResult {
  final bool success;
  final String? message;
  final List<Job> jobs;
  final int total;

  JobListResult({
    required this.success,
    this.message,
    this.jobs = const [],
    this.total = 0,
  });
}

class JobDetailResult {
  final bool success;
  final String? message;
  final Job? job;
  final Map<String, dynamic>? company;
  final bool hasApplied;
  final bool hasSaved;

  JobDetailResult({
    required this.success,
    this.message,
    this.job,
    this.company,
    this.hasApplied = false,
    this.hasSaved = false,
  });
}

class JobService {
  JobService._();

  static Future<JobResult> createJob(Map<String, dynamic> fields) async {
    final token = await AuthService.readToken();
    if (token == null) {
      return JobResult(success: false, message: 'You are not signed in');
    }

    final response = await ApiService.post(
      ApiConstants.jobs,
      fields,
      token: token,
    );

    if (!response.success) {
      return JobResult(
        success: false,
        message: response.message ?? 'Failed to create job',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final jobJson = data['job'] as Map<String, dynamic>;
    return JobResult(success: true, job: JobPosting.fromJson(jobJson));
  }

  static Future<JobsListResult> fetchMyJobs() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return JobsListResult(success: false, message: 'You are not signed in');
    }

    final response = await ApiService.get(ApiConstants.jobsMe, token: token);

    if (!response.success) {
      return JobsListResult(
        success: false,
        message: response.message ?? 'Failed to load jobs',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final jobsJson = data['jobs'] as List<dynamic>? ?? [];
    final jobs = jobsJson
        .map((j) => JobPosting.fromJson(j as Map<String, dynamic>))
        .toList();

    return JobsListResult(success: true, jobs: jobs);
  }

  static Future<JobListResult> fetchJobs({
    String? search,
    String? location,
    String? workingModel,
    String? jobType,
    String? experienceLevel,
    int? salaryMin,
    int? salaryMax,
    String? company,
    String? postedAfter,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) query['q'] = search;
    if (location != null && location.isNotEmpty) query['location'] = location;
    if (workingModel != null && workingModel.isNotEmpty) {
      query['workingModel'] = workingModel;
    }
    if (jobType != null && jobType.isNotEmpty) query['jobType'] = jobType;
    if (experienceLevel != null && experienceLevel.isNotEmpty) {
      query['experienceLevel'] = experienceLevel;
    }
    if (salaryMin != null) query['salaryMin'] = salaryMin.toString();
    if (salaryMax != null) query['salaryMax'] = salaryMax.toString();
    if (company != null && company.isNotEmpty) query['company'] = company;
    if (postedAfter != null && postedAfter.isNotEmpty) {
      query['postedAfter'] = postedAfter;
    }
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;

    final queryString = query.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final path = '${ApiConstants.jobs}?$queryString';
    final response = await ApiService.get(path);

    if (!response.success) {
      return JobListResult(
        success: false,
        message: response.message ?? 'Failed to load jobs',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final jobsJson = data['jobs'] as List<dynamic>? ?? [];

    return JobListResult(
      success: true,
      jobs: jobsJson
          .map((j) => Job.fromJson(j as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? jobsJson.length,
    );
  }

  static Future<JobDetailResult> fetchJobById(int id) async {
    final token = await AuthService.readToken();
    final response = await ApiService.get(
      '${ApiConstants.jobs}/$id',
      token: token,
    );

    if (!response.success) {
      return JobDetailResult(
        success: false,
        message: response.message ?? 'Failed to load job',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final jobJson = data['job'] as Map<String, dynamic>;

    return JobDetailResult(
      success: true,
      job: Job.fromJson(jobJson),
      company: jobJson['company'] as Map<String, dynamic>?,
      hasApplied: jobJson['hasApplied'] as bool? ?? false,
      hasSaved: jobJson['hasSaved'] as bool? ?? false,
    );
  }
}