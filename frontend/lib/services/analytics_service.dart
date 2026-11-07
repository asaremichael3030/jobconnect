import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PopularSearch {
  final String query;
  final int count;

  PopularSearch({required this.query, required this.count});

  factory PopularSearch.fromJson(Map<String, dynamic> json) {
    return PopularSearch(
      query: json['query'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class SearchStats {
  final int totalSearches;
  final int averageLatency;
  final double cacheHitRate;
  final List<PopularSearch> popularSearches;

  SearchStats({
    required this.totalSearches,
    required this.averageLatency,
    required this.cacheHitRate,
    required this.popularSearches,
  });

  factory SearchStats.fromJson(Map<String, dynamic> json) {
    final popularRaw = json['popularSearches'] as List<dynamic>? ?? [];
    return SearchStats(
      totalSearches: json['totalSearches'] as int? ?? 0,
      averageLatency: json['averageLatency'] as int? ?? 0,
      cacheHitRate: (json['cacheHitRate'] as num?)?.toDouble() ?? 0.0,
      popularSearches: popularRaw
          .map((p) => PopularSearch.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AnalyticsResult {
  final bool success;
  final String? message;
  final SearchStats? stats;

  AnalyticsResult({required this.success, this.message, this.stats});
}

class AnalyticsService {
  AnalyticsService._();

  static Future<AnalyticsResult> fetchSearchStats() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return AnalyticsResult(success: false, message: 'Not signed in');
    }

    final response = await ApiService.get(ApiConstants.searchAnalytics, token: token);

    if (!response.success) {
      return AnalyticsResult(
        success: false,
        message: response.message ?? 'Failed to load analytics',
      );
    }

    final data = response.data as Map<String, dynamic>;
    return AnalyticsResult(
      success: true,
      stats: SearchStats.fromJson(data),
    );
  }
}