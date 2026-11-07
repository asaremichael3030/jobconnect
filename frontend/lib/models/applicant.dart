import 'package:flutter/material.dart';

class Applicant {
  final int id;
  final String name;
  final String positionApplied;
  final String experience;
  final String appliedAt;
  final Color avatarColor;

  const Applicant({
    required this.id,
    required this.name,
    required this.positionApplied,
    required this.experience,
    required this.appliedAt,
    required this.avatarColor,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}