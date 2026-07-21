import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:gema/features/onboarding/screens/onboarding_screen.dart';

class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? launchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}

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

  testWidgets(
    'tapping the AI Studio link on step 4 opens the URL externally',
    (tester) async {
      final fakeLauncher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fakeLauncher;

      await pumpOnboarding(tester);

      // Advance to step 3 (index), the API key / config step.
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
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-aistudio-link')));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrl, 'https://aistudio.google.com');
    },
  );

  testWidgets(
    'step 4 shows the current API-key format and rate limits, not the stale ones',
    (tester) async {
      await pumpOnboarding(tester);

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
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Stale copy must be gone.
      expect(find.textContaining('AIza'), findsNothing);
      expect(find.textContaining('1.000/dia'), findsNothing);

      // Current copy must be present.
      expect(find.textContaining('AQ'), findsWidgets);
      expect(find.textContaining('1.500/dia'), findsOneWidget);
      expect(find.textContaining('gratuito'), findsWidgets);
    },
  );
}
