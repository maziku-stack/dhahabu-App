import 'package:flutter/material.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/widgets/app_card.dart';
import 'package:dhahabu/l10n/l10n.dart';

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
      setState(() {
        _items = d;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditLog)),
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
                        Text(a['action'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${a['entity_type']} ${a['entity_id']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${a['actor'] ?? ''} · ${a['created_at'] ?? ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
