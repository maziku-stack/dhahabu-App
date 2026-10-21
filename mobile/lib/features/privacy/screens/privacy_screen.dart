import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dhahabu/core/theme/app_colors.dart';
import 'package:dhahabu/core/network/api_service.dart';
import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/l10n/l10n.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key, this.showAcceptAction = false});

  /// Shows an explicit consent action when this screen is opened during signup.
  final bool showAcceptAction;

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
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final data = await ApiService().exportMyData();
      if (!mounted) return;
      final json = const JsonEncoder.withIndent('  ').convert(data);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.yourDataExport),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(child: SelectableText(json)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
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
                    SnackBar(content: Text(l10n.dataExportCopied)),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(l10n.copyJson),
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
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ApiService().submitPrivacyRequest(
          type: _requestType, details: _details.text.trim());
      _details.clear();
      _message(l10n.requestRecorded);
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
    final l10n = context.l10n;
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
          l10n.privacyAndData,
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
              l10n.draftNotice,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.navy,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.dataWeCollect,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dataCollectDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.useAndAccess,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.useAndAccessDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.retentionRights,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.retentionRightsDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noticeVersionDesc(_noticeVersion),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (widget.showAcceptAction) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.acceptPrivacyNotice),
              ),
            ),
          ],
          if (authenticated) ...[
            const SizedBox(height: 28),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 28),
            Text(
              l10n.useYourDataRights,
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
                icon:
                    const Icon(Icons.download_outlined, color: AppColors.gold),
                label: Text(l10n.viewAndCopyDataExport),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _requestType,
              isExpanded: true,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
              items: [
                DropdownMenuItem(
                    value: 'access', child: Text(l10n.accessExport)),
                DropdownMenuItem(
                    value: 'correction', child: Text(l10n.correctMyData)),
                DropdownMenuItem(
                    value: 'deletion', child: Text(l10n.requestDeletion)),
                DropdownMenuItem(
                    value: 'restriction', child: Text(l10n.restrictProcessing)),
                DropdownMenuItem(
                    value: 'objection', child: Text(l10n.objectToProcessing)),
                DropdownMenuItem(
                    value: 'portability', child: Text(l10n.dataPortability)),
                DropdownMenuItem(
                    value: 'withdraw_consent',
                    child: Text(l10n.withdrawConsent)),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _requestType = value ?? 'access'),
              decoration: _decoration(
                  icon: Icons.shield_outlined, label: l10n.requestType),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _details,
              maxLength: 2000,
              maxLines: 3,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.navy),
              cursorColor: AppColors.gold,
              decoration: _decoration(
                  icon: Icons.notes_rounded, label: l10n.detailsOptional),
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
                child: Text(
                  l10n.submitRequestForReview,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.requestsRecordedNote,
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
