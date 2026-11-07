import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ReportDialog extends StatefulWidget {
  final String targetType;
  final int targetId;
  final String targetName;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide more details (10+ chars)')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await ReportService.submitReport(
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: reason,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted. Thank you.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report ${widget.targetType.toLowerCase()}', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(widget.targetName, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 20),
            Text('Why are you reporting this?', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g., This job looks like a scam. They are asking for payment.',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    minimumSize: const Size(100, 44),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}