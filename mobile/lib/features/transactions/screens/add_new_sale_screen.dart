import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/l10n/l10n.dart';
import 'receipt_screen.dart';

class AddNewSaleScreen extends StatefulWidget {
  final String counterpartyPhone;
  final double weight;
  final String karat;
  final double pricePerGram;
  final String? listingId;

  const AddNewSaleScreen({
    super.key,
    required this.counterpartyPhone,
    this.weight = 0,
    this.karat = '24K',
    this.pricePerGram = 0,
    this.listingId,
  });

  @override
  State<AddNewSaleScreen> createState() => _AddNewSaleScreenState();
}

class _AddNewSaleScreenState extends State<AddNewSaleScreen> {
  late final _phone = TextEditingController(text: widget.counterpartyPhone);
  late final _weight = TextEditingController(
      text: widget.weight > 0 ? widget.weight.toString() : '');
  late final _price = TextEditingController(
      text: widget.pricePerGram > 0 ? widget.pricePerGram.toString() : '');
  String _karat = '';
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
    final l10n = context.l10n;
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
        SnackBar(
          content: Text(l10n.saleCreatedSnackbar),
        ),
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

  InputDecoration _decoration({required IconData icon, String? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      prefixIcon: Icon(icon, color: AppColors.navy, size: 20),
      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.gold, 2),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final fieldStyle = textTheme.bodyLarge?.copyWith(
      color: AppColors.navy,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.recordASale,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.saleDetailsPrompt,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            _label(l10n.counterpartyPhone),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.phone_outlined),
            ),
            const SizedBox(height: 18),
            _label(l10n.weight),
            TextField(
              controller: _weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.scale_outlined, suffix: 'g'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            _label(l10n.karat),
            DropdownButtonFormField<String>(
              initialValue: _karat,
              isExpanded: true,
              style: fieldStyle,
              items: const [
                DropdownMenuItem(value: '24K', child: Text('24K')),
                DropdownMenuItem(value: '22K', child: Text('22K')),
                DropdownMenuItem(value: '18K', child: Text('18K')),
              ],
              onChanged: (v) => setState(() => _karat = v!),
              decoration: _decoration(icon: Icons.diamond_outlined),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selfReportedNote,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _label(l10n.pricePerGram),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration:
                  _decoration(icon: Icons.payments_outlined, suffix: 'TZS'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    l10n.agreedSaleValue,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'TSh ${_fmt.format(_agreed)}',
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.agreedSaleValueDesc,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                ],
              ),
            ),
            const SizedBox(height: 28),
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
                    : Text(
                        l10n.submitSale,
                        style: textTheme.labelLarge
                            ?.copyWith(color: AppColors.navy),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
