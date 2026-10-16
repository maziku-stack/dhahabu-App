import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import '../../widgets/app_card.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getFeedback();
      setState(() => _items = d);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_subject.text.isEmpty || _body.text.isEmpty) return;
    await ApiService()
        .submitFeedback(type: _type, subject: _subject.text, body: _body.text);
    _subject.clear();
    _body.clear();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isAdmin ? 'Feedback Inbox' : 'Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!widget.isAdmin) ...[
            AppCard(
              child: Column(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'feedback', label: Text('Feedback')),
                      ButtonSegment(
                          value: 'grievance', label: Text('Grievance')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _subject,
                      decoration: const InputDecoration(labelText: 'Subject')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _body,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Message')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _submit, child: const Text('Submit')),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ..._items.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['subject'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${f['type']} · ${f['status']}',
                          style: const TextStyle(
                              color: AppColors.gold, fontSize: 12)),
                      Text(f['body'] ?? ''),
                      if ((f['admin_response'] ?? '').toString().isNotEmpty)
                        Text(
                          'Reply: ${f['admin_response']}',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (widget.isAdmin && f['status'] != 'resolved')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _respond(f['id'].toString()),
                            child: const Text('Respond / resolve'),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
