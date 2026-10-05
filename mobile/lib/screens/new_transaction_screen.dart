import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});
  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _phoneCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _karat = '24K';
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final weight = double.parse(_weightCtrl.text);
      final price = double.parse(_priceCtrl.text);
      final txn = await ApiService().createTransaction(
        counterpartyPhone: _phoneCtrl.text.trim(),
        weight: weight,
        karat: _karat,
        pricePerGram: price,
        notes: _notesCtrl.text.trim(),
      );
      setState(() {
        _success = 'Transaction created (${txn['status']}). '
            'Total: TZS ${txn['agreed_price']}. '
            'Miner must confirm to finalize & generate royalty.';
        _phoneCtrl.clear();
        _weightCtrl.clear();
        _priceCtrl.clear();
        _notesCtrl.clear();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _weightCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record a Sale',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Both parties will share an immutable record.',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child:
                  Text(_error!, style: TextStyle(color: Colors.red.shade800)),
            ),
          if (_success != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(_success!,
                  style: TextStyle(color: Colors.green.shade800)),
            ),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Counterparty phone',
              hintText: 'Miner or Dealer phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight (grams)',
              prefixIcon: Icon(Icons.scale),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _karat,
            decoration: const InputDecoration(labelText: 'Karat purity'),
            items: const [
              DropdownMenuItem(value: '24K', child: Text('24K')),
              DropdownMenuItem(value: '22K', child: Text('22K')),
              DropdownMenuItem(value: '18K', child: Text('18K')),
            ],
            onChanged: (v) => setState(() => _karat = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price per gram (TZS)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Transaction'),
          ),
        ],
      ),
    );
  }
}
