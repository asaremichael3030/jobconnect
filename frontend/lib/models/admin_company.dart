import 'package:flutter/material.dart';

class AdminCompany {
  final int id;
  final String name;
  final String industry;
  final String verificationStatus;
  final int openJobs;
  final Color iconColor;
  final String ownerEmail;

  const AdminCompany({
    required this.id,
    required this.name,
    required this.industry,
    required this.verificationStatus,
    this.openJobs = 0,
    required this.iconColor,
    this.ownerEmail = '',
  });

  factory AdminCompany.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final palette = [
      const Color(0xFF1B3CC9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    final color = palette[name.length % palette.length];

    return AdminCompany(
      id: json['id'] as int? ?? 0,
      name: name,
      industry: json['industry'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
      iconColor: color,
      ownerEmail: json['ownerEmail'] as String? ?? '',
    );
  }

  String get initial => name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
  bool get verified => verificationStatus == 'VERIFIED';
}