class Report {
  final int id;
  final String reporterName;
  final String targetType;
  final int targetId;
  final String targetName;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] as String?;
    return Report(
      id: json['id'] as int? ?? 0,
      reporterName: json['reporterName'] as String? ?? '',
      targetType: json['targetType'] as String? ?? '',
      targetId: json['targetId'] as int? ?? 0,
      targetName: json['targetName'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: rawDate != null ? DateTime.tryParse(rawDate) : null,
    );
  }
}