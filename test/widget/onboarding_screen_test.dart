import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/onboarding/screens/onboarding_screen.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
    );
    await tester.pumpAndSettle();
  }

  bool isButtonEnabled(WidgetTester tester) {
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    return button.onPressed != null;
  }

  testWidgets(
    'setting field text directly (paste-equivalent) enables Continuar without extra interaction',
    (tester) async {
      await pumpOnboarding(tester);

      // Step 0 (physical data): nothing filled in yet.
      expect(isButtonEnabled(tester), isFalse);

      // enterText replaces the whole field value at once, like a paste — no keystroke events.
      await tester.enterText(
        find.byKey(const Key('onboarding-weight-field')),
        '80',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-height-field')),
        '178',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-age-field')),
        '30',
      );
      await tester.pump();

      expect(isButtonEnabled(tester), isTrue);

      // Step 0 -> 1 (body composition, always advanceable).
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(isButtonEnabled(tester), isTrue);

      // Step 1 -> 2 (goal; deficit field is pre-filled with '500', already advanceable).
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(isButtonEnabled(tester), isTrue);

      // Step 2 -> 3 (API key).
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(isButtonEnabled(tester), isFalse);

      await tester.enterText(
        find.byKey(const Key('onboarding-api-key-field')),
        'AIzaPastedKeyExample',
      );
      await tester.pump();

      expect(isButtonEnabled(tester), isTrue);
    },
  );
}
