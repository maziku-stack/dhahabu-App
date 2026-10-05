import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_card.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});
  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiService().getAuditLogs();
      setState(() { _items = d; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final a = _items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['action'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${a['entity_type']} ${a['entity_id']}', style: const TextStyle(fontSize: 12)),
                        Text('${a['actor'] ?? ''} · ${a['created_at'] ?? ''}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
