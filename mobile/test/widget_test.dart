import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhahabu/features/auth/screens/login_screen.dart';
import 'package:dhahabu/core/providers/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login screen builds successfully', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettingsProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });
}
