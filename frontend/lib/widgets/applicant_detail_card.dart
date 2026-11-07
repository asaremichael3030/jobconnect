import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/application.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ApplicantDetailCard extends StatelessWidget {
  final Application application;
  final ValueChanged<String>? onStatusChanged;

  const ApplicantDetailCard({
    super.key,
    required this.application,
    this.onStatusChanged,
  });

  static const List<String> statuses = [
    'APPLIED', 'REVIEWING', 'SHORTLISTED', 'INTERVIEW', 'HIRED', 'REJECTED',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName.isEmpty ? 'Applicant' : application.applicantName,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.applicantHeadline.isEmpty ? application.applicantEmail : application.applicantHeadline,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          if (application.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Text(
                application.coverLetter,
                style: AppTextStyles.body.copyWith(fontSize: 12, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 12),
          
          // NEW: View CV Button
          if (application.resumeUrl != null && application.resumeUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(application.resumeUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open CV')));
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('View Applicant CV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Status', style: AppTextStyles.small.copyWith(fontSize: 12)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: application.status,
                  isExpanded: true,
                  items: statuses.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(_pretty(s), style: AppTextStyles.body.copyWith(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null && v != application.status) {
                      onStatusChanged?.call(v);
                    }
                  },
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (application.applicantAvatarUrl != null && application.applicantAvatarUrl!.isNotEmpty) {
      return ClipOval(child: Image.network(application.applicantAvatarUrl!, width: 48, height: 48, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialAvatar()));
    }
    return _initialAvatar();
  }

  Widget _initialAvatar() {
    return Container(
      width: 48, height: 48,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(application.initials, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statusBadge() {
    final color = application.statusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(application.statusLabel(), style: AppTextStyles.pill.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }

  String _pretty(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}