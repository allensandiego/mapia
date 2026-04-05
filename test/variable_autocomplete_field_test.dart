import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapia/core/widgets/variable_autocomplete_field.dart';
import 'package:mapia/core/widgets/variable_text_editing_controller.dart';
import 'package:mapia/core/theme/app_theme.dart';

void main() {
  testWidgets('VariableAutocompleteField shows overlay when typing {{',
      (WidgetTester tester) async {
    final controller = VariableTextEditingController();
    final envVars = ['BASE_URL', 'API_KEY', 'TOKEN'];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: VariableAutocompleteField(
            controller: controller,
            envVars: envVars,
          ),
        ),
      ),
    );

    // Request focus and enter {{
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '{{');
    await tester.pump();

    // Verify overlay is shown with all matches
    expect(
        find.byKey(const Key('variable_autocomplete_overlay')), findsOneWidget);
    expect(find.text('{{BASE_URL}}', findRichText: true), findsOneWidget);
    expect(find.text('{{API_KEY}}', findRichText: true), findsOneWidget);
    expect(find.text('{{TOKEN}}', findRichText: true), findsOneWidget);
  });

  testWidgets('VariableAutocompleteField filters matches when typing',
      (WidgetTester tester) async {
    final controller = VariableTextEditingController();
    final envVars = ['BASE_URL', 'API_KEY', 'TOKEN'];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: VariableAutocompleteField(
            controller: controller,
            envVars: envVars,
          ),
        ),
      ),
    );

    // Request focus and enter {{B
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '{{B');
    await tester.pump();

    // Verify overlay is shown with only BASE_URL
    expect(
        find.byKey(const Key('variable_autocomplete_overlay')), findsOneWidget);
    expect(find.text('{{BASE_URL}}', findRichText: true), findsOneWidget);
    expect(find.text('{{API_KEY}}', findRichText: true), findsNothing);
    expect(find.text('{{TOKEN}}', findRichText: true), findsNothing);
  });

  testWidgets('VariableAutocompleteField selects variable on tap',
      (WidgetTester tester) async {
    final controller = VariableTextEditingController();
    final envVars = ['BASE_URL'];
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: VariableAutocompleteField(
            controller: controller,
            envVars: envVars,
            onChanged: (v) => changedValue = v,
          ),
        ),
      ),
    );

    // Request focus and enter {{
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '{{');
    await tester.pump();

    // Tap on the autocomplete tile
    await tester.tap(find.text('{{BASE_URL}}', findRichText: true));
    await tester.pump();

    // Verify text is updated and overlay is hidden
    expect(controller.text, '{{BASE_URL}}');
    expect(changedValue, '{{BASE_URL}}');
    expect(
        find.byKey(const Key('variable_autocomplete_overlay')), findsNothing);
  });
}
