class JobFilters {
  final String? workingModel;
  final String? jobType;
  final String? experienceLevel;
  final String? location;
  final int? salaryMin;
  final int? salaryMax;
  final String? company;
  final String? postedAfter;

  const JobFilters({
    this.workingModel,
    this.jobType,
    this.experienceLevel,
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.company,
    this.postedAfter,
  });

  bool get isEmpty =>
      workingModel == null &&
      jobType == null &&
      experienceLevel == null &&
      location == null &&
      salaryMin == null &&
      salaryMax == null &&
      company == null &&
      postedAfter == null;

  int get activeCount {
    int count = 0;
    if (workingModel != null) count++;
    if (jobType != null) count++;
    if (experienceLevel != null) count++;
    if (location != null) count++;
    if (salaryMin != null || salaryMax != null) count++;
    if (company != null) count++;
    if (postedAfter != null) count++;
    return count;
  }

  JobFilters copyWith({
    String? workingModel,
    String? jobType,
    String? experienceLevel,
    String? location,
    int? salaryMin,
    int? salaryMax,
    String? company,
    String? postedAfter,
    bool clearWorkingModel = false,
    bool clearJobType = false,
    bool clearExperienceLevel = false,
    bool clearLocation = false,
    bool clearSalary = false,
    bool clearCompany = false,
    bool clearPostedAfter = false,
  }) {
    return JobFilters(
      workingModel: clearWorkingModel
          ? null
          : (workingModel ?? this.workingModel),
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      experienceLevel: clearExperienceLevel
          ? null
          : (experienceLevel ?? this.experienceLevel),
      location: clearLocation ? null : (location ?? this.location),
      salaryMin: clearSalary ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalary ? null : (salaryMax ?? this.salaryMax),
      company: clearCompany ? null : (company ?? this.company),
      postedAfter:
          clearPostedAfter ? null : (postedAfter ?? this.postedAfter),
    );
  }
}