import 'package:dhahabu/features/auth/providers/auth_provider.dart';
import 'package:dhahabu/features/auth/screens/register_screen.dart';
import 'package:dhahabu/core/providers/app_settings_provider.dart';
import 'package:dhahabu/l10n/l10n.dart';
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
    required bool privacyNoticeAcknowledged,
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

  testWidgets('registration requires acknowledging privacy notice first',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(arguments: 'miner'),
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(
      find.text('Read and acknowledge the privacy notice to continue.'),
      findsOneWidget,
    );
  });

  testWidgets('accepting privacy notice from policy screen enables signup',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(arguments: 'miner'),
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I have read and agree to the privacy notice'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy and data'), findsOneWidget);

    final acceptButton = find.text('Agree and return');
    await tester.ensureVisible(acceptButton);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Read and acknowledge the privacy notice to continue.'),
        findsNothing);
  });

  testWidgets('registration requires a role before submitting', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox), warnIfMissed: false);
    await tester.pumpAndSettle();

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(
      find.text('Role not specified. Please go back and select a role.'),
      findsOneWidget,
    );
  });

  testWidgets('mismatched passwords are rejected before registration',
      (tester) async {
    final auth = _TrackingAuthProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(arguments: 'miner'),
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox), warnIfMissed: false);
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

  testWidgets('valid registration submits details and opens home',
      (tester) async {
    final auth = _TrackingAuthProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(arguments: 'miner'),
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
          routes: {
            '/home': (_) => const Scaffold(body: Text('Home destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox), warnIfMissed: false);
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
    expect(find.text('Home destination'), findsOneWidget);
  });

  testWidgets('dealer registration submits dealer role after privacy consent',
      (tester) async {
    final auth = _TrackingAuthProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(arguments: 'dealer'),
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
          routes: {
            '/home': (_) => const Scaffold(body: Text('Home destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.text('Register as Dealer'), findsOneWidget);

    const values = [
      'Asha Dealer',
      'asha@example.com',
      '0712345679',
      'correct-horse',
      'correct-horse',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    await tester.tap(find.text('I have read and agree to the privacy notice'));
    await tester.pumpAndSettle();
    final acceptButton = find.text('Agree and return');
    await tester.ensureVisible(acceptButton);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    final createAccountButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(auth.registerCalled, isTrue);
    expect(auth.submittedDetails?['role'], 'dealer');
    expect(find.text('Home destination'), findsOneWidget);
  });
}
