import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shahirizada/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(child: ShahirizadaApp()));

    // Verify app starts (basic smoke test)
    expect(find.text('Shahirizada'), findsOneWidget);
  });
}
