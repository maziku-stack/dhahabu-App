import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
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
    await ApiService().submitFeedback(type: _type, subject: _subject.text, body: _body.text);
    _subject.clear();
    _body.clear();
    _load();
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
      appBar: AppBar(title: Text(widget.isAdmin ? 'Feedback Inbox' : 'Feedback')),
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
                      ButtonSegment(value: 'grievance', label: Text('Grievance')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
                  const SizedBox(height: 8),
                  TextField(controller: _body, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _submit, child: const Text('Submit')),
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
                      Text(f['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${f['type']} · ${f['status']}', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                      Text(f['body'] ?? ''),
                      if ((f['admin_response'] ?? '').toString().isNotEmpty)
                        Text('Reply: ${f['admin_response']}', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
