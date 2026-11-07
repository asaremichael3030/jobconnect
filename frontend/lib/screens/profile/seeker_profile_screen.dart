import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/profile_section_card.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/timeline_entry.dart';
import 'edit_profile_screen.dart';

class SeekerProfileScreen extends StatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  State<SeekerProfileScreen> createState() => _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends State<SeekerProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await UserService.fetchMyProfile();

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _profile = result.profile;
      } else {
        _error = result.message ?? 'Failed to load profile';
      }
    });
  }

  Future<void> _openEditProfile() async {
    if (_profile == null) return;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: _profile!),
      ),
    );
    if (updated == true && mounted) {
      await _loadProfile();
    }
  }

  Future<void> _handleChangePicture() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      setState(() => _loading = true);
      final result = await UserService.uploadProfilePicture(bytes, picked.name);

      if (!mounted) return;
      if (!result.success) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Upload failed')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated'), backgroundColor: AppColors.success),
      );
      await _loadProfile();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick image')),
      );
    }
  }

  Future<void> _handleUploadResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      setState(() => _loading = true);
      final upload = await UserService.uploadResume(bytes, file.name);

      if (!mounted) return;
      if (!upload.success) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(upload.message ?? 'Upload failed')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume uploaded'), backgroundColor: AppColors.success),
      );
      await _loadProfile();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick file')),
      );
    }
  }

  // --- NEW DIALOGS FOR ADDING DATA ---

  void _addSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Flutter, Node.js, Python'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(context);
              setState(() => _loading = true);
              await UserService.addSkill(controller.text.trim());
              await _loadProfile();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addExperienceDialog() {
    final titleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Job Title')),
              TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Date (e.g. Jan 2023)')),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Date (or Present)')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty || companyCtrl.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _loading = true);
              await UserService.addExperience(
                jobTitle: titleCtrl.text.trim(),
                company: companyCtrl.text.trim(),
                startDate: startCtrl.text.trim(),
                endDate: endCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );
              await _loadProfile();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addEducationDialog() {
    final degreeCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: degreeCtrl, decoration: const InputDecoration(labelText: 'Degree (e.g. BSc Computer Science)')),
              TextField(controller: schoolCtrl, decoration: const InputDecoration(labelText: 'School/University')),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Year'), keyboardType: TextInputType.number),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Year'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (degreeCtrl.text.isEmpty || schoolCtrl.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _loading = true);
              await UserService.addEducation(
                degree: degreeCtrl.text.trim(),
                school: schoolCtrl.text.trim(),
                startYear: int.tryParse(startCtrl.text) ?? 0,
                endYear: int.tryParse(endCtrl.text) ?? 0,
              );
              await _loadProfile();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPreferencesDialog() {
    if (_profile == null) return;
    String jobType = _profile!.preferredJobType;
    String workingModel = _profile!.preferredWorkingModel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: jobType,
                decoration: const InputDecoration(labelText: 'Preferred Job Type'),
                items: ['Full-Time', 'Part-Time', 'Contract', 'Internship']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setDialogState(() => jobType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: workingModel,
                decoration: const InputDecoration(labelText: 'Working Model'),
                items: ['Remote', 'Hybrid', 'On-Site']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setDialogState(() => workingModel = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _loading = true);
                await UserService.updateMyProfile({
                  'preferredJobType': jobType,
                  'preferredWorkingModel': workingModel,
                });
                await _loadProfile();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editLinksDialog() {
    if (_profile == null) return;
    final linkedinCtrl = TextEditingController(text: _profile!.linkedin);
    final githubCtrl = TextEditingController(text: _profile!.github);
    final portfolioCtrl = TextEditingController(text: _profile!.portfolio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Links'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: linkedinCtrl, decoration: const InputDecoration(labelText: 'LinkedIn URL')),
            TextField(controller: githubCtrl, decoration: const InputDecoration(labelText: 'GitHub URL')),
            TextField(controller: portfolioCtrl, decoration: const InputDecoration(labelText: 'Portfolio Website')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _loading = true);
              await UserService.updateMyProfile({
                'linkedin': linkedinCtrl.text.trim(),
                'github': githubCtrl.text.trim(),
                'portfolio': portfolioCtrl.text.trim(),
              });
              await _loadProfile();
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text('Could not load your profile', style: AppTextStyles.h3),
              const SizedBox(height: 6),
              Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProfile, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentityCard(profile),
            const SizedBox(height: 16),
            _buildProgressCard(profile),
            const SizedBox(height: 16),
            _buildAboutSection(profile),
            const SizedBox(height: 16),
            _buildSkillsSection(profile),
            const SizedBox(height: 16),
            _buildExperienceSection(profile),
            const SizedBox(height: 16),
            _buildEducationSection(profile),
            const SizedBox(height: 16),
            _buildPreferencesSection(profile),
            const SizedBox(height: 16),
            _buildLinksSection(profile),
            const SizedBox(height: 16),
            _buildResumeSection(profile),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 4),
          Text('Profile', style: AppTextStyles.h3),
          const Spacer(),
          IconButton(onPressed: _openEditProfile, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(UserProfile profile) {
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
          ProfileAvatar(initials: profile.initials, imageUrl: profile.profilePictureUrl, onEditTap: _handleChangePicture),
          const SizedBox(height: 16),
          Text(profile.fullName.isEmpty ? 'Your name' : profile.fullName, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(profile.headline.isEmpty ? 'Add a professional headline' : profile.headline, style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          _contactRow(profile),
        ],
      ),
    );
  }

  Widget _contactRow(UserProfile profile) {
    final items = <Widget>[];
    if (profile.email.isNotEmpty) items.add(_contactItem(Icons.mail_outline, profile.email));
    if (profile.phone.isNotEmpty) items.add(_contactItem(Icons.phone_outlined, profile.phone));
    if (profile.location.isNotEmpty) items.add(_contactItem(Icons.location_on_outlined, profile.location));

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

  Widget _buildProgressCard(UserProfile profile) {
    final percent = profile.completionPercent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Profile $percent% complete', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(UserProfile profile) {
    return ProfileSectionCard(
      title: 'About',
      actionLabel: 'Edit',
      onAction: _openEditProfile,
      child: Text(
        profile.about.isEmpty ? 'Tell employers a little about yourself.' : profile.about,
        style: AppTextStyles.body.copyWith(height: 1.5, fontSize: 13, color: profile.about.isEmpty ? AppColors.textMuted : null),
      ),
    );
  }

  Widget _buildSkillsSection(UserProfile profile) {
    return ProfileSectionCard(
      title: 'Skills',
      actionLabel: 'Add',
      onAction: _addSkillDialog, // <-- WIRED UP
      child: profile.skills.isEmpty
          ? Text('Add your skills to stand out.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.skills
                  .map((skill) => SkillChip(label: skill, onRemove: () {})) // Remove functionality can be added later
                  .toList(),
            ),
    );
  }

  Widget _buildExperienceSection(UserProfile profile) {
    return ProfileSectionCard(
      title: 'Experience',
      actionLabel: 'Add',
      onAction: _addExperienceDialog, // <-- WIRED UP
      child: profile.experience.isEmpty
          ? Text('No experience added yet.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
          : Column(
              children: profile.experience
                  .map((exp) => TimelineEntry(
                        title: exp.jobTitle,
                        subtitle: exp.company,
                        dateRange: '${exp.startDate}  -  ${exp.endDate}',
                        description: exp.description,
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildEducationSection(UserProfile profile) {
    return ProfileSectionCard(
      title: 'Education',
      actionLabel: 'Add',
      onAction: _addEducationDialog, // <-- WIRED UP
      child: profile.education.isEmpty
          ? Text('No education added yet.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
          : Column(
              children: profile.education
                  .map((edu) => TimelineEntry(
                        title: edu.degree,
                        subtitle: edu.school,
                        dateRange: '${edu.startYear}  -  ${edu.endYear}',
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildPreferencesSection(UserProfile profile) {
    return ProfileSectionCard(
      title: 'Preferred Job Settings',
      actionLabel: 'Edit',
      onAction: _editPreferencesDialog, // <-- WIRED UP
      child: Column(
        children: [
          _preferenceRow(icon: Icons.work_outline, label: 'Job type', value: profile.preferredJobType),
          const SizedBox(height: 10),
          _preferenceRow(icon: Icons.laptop_mac_outlined, label: 'Working model', value: profile.preferredWorkingModel),
        ],
      ),
    );
  }

  Widget _preferenceRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 13))),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildLinksSection(UserProfile profile) {
    final links = <Widget>[];
    if (profile.linkedin != null && profile.linkedin!.isNotEmpty) links.add(_linkRow(Icons.link, profile.linkedin!));
    if (profile.github != null && profile.github!.isNotEmpty) links.add(_linkRow(Icons.code, profile.github!));
    if (profile.portfolio != null && profile.portfolio!.isNotEmpty) links.add(_linkRow(Icons.public, profile.portfolio!));

    return ProfileSectionCard(
      title: 'Links',
      actionLabel: 'Edit',
      onAction: _editLinksDialog, // <-- WIRED UP
      child: links.isEmpty
          ? Text('Add LinkedIn, GitHub or your portfolio.', style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.textMuted))
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

  Widget _buildResumeSection(UserProfile profile) {
    final fileName = profile.fullName.isEmpty ? 'Resume.pdf' : '${profile.fullName.split(" ").first}_CV.pdf';

    return ProfileSectionCard(
      title: 'Resume / CV',
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.danger, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.hasResume ? fileName : 'No CV uploaded', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(profile.hasResume ? 'Uploaded and ready to share' : 'Upload a PDF to apply faster', style: AppTextStyles.small.copyWith(fontSize: 11)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _handleUploadResume,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: AppTextStyles.pill.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            child: Text(profile.hasResume ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }
}