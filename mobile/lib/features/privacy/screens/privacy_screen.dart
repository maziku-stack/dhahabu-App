import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _details = TextEditingController();
  String _requestType = 'access';
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final data = await ApiService().exportMyData();
      if (!mounted) return;
      final json = const JsonEncoder.withIndent('  ').convert(data);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Your data export'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(child: SelectableText(json)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
                elevation: 0,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data export copied to clipboard')),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy JSON'),
            ),
          ],
        ),
      );
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitRequest() async {
    setState(() => _busy = true);
    try {
      await ApiService().submitPrivacyRequest(
          type: _requestType, details: _details.text.trim());
      _details.clear();
      _message('Your request has been recorded for review.');
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
    }
  }

  InputDecoration _decoration({required IconData icon, String? label}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      prefixIcon: Icon(icon, color: AppColors.navy, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.gold, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthProvider>().isAuthenticated;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Privacy and data',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'DRAFT — NOT READY FOR PRODUCTION. The operating entity, privacy contact, service providers, retention periods and legal terms still need confirmation.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.navy,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data we collect',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account data: name, phone, email, account type and language; region and mining site are optional. We also process listing details, trade measurements and records, and dealer verification information. Passwords/PINs are stored as hashes; sign-in tokens are kept on your device.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Use and access',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data supports accounts, listings, trades, security and support. A miner’s phone appears on a listing only when they choose to share it. Trade participants see relevant counterparty details. Authority access must have a lawful basis and approved integration; Mining Commission/TRA integrations are not connected yet.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Retention, providers and your rights',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Retention periods, hosting/SMS/analytics providers, cross-border storage and the privacy officer’s contact still need confirmation. You can request access, correction, deletion, restriction or portability, or object to processing. Trade records may have legal retention requirements; a deletion request is reviewed and does not automatically erase such records.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Version $_noticeVersion. This product notice is a draft, not legal advice or a certification of compliance.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (authenticated) ...[
            const SizedBox(height: 28),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 28),
            Text(
              'Use your data rights',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _busy ? null : _export,
                icon: const Icon(Icons.download_outlined, color: AppColors.gold),
                label: const Text('View and copy my data export'),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _requestType,
              isExpanded: true,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
              items: const [
                DropdownMenuItem(
                    value: 'access', child: Text('Access / export')),
                DropdownMenuItem(
                    value: 'correction', child: Text('Correct my data')),
                DropdownMenuItem(
                    value: 'deletion', child: Text('Request deletion')),
                DropdownMenuItem(
                    value: 'restriction', child: Text('Restrict processing')),
                DropdownMenuItem(
                    value: 'objection', child: Text('Object to processing')),
                DropdownMenuItem(
                    value: 'portability', child: Text('Data portability')),
                DropdownMenuItem(
                    value: 'withdraw_consent',
                    child: Text('Withdraw optional consent')),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _requestType = value ?? 'access'),
              decoration: _decoration(icon: Icons.shield_outlined, label: 'Request type'),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _details,
              maxLength: 2000,
              maxLines: 3,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
              cursorColor: AppColors.gold,
              decoration: _decoration(icon: Icons.notes_rounded, label: 'Details (optional)'),
            ),
            const SizedBox(height: 12),
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
                onPressed: _busy ? null : _submitRequest,
                child: const Text(
                  'Submit request for review',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Requests are recorded as received for an operator to review. This form does not automatically delete data.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _noticeVersion = '2026-10-draft-1';
