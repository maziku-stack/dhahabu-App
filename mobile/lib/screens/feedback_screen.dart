import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _type = 'feedback';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getFeedback();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    try {
      await ApiService().submitFeedback(
        type: _type,
        subject: _subjectCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
      );
      _subjectCtrl.clear();
      _bodyCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted to Government Admin')),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Feedback & Grievances', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Reach regulators directly — no intermediary.', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 8),
                TextField(controller: _bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _submit, child: const Text('Submit')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('My submissions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_items.isEmpty)
          const Text('No submissions yet.')
        else
          ..._items.map((f) {
            return Card(
              child: ListTile(
                title: Text(f['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${f['type']} • ${f['status']}\n${f['body'] ?? ''}', maxLines: 3),
                isThreeLine: true,
              ),
            );
          }),
      ],
    );
  }
}
