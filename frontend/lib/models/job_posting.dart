import 'package:flutter/material.dart';

class JobPosting {
  final int id;
  final String title;
  final String workingModel;
  final String jobType;
  final int applicantCount;
  final String status;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const JobPosting({
    required this.id,
    required this.title,
    required this.workingModel,
    required this.jobType,
    required this.applicantCount,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'ACTIVE';
    final prettyStatus = rawStatus.isEmpty
        ? 'Active'
        : rawStatus[0].toUpperCase() +
            rawStatus.substring(1).toLowerCase();

    return JobPosting(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      workingModel: json['workingModel'] as String? ?? '',
      jobType: json['jobType'] as String? ?? '',
      applicantCount: json['applicantCount'] as int? ?? 0,
      status: prettyStatus,
      icon: Icons.work_outline,
      iconColor: Colors.white,
      iconBackground: const Color(0xFF1B3CC9),
    );
  }
}