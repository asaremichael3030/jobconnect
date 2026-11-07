import 'package:flutter/material.dart';

import '../../models/admin_company.dart';
import '../../services/admin_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin_company_card.dart';

class AdminCompaniesTab extends StatefulWidget {
  const AdminCompaniesTab({super.key});

  @override
  State<AdminCompaniesTab> createState() => _AdminCompaniesTabState();
}

class _AdminCompaniesTabState extends State<AdminCompaniesTab> {
  List<AdminCompany> _companies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final companies = await AdminService.fetchCompanies();
    if (!mounted) return;
    setState(() {
      _companies = companies;
      _loading = false;
    });
  }

  Future<void> _updateVerification(AdminCompany company, String status) async {
    final success = await AdminService.updateCompanyVerification(company.id, status);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company marked as $status')),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update company')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AdminCompanyCard(company: company, onTap: () {}),
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (company.verificationStatus == 'PENDING') ...[
                          TextButton(
                            onPressed: () => _updateVerification(company, 'REJECTED'),
                            child: const Text(
                              'Reject',
                              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updateVerification(company, 'VERIFIED'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 36),
                              backgroundColor: AppColors.success,
                            ),
                            child: const Text('Verify'),
                          ),
                        ] else if (company.verificationStatus == 'VERIFIED') ...[
                          TextButton(
                            onPressed: () => _updateVerification(company, 'PENDING'),
                            child: const Text(
                              'Revoke Verification',
                              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () => _updateVerification(company, 'VERIFIED'),
                            child: const Text(
                              'Verify Anyway',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}