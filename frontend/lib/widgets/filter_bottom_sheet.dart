import 'package:flutter/material.dart';

import '../models/job_filters.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FilterBottomSheet extends StatefulWidget {
  final JobFilters initial;

  const FilterBottomSheet({super.key, required this.initial});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late JobFilters _draft;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _companyController;

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
  final List<String> _locations = const [
    'Remote',
    'New York, USA',
    'Accra, Ghana',
    'London, UK',
  ];
  final List<MapEntry<String, String>> _dateRanges = const [
    MapEntry('any', 'Any time'),
    MapEntry('1', 'Last 24 hours'),
    MapEntry('7', 'Last 7 days'),
    MapEntry('30', 'Last 30 days'),
  ];

  String _selectedDateRange = 'any';

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _salaryMinController = TextEditingController(
      text: _draft.salaryMin?.toString() ?? '',
    );
    _salaryMaxController = TextEditingController(
      text: _draft.salaryMax?.toString() ?? '',
    );
    _companyController = TextEditingController(
      text: _draft.company ?? '',
    );
    _selectedDateRange = _draft.postedAfter ?? 'any';
  }

  @override
  void dispose() {
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _grabber(),
            _header(),
            const Divider(height: 1, color: AppColors.divider),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      title: 'Working Model',
                      options: _workingModels,
                      selected: _draft.workingModel,
                      onSelect: (value) => setState(() {
                        _draft = _draft.workingModel == value
                            ? _draft.copyWith(clearWorkingModel: true)
                            : _draft.copyWith(workingModel: value);
                      }),
                    ),
                    const SizedBox(height: 20),
                    _section(
                      title: 'Job Type',
                      options: _jobTypes,
                      selected: _draft.jobType,
                      onSelect: (value) => setState(() {
                        _draft = _draft.jobType == value
                            ? _draft.copyWith(clearJobType: true)
                            : _draft.copyWith(jobType: value);
                      }),
                    ),
                    const SizedBox(height: 20),
                    _section(
                      title: 'Experience Level',
                      options: _experienceLevels,
                      selected: _draft.experienceLevel,
                      onSelect: (value) => setState(() {
                        _draft = _draft.experienceLevel == value
                            ? _draft.copyWith(clearExperienceLevel: true)
                            : _draft.copyWith(experienceLevel: value);
                      }),
                    ),
                    const SizedBox(height: 20),
                    _section(
                      title: 'Location',
                      options: _locations,
                      selected: _draft.location,
                      onSelect: (value) => setState(() {
                        _draft = _draft.location == value
                            ? _draft.copyWith(clearLocation: true)
                            : _draft.copyWith(location: value);
                      }),
                    ),
                    const SizedBox(height: 20),
                    _salarySection(),
                    const SizedBox(height: 20),
                    _textFieldSection(
                      title: 'Company',
                      hint: 'e.g. TechCorp',
                      controller: _companyController,
                      onChanged: (value) {
                        final trimmed = value.trim();
                        _draft = trimmed.isEmpty
                            ? _draft.copyWith(clearCompany: true)
                            : _draft.copyWith(company: trimmed);
                      },
                    ),
                    const SizedBox(height: 20),
                    _dateSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _grabber() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        children: [
          Text('Filters', style: AppTextStyles.h3),
          const Spacer(),
          if (!_draft.isEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _draft = const JobFilters();
                  _salaryMinController.clear();
                  _salaryMaxController.clear();
                  _companyController.clear();
                  _selectedDateRange = 'any';
                });
              },
              child: Text(
                'Reset',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<String> options,
    required String? selected,
    required void Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  option,
                  style: AppTextStyles.pill.copyWith(
                    color:
                        isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _salarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary Range (USD)',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _salaryMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Min'),
                onChanged: (value) {
                  final n = int.tryParse(value);
                  _draft = n == null
                      ? _draft.copyWith(clearSalary: true)
                      : _draft.copyWith(salaryMin: n);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _salaryMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Max'),
                onChanged: (value) {
                  final n = int.tryParse(value);
                  _draft = n == null
                      ? _draft.copyWith(clearSalary: true)
                      : _draft.copyWith(salaryMax: n);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _textFieldSection({
    required String title,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posted',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dateRanges.map((entry) {
            final isSelected = entry.key == _selectedDateRange;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateRange = entry.key;
                  if (entry.key == 'any') {
                    _draft = _draft.copyWith(clearPostedAfter: true);
                  } else {
                    final days = int.parse(entry.key);
                    final cutoff = DateTime.now()
                        .subtract(Duration(days: days))
                        .toIso8601String();
                    _draft = _draft.copyWith(postedAfter: cutoff);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: AppTextStyles.pill.copyWith(
                    color:
                        isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                textStyle: AppTextStyles.buttonText
                    .copyWith(color: AppColors.primary),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _draft),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}