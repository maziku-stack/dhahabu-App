import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhahabu/main.dart';

void main() {
  testWidgets('Dhahabu app builds its Material shell', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DhahabuApp());
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(DhahabuApp), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
