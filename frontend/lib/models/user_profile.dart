import '../utils/constants.dart';

class Experience {
  final int id;
  final String jobTitle;
  final String company;
  final String startDate;
  final String endDate;
  final String description;

  const Experience({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as int,
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class Education {
  final int id;
  final String degree;
  final String school;
  final String startYear;
  final String endYear;

  const Education({
    required this.id,
    required this.degree,
    required this.school,
    required this.startYear,
    required this.endYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as int,
      degree: json['degree'] as String? ?? '',
      school: json['school'] as String? ?? '',
      startYear: json['startYear']?.toString() ?? '',
      endYear: json['endYear']?.toString() ?? '',
    );
  }
}

class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String headline;
  final String about;
  final List<String> skills;
  final List<Experience> experience;
  final List<Education> education;
  final int yearsOfExperience;
  final String preferredJobType;
  final String preferredWorkingModel;
  final String? linkedin;
  final String? github;
  final String? portfolio;
  final String? profilePictureUrl;
  final String? resumeUrl;
  final bool hasResume;
  final int completionPercent;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.headline,
    required this.about,
    required this.skills,
    required this.experience,
    required this.education,
    required this.yearsOfExperience,
    required this.preferredJobType,
    required this.preferredWorkingModel,
    this.linkedin,
    this.github,
    this.portfolio,
    this.profilePictureUrl,
    this.resumeUrl,
    this.hasResume = false,
    this.completionPercent = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final skillsList = (json['skills'] as List<dynamic>? ?? []).cast<String>();
    final experienceList = json['experience'] as List<dynamic>? ?? [];
    final educationList = json['education'] as List<dynamic>? ?? [];

    final rawPictureUrl = profile['profilePictureUrl'] as String?;
    final pictureUrl = (rawPictureUrl != null && rawPictureUrl.isNotEmpty)
        ? '${ApiConstants.baseUrl}$rawPictureUrl'
        : null;

    final rawResumeUrl = profile['resumeUrl'] as String?;
    final resumeUrl = (rawResumeUrl != null && rawResumeUrl.isNotEmpty)
        ? '${ApiConstants.baseUrl}$rawResumeUrl'
        : null;

    return UserProfile(
      id: user['id'] as int? ?? 0,
      fullName: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      phone: profile['phone'] as String? ?? '',
      location: profile['location'] as String? ?? '',
      headline: profile['headline'] as String? ?? '',
      about: profile['about'] as String? ?? '',
      skills: skillsList,
      experience: experienceList
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: educationList
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      yearsOfExperience: profile['yearsOfExperience'] as int? ?? 0,
      preferredJobType: profile['preferredJobType'] as String? ?? 'Full-Time',
      preferredWorkingModel:
          profile['preferredWorkingModel'] as String? ?? 'Remote',
      linkedin: profile['linkedin'] as String?,
      github: profile['github'] as String?,
      portfolio: profile['portfolio'] as String?,
      profilePictureUrl: pictureUrl,
      resumeUrl: resumeUrl,
      hasResume: resumeUrl != null,
      completionPercent: profile['completionPercent'] as int? ?? 0,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}