import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dhahabu/core/providers/app_settings_provider.dart';
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
              child: SingleChildScrollView(child: SelectableText(json))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
            FilledButton.icon(
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
              icon: const Icon(Icons.copy),
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

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<AppSettingsProvider>().isSwahili;
    final authenticated = context.watch<AuthProvider>().isAuthenticated;
    return Scaffold(
      appBar: AppBar(title: Text(sw ? 'Faragha na data' : 'Privacy and data')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(sw
                  ? 'RASIMU YA MAJARIBIO — haijakamilika kwa matumizi ya uzalishaji. Taasisi inayoendesha, mawasiliano ya faragha, watoa huduma, muda wa kuhifadhi na masharti ya kisheria lazima yathibitishwe.'
                  : 'DRAFT — NOT READY FOR PRODUCTION. The operating entity, privacy contact, service providers, retention periods and legal terms still need confirmation.'),
            ),
          ),
          const SizedBox(height: 12),
          Text(sw ? 'Data tunayokusanya' : 'Data we collect',
              style: Theme.of(context).textTheme.titleLarge),
          Text(sw
              ? 'Akaunti: jina, simu, barua pepe, aina ya akaunti na lugha. Kwa hiari: eneo na mgodi. Pia taarifa za matangazo, vipimo vya biashara, rekodi za miamala na uthibitishaji wa wafanyabiashara. Nenosiri/PIN huhifadhiwa kama hash; tokeni za kuingia huhifadhiwa kwenye kifaa.'
              : 'Account data: name, phone, email, account type and language; region and mining site are optional. We also process listing details, trade measurements and records, and dealer verification information. Passwords/PINs are stored as hashes; sign-in tokens are kept on your device.'),
          const SizedBox(height: 12),
          Text(sw ? 'Matumizi na ufikiaji' : 'Use and access',
              style: Theme.of(context).textTheme.titleLarge),
          Text(sw
              ? 'Taarifa hutumika kuendesha akaunti, matangazo, miamala, usalama na huduma kwa wateja. Namba ya simu huonyeshwa kwenye tangazo tu ikiwa mchimbaji amechagua kushiriki. Washiriki wa muamala huona taarifa muhimu za upande mwingine. Ufikiaji wa mamlaka hutegemea msingi halali na muunganisho ulioidhinishwa; miunganisho ya Mining Commission/TRA bado haijaunganishwa.'
              : 'Data supports accounts, listings, trades, security and support. A miner’s phone appears on a listing only when they choose to share it. Trade participants see relevant counterparty details. Authority access must have a lawful basis and approved integration; Mining Commission/TRA integrations are not connected yet.'),
          const SizedBox(height: 12),
          Text(
              sw
                  ? 'Muda, watoa huduma na haki zako'
                  : 'Retention, providers and your rights',
              style: Theme.of(context).textTheme.titleLarge),
          Text(sw
              ? 'Muda wa kuhifadhi, kampuni za hosting/SMS/uchanganuzi, uhamisho wa data nje ya nchi na mawasiliano ya afisa wa faragha bado vinahitaji kuthibitishwa. Unaweza kuomba kuona, kusahihisha, kufuta, kuzuia au kuhamisha data, au kupinga uchakataji. Rekodi za biashara zinaweza kuhitaji kuhifadhiwa kisheria; ombi la kufuta litakaguliwa na halifuti rekodi hizo moja kwa moja.'
              : 'Retention periods, hosting/SMS/analytics providers, cross-border storage and the privacy officer’s contact still need confirmation. You can request access, correction, deletion, restriction or portability, or object to processing. Trade records may have legal retention requirements; a deletion request is reviewed and does not automatically erase such records.'),
          const SizedBox(height: 12),
          Text(sw
              ? 'Toleo $_noticeVersion. Hili ni taarifa ya bidhaa ya rasimu, si ushauri wa kisheria wala uthibitisho wa kufuata sheria.'
              : 'Version $_noticeVersion. This product notice is a draft, not legal advice or a certification of compliance.'),
          if (authenticated) ...[
            const Divider(height: 36),
            Text(sw ? 'Tumia haki zako' : 'Use your data rights',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.download_outlined),
              label: Text(sw
                  ? 'Onyesha na nakili data yangu'
                  : 'View and copy my data export'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _requestType,
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
              decoration: InputDecoration(
                  labelText: sw ? 'Aina ya ombi' : 'Request type'),
            ),
            TextField(
              controller: _details,
              maxLength: 2000,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: sw ? 'Maelezo ya hiari' : 'Details (optional)'),
            ),
            FilledButton(
              onPressed: _busy ? null : _submitRequest,
              child: Text(
                  sw ? 'Tuma ombi kwa ukaguzi' : 'Submit request for review'),
            ),
            const SizedBox(height: 8),
            Text(sw
                ? 'Ombi linahifadhiwa kama “limepokelewa”; mhudumu anapaswa kulikagua. Halifuti data moja kwa moja.'
                : 'Requests are recorded as received for an operator to review. This form does not automatically delete data.'),
          ],
        ],
      ),
    );
  }
}

const _noticeVersion = '2026-10-draft-1';
