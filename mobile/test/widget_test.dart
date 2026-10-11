import 'package:flutter_test/flutter_test.dart';
import 'package:dhahabu/main.dart';

void main() {
  testWidgets('Dhahabu app builds its Material shell', (tester) async {
    await tester.pumpWidget(const DhahabuApp());

    expect(find.text('0'), findsNothing);
    expect(find.byType(DhahabuApp), findsOneWidget);
  });
}
