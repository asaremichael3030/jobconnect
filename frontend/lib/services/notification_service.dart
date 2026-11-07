import '../models/notification.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificationsResult {
  final bool success;
  final String? message;
  final List<AppNotification> notifications;
  final int unreadCount;

  NotificationsResult({
    required this.success,
    this.message,
    this.notifications = const [],
    this.unreadCount = 0,
  });
}

class NotificationService {
  NotificationService._();

  static Future<NotificationsResult> fetchNotifications() async {
    final token = await AuthService.readToken();
    if (token == null) {
      return NotificationsResult(
        success: false,
        message: 'You are not signed in',
      );
    }

    final response = await ApiService.get(
      ApiConstants.notifications,
      token: token,
    );

    if (!response.success) {
      return NotificationsResult(
        success: false,
        message: response.message ?? 'Failed to load notifications',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final list = data['notifications'] as List<dynamic>? ?? [];
    final unread = data['unreadCount'] as int? ?? 0;

    return NotificationsResult(
      success: true,
      notifications: list
          .map((n) =>
              AppNotification.fromJson(n as Map<String, dynamic>))
          .toList(),
      unreadCount: unread,
    );
  }

  static Future<int> fetchUnreadCount() async {
    final token = await AuthService.readToken();
    if (token == null) return 0;

    final response = await ApiService.get(
      '${ApiConstants.notifications}/unread-count',
      token: token,
    );

    if (!response.success) return 0;

    final data = response.data as Map<String, dynamic>;
    return data['unreadCount'] as int? ?? 0;
  }

  static Future<bool> markRead(int notificationId) async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.patch(
      '${ApiConstants.notifications}/$notificationId/read',
      {},
      token: token,
    );
    return response.success;
  }

  static Future<bool> markAllRead() async {
    final token = await AuthService.readToken();
    if (token == null) return false;

    final response = await ApiService.patch(
      '${ApiConstants.notifications}/read-all',
      {},
      token: token,
    );
    return response.success;
  }
}