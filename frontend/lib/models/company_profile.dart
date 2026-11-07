import '../utils/constants.dart';

class CompanyJob {
  final int id;
  final String title;
  final String workingModel;
  final String jobType;
  final int applicants;
  final bool active;

  const CompanyJob({
    required this.id,
    required this.title,
    required this.workingModel,
    required this.jobType,
    required this.applicants,
    this.active = true,
  });
}

class CompanyProfile {
  final int id;
  final String name;
  final String industry;
  final String companySize;
  final String location;
  final String about;
  final String website;
  final String email;
  final String? linkedin;
  final String? twitter;
  final String? logoUrl;
  final String verificationStatus;
  final int foundedYear;
  final int openJobs;
  final int totalHires;
  final List<String> specialties;
  final List<CompanyJob> jobs;

  const CompanyProfile({
    required this.id,
    required this.name,
    required this.industry,
    required this.companySize,
    required this.location,
    required this.about,
    required this.website,
    required this.email,
    this.linkedin,
    this.twitter,
    this.logoUrl,
    this.verificationStatus = 'PENDING',
    required this.foundedYear,
    this.openJobs = 0,
    this.totalHires = 0,
    this.specialties = const [],
    this.jobs = const [],
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    final rawLogoUrl = json['logoUrl'] as String?;
    final logoUrl = (rawLogoUrl != null && rawLogoUrl.isNotEmpty)
        ? '${ApiConstants.baseUrl}$rawLogoUrl'
        : null;

    return CompanyProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      companySize: json['companySize'] as String? ?? '',
      location: json['location'] as String? ?? '',
      about: json['about'] as String? ?? '',
      website: json['website'] as String? ?? '',
      email: json['email'] as String? ?? '',
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
      logoUrl: logoUrl,
      verificationStatus: json['verificationStatus'] as String? ?? 'PENDING',
      foundedYear: json['foundedYear'] as int? ?? 0,
      openJobs: json['openJobs'] as int? ?? 0,
      totalHires: json['totalHires'] as int? ?? 0,
      specialties: const [],
      jobs: const [],
    );
  }

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  bool get isVerified => verificationStatus == 'VERIFIED';
}