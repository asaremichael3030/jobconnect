import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _aboutController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _portfolioController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _locationController = TextEditingController(text: widget.profile.location);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _aboutController = TextEditingController(text: widget.profile.about);
    _linkedinController = TextEditingController(text: widget.profile.linkedin ?? '');
    _githubController = TextEditingController(text: widget.profile.github ?? '');
    _portfolioController = TextEditingController(text: widget.profile.portfolio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await UserService.updateMyProfile({
      'name': _nameController.text.trim(),
      'headline': _headlineController.text.trim(),
      'location': _locationController.text.trim(),
      'phone': _phoneController.text.trim(),
      'about': _aboutController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'github': _githubController.text.trim(),
      'portfolio': _portfolioController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'Your name',
                icon: Icons.person_outline,
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Professional Headline',
                hint: 'e.g. Flutter Developer',
                icon: Icons.work_outline,
                controller: _headlineController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location',
                hint: 'e.g. Accra, Ghana',
                icon: Icons.location_on_outlined,
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone',
                hint: '+233 24 000 0000',
                icon: Icons.phone_outlined,
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 4,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Tell employers about yourself...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Links', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              AppTextField(
                label: 'LinkedIn',
                hint: 'linkedin.com/in/username',
                icon: Icons.link,
                controller: _linkedinController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'GitHub',
                hint: 'github.com/username',
                icon: Icons.code,
                controller: _githubController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Portfolio',
                hint: 'yourwebsite.com',
                icon: Icons.public,
                controller: _portfolioController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}