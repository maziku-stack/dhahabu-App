import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import 'receipt_screen.dart';

class ConfirmSaleScreen extends StatefulWidget {
  final String counterpartyPhone;
  final double weight;
  final String karat;
  final double pricePerGram;
  final String? listingId;

  const ConfirmSaleScreen({
    super.key,
    required this.counterpartyPhone,
    this.weight = 0,
    this.karat = '24K',
    this.pricePerGram = 0,
    this.listingId,
  });

  @override
  State<ConfirmSaleScreen> createState() => _ConfirmSaleScreenState();
}

class _ConfirmSaleScreenState extends State<ConfirmSaleScreen> {
  late final _phone = TextEditingController(text: widget.counterpartyPhone);
  late final _weight = TextEditingController(
      text: widget.weight > 0 ? widget.weight.toString() : '');
  late final _price = TextEditingController(
      text: widget.pricePerGram > 0 ? widget.pricePerGram.toString() : '');
  String _karat = '24K';
  bool _loading = false;
  String? _error;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _karat = widget.karat;
  }

  double get _agreed {
    final w = double.tryParse(_weight.text) ?? 0;
    final p = double.tryParse(_price.text) ?? 0;
    return w * p;
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final txn = await ApiService().createTransaction(
        counterpartyPhone: _phone.text.trim(),
        weight: double.parse(_weight.text),
        karat: _karat,
        pricePerGram: double.parse(_price.text),
        listingId: widget.listingId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Sale created. Both parties must confirm to finalize it.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReceiptScreen(txn: txn)),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _weight.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Sale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            TextField(
                controller: _phone,
                decoration:
                    const InputDecoration(labelText: 'Counterparty phone')),
            const SizedBox(height: 12),
            TextField(
                controller: _weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (grams)')),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                  'Weight and karat entered here are self-reported until an approved assay device/provider is connected.'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _karat,
              items: const [
                DropdownMenuItem(value: '24K', child: Text('24K')),
                DropdownMenuItem(value: '22K', child: Text('22K')),
                DropdownMenuItem(value: '18K', child: Text('18K')),
              ],
              onChanged: (v) => setState(() => _karat = v!),
              decoration: const InputDecoration(labelText: 'Karat'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Price per gram (TZS)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sale value and official charges',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Agreed: TSh ${_fmt.format(_agreed)}'),
                  const Text(
                      'This is the price agreed by the two parties, not an official Commission quote.'),
                  const Text(
                    'Official charges and payment status will be shown when the approved government assessment service is connected. Dhahabu adds no charge here.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child:
                  Text(_loading ? '…' : 'Submit sale (both parties confirm)'),
            ),
          ],
        ),
      ),
    );
  }
}
