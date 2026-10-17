import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/features/auth/screens/login_screen.dart';
import 'package:dhahabu/core/providers/app_settings_provider.dart';
import 'package:dhahabu/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingAuthProvider extends AuthProvider {
  @override
  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    throw Exception('Invalid credentials');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> showLoginScreen(WidgetTester tester, {AuthProvider? authProvider}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider ?? AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty email and password show validation without API call',
      (tester) async {
    await showLoginScreen(tester);

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
  });

  testWidgets('failed sign-in shows the server error and clears loading',
      (tester) async {
    await showLoginScreen(tester, authProvider: _FailingAuthProvider());

    await tester.enterText(find.byType(TextField).at(0), 'miner@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(signInButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(signInButton).onPressed, isNotNull);
  });
}
