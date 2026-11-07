import 'package:flutter/material.dart';

class AdminUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String joinedAt;
  final Color avatarColor;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.avatarColor,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] as String?;
    final date = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final name = json['name'] as String? ?? '';

    // Simple colour picker based on name length
    final palette = [
      const Color(0xFF1B3CC9),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];
    final color = palette[name.length % palette.length];

    String displayDate = 'Unknown';
    if (date != null) {
      displayDate = '${date.day}/${date.month}/${date.year}';
    }

    return AdminUser(
      id: json['id'] as int? ?? 0,
      name: name,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'JOB_SEEKER',
      status: json['status'] as String? ?? 'ACTIVE',
      joinedAt: displayDate,
      avatarColor: color,
    );
  }

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}