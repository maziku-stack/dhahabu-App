import 'package:dhahabu/providers/auth_provider.dart';
import 'package:dhahabu/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TrackingAuthProvider extends AuthProvider {
  bool registerCalled = false;
  Map<String, String>? submittedDetails;

  @override
  Future<void> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) async {
    registerCalled = true;
    submittedDetails = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
    };
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('registration requires a role before submitting', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(
      find.text('Choose whether you are a miner or dealer.'),
      findsOneWidget,
    );
  });

  testWidgets('mismatched passwords are rejected before registration',
      (tester) async {
    final auth = _TrackingAuthProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Miner'));
    await tester.pumpAndSettle();

    const values = [
      'Amina Tester',
      'amina@example.com',
      '0712345678',
      'correct-horse',
      'different-password',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(auth.registerCalled, isFalse);
  });

  testWidgets('valid registration submits details and opens PIN setup',
      (tester) async {
    final auth = _TrackingAuthProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp(
          home: const RegisterScreen(),
          routes: {
            '/set-pin': (_) => const Scaffold(body: Text('PIN setup destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Miner'));
    await tester.pumpAndSettle();
    const values = [
      ' Amina Tester ',
      ' amina@example.com ',
      '0712345678',
      'correct-horse',
      'correct-horse',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(auth.registerCalled, isTrue);
    expect(auth.submittedDetails?['fullName'], 'Amina Tester');
    expect(auth.submittedDetails?['email'], 'amina@example.com');
    expect(auth.submittedDetails?['role'], 'miner');
    expect(find.text('PIN setup destination'), findsOneWidget);
  });
}
