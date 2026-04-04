import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapia/main.dart';

void main() {
  testWidgets('Mapia app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MapiaApp()));

    // Verify that the app title is present
    expect(find.text('Mapia'), findsAtLeast(1));
  });
}
