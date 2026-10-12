import 'package:dhahabu/providers/auth_provider.dart';
import 'package:dhahabu/screens/auth/login_screen.dart';
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

  Future<void> showLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
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

    expect(find.text('Enter your email and password.'), findsOneWidget);
  });

  testWidgets('short phone number is rejected before requesting an OTP',
      (tester) async {
    await showLoginScreen(tester);
    await tester.tap(find.text('Phone code'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123');
    final sendOtpButton = find.widgetWithText(ElevatedButton, 'Send OTP');
    await tester.ensureVisible(sendOtpButton);
    await tester.tap(sendOtpButton);
    await tester.pump();

    expect(find.text('Enter a valid phone number'), findsOneWidget);
  });

  testWidgets('failed sign-in shows the server error and clears loading',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _FailingAuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

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
