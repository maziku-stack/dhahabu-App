import 'package:flutter/material.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/l10n/l10n.dart';

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
  bool _sharePhone = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final w = double.parse(_weight.text);
      final asking = double.parse(_price.text);
      await ApiService().createListing(
        weight: w,
        karat: _karat,
        askingPrice: asking,
        pricePerGram: asking / w,
        notes: _notes.text,
        sharePhone: _sharePhone,
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
          l10n.createNewListing,
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
            _label(l10n.weightGrams),
            TextField(
              controller: _weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.scale_outlined, suffix: 'g'),
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
            const SizedBox(height: 18),
            _label(l10n.askingPriceTzs),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.payments_outlined, suffix: 'TZS'),
            ),
            const SizedBox(height: 18),
            _label(l10n.notes),
            TextField(
              controller: _notes,
              maxLines: 3,
              style: fieldStyle,
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.note_outlined),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _sharePhone,
              onChanged: _loading
                  ? null
                  : (value) => setState(() => _sharePhone = value ?? false),
              activeColor: AppColors.navy,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.showPhoneOnListing,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n.showPhoneSubtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
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
                        l10n.publishListing,
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
