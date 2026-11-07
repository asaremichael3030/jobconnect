import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/company_profile.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/profile_section_card.dart';
import '../../widgets/verification_badge.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  CompanyProfile? _company;
  bool _exists = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await CompanyService.fetchMyCompany();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _exists = result.exists;
        _company = result.company;
      } else {
        _error = result.message ?? 'Failed to load company';
      }
    });
  }

  Future<void> _handleCreateCompany() async {
    setState(() => _loading = true);
    final result = await CompanyService.updateMyCompany({
      'name': 'TechCorp Ltd',
      'industry': 'Software Development',
      'location': 'Accra, Ghana',
      'about': 'A default company profile created from the app.',
    });
    if (!mounted) return;
    
    if (result.success) {
      await _loadCompany();
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to create company')),
      );
    }
  }

  Future<void> _handleChangeLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _loading = true);
      final result = await CompanyService.uploadCompanyLogo(bytes, picked.name);
      if (!mounted) return;
      if (!result.success) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Upload failed')));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company logo updated'), backgroundColor: AppColors.success));
      await _loadCompany();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image')));
    }
  }

  void _editCompanyDetails() {
    if (_company == null) return;
    
    final nameCtrl = TextEditingController(text: _company!.name);
    final industryCtrl = TextEditingController(text: _company!.industry);
    final sizeCtrl = TextEditingController(text: _company!.companySize);
    final locationCtrl = TextEditingController(text: _company!.location);
    final foundedCtrl = TextEditingController(text: _company!.foundedYear > 0 ? _company!.foundedYear.toString() : '');
    final websiteCtrl = TextEditingController(text: _company!.website);
    final linkedinCtrl = TextEditingController(text: _company!.linkedin);
    final twitterCtrl = TextEditingController(text: _company!.twitter);
    final aboutCtrl = TextEditingController(text: _company!.about);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Company Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
              const SizedBox(height: 8),
              TextField(controller: industryCtrl, decoration: const InputDecoration(labelText: 'Industry')),
              const SizedBox(height: 8),
              TextField(controller: sizeCtrl, decoration: const InputDecoration(labelText: 'Company Size (e.g. 50-200)')),
              const SizedBox(height: 8),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 8),
              TextField(controller: foundedCtrl, decoration: const InputDecoration(labelText: 'Founded Year'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: websiteCtrl, decoration: const InputDecoration(labelText: 'Website URL')),
              const SizedBox(height: 8),
              TextField(controller: linkedinCtrl, decoration: const InputDecoration(labelText: 'LinkedIn URL')),
              const SizedBox(height: 8),
              TextField(controller: twitterCtrl, decoration: const InputDecoration(labelText: 'Twitter URL')),
              const SizedBox(height: 8),
              TextField(controller: aboutCtrl, decoration: const InputDecoration(labelText: 'About'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _loading = true);
              await CompanyService.updateMyCompany({
                'name': nameCtrl.text.trim(),
                'industry': industryCtrl.text.trim(),
                'companySize': sizeCtrl.text.trim(),
                'location': locationCtrl.text.trim(),
                'foundedYear': int.tryParse(foundedCtrl.text.trim()) ?? 0,
                'website': websiteCtrl.text.trim(),
                'linkedin': linkedinCtrl.text.trim(),
                'twitter': twitterCtrl.text.trim(),
                'about': aboutCtrl.text.trim(),
              });
              await _loadCompany();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Text(_error!, style: AppTextStyles.bodyMuted));
    if (!_exists || _company == null) return _buildEmptyState();

    final company = _company!;

    return RefreshIndicator(
      onRefresh: _loadCompany,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentityCard(company),
            const SizedBox(height: 16),
            _buildStatsRow(company),
            const SizedBox(height: 16),
            _buildAboutSection(company),
            const SizedBox(height: 16),
            _buildSpecialtiesSection(company),
            const SizedBox(height: 16),
            _buildInfoSection(company),
            const SizedBox(height: 16),
            _buildLinksSection(company),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.business_outlined, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Set up your company profile', style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Add your company details to start posting jobs and receiving applications.', textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _handleCreateCompany, child: const Text('Create Company Profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 4),
          Text('Company Profile', style: AppTextStyles.h3),
          const Spacer(),
          if (_exists) IconButton(onPressed: _editCompanyDetails, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(CompanyProfile company) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ProfileAvatar(initials: company.initial, imageUrl: company.logoUrl, onEditTap: _handleChangeLogo),
          const SizedBox(height: 14),
          Text(company.name, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            company.industry.isEmpty && company.foundedYear == 0
                ? 'Add industry and founding year'
                : '${company.industry}  \u00B7  Founded ${company.foundedYear}',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          VerificationBadge(status: company.verificationStatus),
          const SizedBox(height: 12),
          _contactRow(company),
        ],
      ),
    );
  }

  Widget _contactRow(CompanyProfile company) {
    final items = <Widget>[];
    if (company.website.isNotEmpty) items.add(_contactItem(Icons.public, company.website));
    if (company.email.isNotEmpty) items.add(_contactItem(Icons.mail_outline, company.email));
    if (company.location.isNotEmpty) items.add(_contactItem(Icons.location_on_outlined, company.location));
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(alignment: WrapAlignment.center, spacing: 16, runSpacing: 6, children: items);
  }

  Widget _contactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.small.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsRow(CompanyProfile company) {
    return Row(
      children: [
        Expanded(child: _statTile(label: 'Open Jobs', value: '${company.openJobs}', icon: Icons.work_outline)),
        const SizedBox(width: 10),
        Expanded(child: _statTile(label: 'Total Hires', value: '${company.totalHires}', icon: Icons.check_circle_outline)),
        const SizedBox(width: 10),
        Expanded(child: _statTile(label: 'Team Size', value: company.companySize.isEmpty ? 'N/A' : company.companySize.split(' ').first, icon: Icons.people_outline)),
      ],
    );
  }

  Widget _statTile({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.statNumber.copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.small.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(CompanyProfile company) {
    return ProfileSectionCard(
      title: 'About',
      actionLabel: 'Edit',
      onAction: _editCompanyDetails,
      child: Text(
        company.about.isEmpty ? 'Tell job seekers about your company.' : company.about,
        style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13, color: company.about.isEmpty ? AppColors.textMuted : null),
      ),
    );
  }

  Widget _buildSpecialtiesSection(CompanyProfile company) {
    // We removed the 'Add' button because Specialties requires a separate table in the database.
    // It is now a read-only display.
    return ProfileSectionCard(
      title: 'Specialties',
      child: company.specialties.isEmpty
          ? Text('No specialties added yet.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: company.specialties.map((s) => Chip(label: Text(s))).toList(),
            ),
    );
  }

  Widget _buildInfoSection(CompanyProfile company) {
    return ProfileSectionCard(
      title: 'Company Information',
      actionLabel: 'Edit',
      onAction: _editCompanyDetails,
      child: Column(
        children: [
          _infoRow(Icons.business_outlined, 'Industry', company.industry.isEmpty ? 'Not set' : company.industry),
          const SizedBox(height: 10),
          _infoRow(Icons.people_outline, 'Company size', company.companySize.isEmpty ? 'Not set' : company.companySize),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, 'Headquarters', company.location.isEmpty ? 'Not set' : company.location),
          const SizedBox(height: 10),
          _infoRow(Icons.calendar_today_outlined, 'Founded', company.foundedYear == 0 ? 'Not set' : '${company.foundedYear}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 13))),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildLinksSection(CompanyProfile company) {
    final links = <Widget>[];
    if (company.website.isNotEmpty) links.add(_linkRow(Icons.public, company.website));
    if (company.linkedin != null && company.linkedin!.isNotEmpty) links.add(_linkRow(Icons.link, company.linkedin!));
    if (company.twitter != null && company.twitter!.isNotEmpty) links.add(_linkRow(Icons.alternate_email, company.twitter!));

    return ProfileSectionCard(
      title: 'Links',
      actionLabel: 'Edit',
      onAction: _editCompanyDetails,
      child: links.isEmpty
          ? Text('Add website, LinkedIn or Twitter.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
          : Column(
              children: [
                for (int i = 0; i < links.length; i++) ...[
                  links[i],
                  if (i < links.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _linkRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.primary))),
        const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
      ],
    );
  }
}