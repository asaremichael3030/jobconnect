import 'package:flutter/material.dart';

import '../../services/job_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  String _workingModel = 'Remote';
  String _jobType = 'Full-Time';
  String _experienceLevel = 'Mid-Level';
  DateTime? _deadline;
  bool _loading = false;

  final List<String> _workingModels = const ['Remote', 'Hybrid', 'On-Site'];
  final List<String> _jobTypes = const [
    'Full-Time',
    'Part-Time',
    'Internship',
    'Contract',
  ];
  final List<String> _experienceLevels = const [
    'Internship',
    'Entry Level',
    'Junior',
    'Mid-Level',
    'Senior',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'workingModel': _workingModel,
      'jobType': _jobType,
      'experienceLevel': _experienceLevel,
    };

    if (_locationController.text.trim().isNotEmpty) {
      payload['location'] = _locationController.text.trim();
    }
    if (_salaryMinController.text.trim().isNotEmpty) {
      payload['salaryMin'] = int.tryParse(_salaryMinController.text.trim());
    }
    if (_salaryMaxController.text.trim().isNotEmpty) {
      payload['salaryMax'] = int.tryParse(_salaryMaxController.text.trim());
    }
    if (_requirementsController.text.trim().isNotEmpty) {
      payload['requirements'] = _requirementsController.text.trim();
    }
    if (_responsibilitiesController.text.trim().isNotEmpty) {
      payload['responsibilities'] = _responsibilitiesController.text.trim();
    }
    if (_deadline != null) {
      payload['applicationDeadline'] = _formatDate(_deadline!);
    }

    final result = await JobService.createJob(payload);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to create job')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job posted successfully'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Job Details'),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Job title',
                        hint: 'e.g. Frontend Developer',
                        icon: Icons.work_outline,
                        controller: _titleController,
                        validator: (v) {
                          if (v == null || v.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Location',
                        hint: 'e.g. Accra, Ghana or Remote',
                        icon: Icons.location_on_outlined,
                        controller: _locationController,
                      ),
                      const SizedBox(height: 16),
                      _buildMultilineField(
                        label: 'Job description',
                        hint: 'Describe the role, team, and what success looks like',
                        controller: _descriptionController,
                        minLines: 4,
                        validator: (v) {
                          if (v == null || v.trim().length < 20) {
                            return 'Description must be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Job Settings'),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Working model',
                        value: _workingModel,
                        options: _workingModels,
                        onChanged: (v) => setState(() => _workingModel = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Job type',
                        value: _jobType,
                        options: _jobTypes,
                        onChanged: (v) => setState(() => _jobType = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Experience level',
                        value: _experienceLevel,
                        options: _experienceLevels,
                        onChanged: (v) => setState(() => _experienceLevel = v!),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Compensation (optional)'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Salary min (USD)',
                              hint: '40000',
                              icon: Icons.attach_money,
                              controller: _salaryMinController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Salary max (USD)',
                              hint: '60000',
                              icon: Icons.attach_money,
                              controller: _salaryMaxController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Additional details (optional)'),
                      const SizedBox(height: 12),
                      _buildMultilineField(
                        label: 'Requirements',
                        hint: 'List skills, experience, qualifications',
                        controller: _requirementsController,
                        minLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildMultilineField(
                        label: 'Responsibilities',
                        hint: 'What will this person do day to day?',
                        controller: _responsibilitiesController,
                        minLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Application deadline (optional)'),
                      const SizedBox(height: 12),
                      _buildDeadlineField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post a Job',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reach qualified candidates',
                  style: AppTextStyles.small.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildMultilineField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 3,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines + 3,
          validator: validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
          style: AppTextStyles.body,
          dropdownColor: AppColors.surface,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildDeadlineField() {
    final label = _deadline == null
        ? 'No deadline set'
        : _formatDate(_deadline!);

    return InkWell(
      onTap: _pickDeadline,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.body),
            ),
            if (_deadline != null)
              GestureDetector(
                onTap: () => setState(() => _deadline = null),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _loading ? null : _handleSubmit,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Post Job'),
        ),
      ),
    );
  }
}