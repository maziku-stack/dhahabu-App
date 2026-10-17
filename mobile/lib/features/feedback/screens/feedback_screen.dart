import 'package:flutter/material.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  final bool isAdmin;
  const FeedbackScreen({super.key, this.isAdmin = false});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<dynamic> _items = [];
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String _type = 'feedback';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getFeedback();
      if (!mounted) return;
      setState(() => _items = d);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _body.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService().submitFeedback(
        type: _type,
        subject: _subject.text.trim(),
        body: _body.text.trim(),
      );
      _subject.clear();
      _body.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully.')),
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(String id) async {
    final controller = TextEditingController();
    final response = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resolve feedback'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Response (optional)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Mark resolved'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (response == null || !mounted) return;
    try {
      await ApiService().respondToFeedback(id, response);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  InputDecoration _decoration({required IconData icon, String? label}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      prefixIcon: Icon(icon, color: AppColors.navy, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.gold, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isAdmin ? 'Feedback Inbox' : 'Feedback & Support',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          if (!widget.isAdmin) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Category',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'feedback',
                        label: Text('Feedback'),
                        icon: Icon(Icons.feedback_outlined, size: 16),
                      ),
                      ButtonSegment(
                        value: 'grievance',
                        label: Text('Grievance'),
                        icon: Icon(Icons.report_problem_outlined, size: 16),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.gold.withValues(alpha: 0.2),
                      selectedForegroundColor: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _subject,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                    cursorColor: AppColors.gold,
                    decoration: _decoration(
                      icon: Icons.subject_rounded,
                      label: 'Subject',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _body,
                    maxLines: 3,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
                    cursorColor: AppColors.gold,
                    decoration: _decoration(
                      icon: Icons.message_outlined,
                      label: 'Message',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.navy,
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.isAdmin ? 'All Submissions' : 'Your History',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'No feedback records found.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ..._items.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            f['subject'] ?? '',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: f['status'] == 'resolved'
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${f['type']} · ${f['status']}',
                            style: textTheme.labelSmall?.copyWith(
                              color: f['status'] == 'resolved'
                                    ? AppColors.success
                                    : AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f['body'] ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if ((f['admin_response'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Reply: ${f['admin_response']}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (widget.isAdmin && f['status'] != 'resolved') ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.navy,
                          ),
                          onPressed: () => _respond(f['id'].toString()),
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: AppColors.gold),
                          label: const Text('Respond / resolve'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
