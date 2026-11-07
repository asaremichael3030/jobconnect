import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Application {
  final int id;
  final int jobId;
  final String status;
  final DateTime? appliedAt;

  // Seeker view fields
  final String jobTitle;
  final String jobType;
  final String workingModel;
  final String location;
  final int companyId;
  final String companyName;
  final String? companyLogoUrl;

  // Employer view fields
  final int userId;
  final String applicantName;
  final String applicantEmail;
  final String? applicantAvatarUrl;
  final String applicantHeadline;
  final String applicantLocation;
  final String coverLetter;
  final String? resumeUrl; // <-- Added this

  const Application({
    required this.id,
    required this.jobId,
    required this.status,
    this.appliedAt,
    this.jobTitle = '',
    this.jobType = '',
    this.workingModel = '',
    this.location = '',
    this.companyId = 0,
    this.companyName = '',
    this.companyLogoUrl,
    this.userId = 0,
    this.applicantName = '',
    this.applicantEmail = '',
    this.applicantAvatarUrl,
    this.applicantHeadline = '',
    this.applicantLocation = '',
    this.coverLetter = '',
    this.resumeUrl, // <-- Added this
  });

  factory Application.fromSeekerJson(Map<String, dynamic> json) {
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final rawLogo = job['companyLogoUrl'] as String?;
    final appliedRaw = json['appliedAt'] as String?;

    return Application(
      id: json['id'] as int? ?? 0,
      jobId: json['jobId'] as int? ?? 0,
      status: json['status'] as String? ?? 'APPLIED',
      appliedAt: appliedRaw != null ? DateTime.tryParse(appliedRaw) : null,
      jobTitle: job['title'] as String? ?? '',
      jobType: job['jobType'] as String? ?? '',
      workingModel: job['workingModel'] as String? ?? '',
      location: job['location'] as String? ?? '',
      companyId: job['companyId'] as int? ?? 0,
      companyName: job['companyName'] as String? ?? '',
      companyLogoUrl: (rawLogo != null && rawLogo.isNotEmpty)
          ? '${ApiConstants.baseUrl}$rawLogo'
          : null,
    );
  }

  factory Application.fromEmployerJson(Map<String, dynamic> json) {
    final applicant = json['applicant'] as Map<String, dynamic>? ?? {};
    final rawAvatar = applicant['avatarUrl'] as String?;
    final appliedRaw = json['appliedAt'] as String?;
    final rawResume = json['resumeUrl'] as String?;

    return Application(
      id: json['id'] as int? ?? 0,
      jobId: json['jobId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      status: json['status'] as String? ?? 'APPLIED',
      appliedAt: appliedRaw != null ? DateTime.tryParse(appliedRaw) : null,
      applicantName: applicant['name'] as String? ?? '',
      applicantEmail: applicant['email'] as String? ?? '',
      applicantAvatarUrl: (rawAvatar != null && rawAvatar.isNotEmpty)
          ? '${ApiConstants.baseUrl}$rawAvatar'
          : null,
      applicantHeadline: applicant['headline'] as String? ?? '',
      applicantLocation: applicant['location'] as String? ?? '',
      coverLetter: json['coverLetter'] as String? ?? '',
      resumeUrl: (rawResume != null && rawResume.isNotEmpty)
          ? '${ApiConstants.baseUrl}$rawResume'
          : null, // <-- Added this
    );
  }

  String get initials {
    final name = applicantName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Color statusColor() {
    switch (status) {
      case 'APPLIED':
        return const Color(0xFF1B3CC9);
      case 'REVIEWING':
        return const Color(0xFFF59E0B);
      case 'SHORTLISTED':
        return const Color(0xFF8B5CF6);
      case 'INTERVIEW':
        return const Color(0xFF0EA5E9);
      case 'HIRED':
        return const Color(0xFF22C55E);
      case 'REJECTED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String statusLabel() {
    switch (status) {
      case 'APPLIED':
        return 'Applied';
      case 'REVIEWING':
        return 'Reviewing';
      case 'SHORTLISTED':
        return 'Shortlisted';
      case 'INTERVIEW':
        return 'Interview';
      case 'HIRED':
        return 'Hired';
      case 'REJECTED':
        return 'Not selected';
      default:
        return status;
    }
  }
}