import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class ListingNewScreen extends StatefulWidget {
  const ListingNewScreen({super.key});
  @override
  State<ListingNewScreen> createState() => _ListingNewScreenState();
}

class _ListingNewScreenState extends State<ListingNewScreen> {
  final _weight = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  String _karat = '24K';
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final w = double.parse(_weight.text);
      final asking = double.parse(_price.text);
      await ApiService().createListing(
        weight: w,
        karat: _karat,
        askingPrice: asking,
        pricePerGram: asking / w,
        notes: _notes.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error)),
            TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (grams)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _karat,
              items: const [
                DropdownMenuItem(value: '24K', child: Text('24K')),
                DropdownMenuItem(value: '22K', child: Text('22K')),
                DropdownMenuItem(value: '18K', child: Text('18K')),
              ],
              onChanged: (v) => setState(() => _karat = v!),
              decoration: const InputDecoration(labelText: 'Karat'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Asking price (TZS total)')),
            const SizedBox(height: 12),
            TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? '…' : 'Publish listing')),
          ],
        ),
      ),
    );
  }
}
