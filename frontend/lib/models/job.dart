import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Job {
  final int id;
  final int companyId;
  final String title;
  final String companyName;
  final String companyInitial;
  final Color companyColor;
  final String? companyLogoUrl;
  final String location;
  final String jobType;
  final String workingModel;
  final String experienceLevel;
  final int applicants;
  final String salary;
  final String description;
  final String requirements;
  final String responsibilities;
  final DateTime? applicationDeadline;
  final String status;
  final int? matchScore; // <-- THIS IS THE NEW FIELD

  const Job({
    required this.id,
    this.companyId = 0,
    required this.title,
    required this.companyName,
    required this.companyInitial,
    required this.companyColor,
    this.companyLogoUrl,
    required this.location,
    required this.jobType,
    required this.workingModel,
    required this.experienceLevel,
    required this.applicants,
    required this.salary,
    this.description = '',
    this.requirements = '',
    this.responsibilities = '',
    this.applicationDeadline,
    this.status = 'ACTIVE',
    this.matchScore,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    final companyName = json['companyName'] as String? ?? '';
    final companyId = json['companyId'] as int? ?? 0;
    final rawLogo = json['companyLogoUrl'] as String?;

    final salaryMin = json['salaryMin'] as int?;
    final salaryMax = json['salaryMax'] as int?;
    final currency = (json['salaryCurrency'] as String? ?? 'USD');
    final symbol = currency == 'USD' ? '\$' : '$currency ';

    String salaryDisplay;
    if (salaryMin != null && salaryMax != null) {
      salaryDisplay =
          '$symbol${_compact(salaryMin)} - $symbol${_compact(salaryMax)} /month';
    } else if (salaryMin != null) {
      salaryDisplay = 'From $symbol${_compact(salaryMin)} /month';
    } else if (salaryMax != null) {
      salaryDisplay = 'Up to $symbol${_compact(salaryMax)} /month';
    } else {
      salaryDisplay = 'Salary not specified';
    }

    final deadlineRaw = json['applicationDeadline'] as String?;

    return Job(
      id: json['id'] as int? ?? 0,
      companyId: companyId,
      title: json['title'] as String? ?? '',
      companyName: companyName,
      companyInitial: companyName.isEmpty
          ? '?'
          : companyName.trim().substring(0, 1).toUpperCase(),
      companyColor: _colorForCompany(companyId),
      companyLogoUrl: (rawLogo != null && rawLogo.isNotEmpty)
          ? '${ApiConstants.baseUrl}$rawLogo'
          : null,
      location: json['location'] as String? ?? '',
      jobType: json['jobType'] as String? ?? '',
      workingModel: json['workingModel'] as String? ?? '',
      experienceLevel: json['experienceLevel'] as String? ?? '',
      applicants: json['applicantCount'] as int? ?? 0,
      salary: salaryDisplay,
      description: json['description'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      responsibilities: json['responsibilities'] as String? ?? '',
      applicationDeadline: deadlineRaw != null && deadlineRaw.isNotEmpty
          ? DateTime.tryParse(deadlineRaw)
          : null,
      status: json['status'] as String? ?? 'ACTIVE',
      matchScore: json['matchScore'] as int?, // <-- THIS READS IT
    );
  }

  static String _compact(int value) {
    if (value >= 1000) {
      return '${(value / 1000).round()}k';
    }
    return '$value';
  }

  static Color _colorForCompany(int companyId) {
    const palette = [
      Color(0xFF1B3CC9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF0EA5E9),
    ];
    if (companyId <= 0) return palette[0];
    return palette[companyId % palette.length];
  }
}