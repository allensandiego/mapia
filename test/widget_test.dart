import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapia/main.dart';
import 'package:mapia/core/services/storage_service.dart';

class MockStorageService implements StorageService {
  @override
  Future<void> save(String key, String data) async {}
  @override
  Future<String?> load(String key) async => null;
  @override
  Future<void> delete(String key) async {}
}

void main() {
  testWidgets('Mapia app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(MockStorageService()),
        ],
        child: const MapiaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the app title is present (either in app bar or empty state)
    expect(find.text('Mapia'), findsAtLeast(1));
  });
}
