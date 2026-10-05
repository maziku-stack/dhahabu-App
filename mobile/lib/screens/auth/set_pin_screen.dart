import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});
  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    if (_pin.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().setPin(_pin.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your PIN unlocks the app and confirms high-value actions like sale confirmation.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error)),
            TextField(controller: _pin, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN')),
            const SizedBox(height: 12),
            TextField(controller: _confirm, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Confirm PIN')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loading ? null : _save, child: Text(_loading ? '…' : 'Save PIN & continue')),
          ],
        ),
      ),
    );
  }
}
