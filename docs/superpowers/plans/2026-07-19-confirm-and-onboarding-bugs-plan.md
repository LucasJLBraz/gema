# Confirm-Screen Discard & Onboarding Reactivity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two reliability bugs — meals silently persisted without user confirmation, and the onboarding "Continuar" button not reacting to pasted text — by wiring an explicit discard path in `ConfirmMealScreen` and scoping button reactivity to all onboarding text controllers via `ListenableBuilder`.

**Architecture:** Both fixes reuse existing infrastructure rather than adding new abstractions. Bug #5 extends the `MealQueueNotifier.deleteMeal` method (already used by swipe-to-delete elsewhere in the app) to also remove the associated photo file, then wires it to `ConfirmMealScreen`'s close button and Android back gesture via `PopScope`. Bug #6 wraps the onboarding screen's single navigation button in a `ListenableBuilder` listening to all five `TextEditingController`s, so any programmatic text change (paste, autofill, voice dictation) re-evaluates button state — without rebuilding the rest of the screen.

**Tech Stack:** Flutter, Riverpod (`riverpod_annotation` generated providers), Isar (local reactive DB), `go_router`.

## Global Constraints

- No new value is added to `MealStatus` (`provisional | queued | processing | done | error`, per CLAUDE.md) — discarding a meal is a physical Isar delete, not a new status.
- Discarding a meal never cancels an in-flight Gemini HTTP request. `MealQueueNotifier.applyGeminiResult` already guards against a missing meal (`if (meal == null) return;` at `lib/features/meals/providers/meal_provider.dart:121`) — a late-arriving result for a discarded meal is a no-op with no code changes needed there.
- The onboarding reactivity fix must use one unified pattern (`ListenableBuilder` merging all controllers) across the whole screen — not a per-field patch — per the approved spec.
- Follow the project's existing test-tier convention from CLAUDE.md: pure-Dart logic → `test/unit/`; anything touching Isar or widgets → `test/widget/`. This plan is the first to exercise Isar in a test, so it opens a real `Isar` instance in a `Directory.systemTemp` temp dir per test (no mocking library is present in `pubspec.yaml`, and Isar has no official Flutter-independent mock — a real temp-dir instance is the standard approach for this database).

---

### Task 1: Extend `deleteMeal` to also remove the associated photo file

**Files:**
- Modify: `lib/features/meals/providers/meal_provider.dart:1-8` (imports), `:188-193` (`deleteMeal`)
- Test: `test/widget/meal_provider_test.dart` (new)

**Interfaces:**
- Consumes: `db.isar` (global mutable `late Isar isar` from `lib/core/db/database.dart:12`), `Meal`/`MealSource`/`MealStatus`/`MealComponentSchema` from `lib/features/meals/models/meal.dart`, `mealQueueNotifierProvider` from `lib/features/meals/providers/meal_provider.dart`.
- Produces: `MealQueueNotifier.deleteMeal(int mealId)` — same signature as today, now also deletes `meal.photoPath` from disk if present. Existing callers (`lib/features/home/widgets/meal_list_tile.dart:61`, `lib/features/meals/widgets/meal_detail_sheet.dart:252`) need no changes.

- [ ] **Step 1: Write the failing test**

Create `test/widget/meal_provider_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gema_meal_provider_test_');
    db.isar = await Isar.open(
      [MealSchema, MealComponentSchema],
      directory: tempDir.path,
    );
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('deleteMeal removes the Isar record and the associated photo file', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final photoFile = File('${tempDir.path}/meal_test.jpg')
      ..writeAsStringSync('fake-jpeg-bytes');

    final mealId = await notifier.createMeal(
      source: MealSource.aiPhoto,
      photoPath: photoFile.path,
    );

    expect(await db.isar.meals.get(mealId), isNotNull);
    expect(await photoFile.exists(), isTrue);

    await notifier.deleteMeal(mealId);

    expect(await db.isar.meals.get(mealId), isNull);
    expect(await photoFile.exists(), isFalse);
  });

  test('deleteMeal does not throw when photoPath is null', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final mealId = await notifier.createMeal(
      source: MealSource.manual,
      photoPath: null,
    );

    await notifier.deleteMeal(mealId);

    expect(await db.isar.meals.get(mealId), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/meal_provider_test.dart`
Expected: the first test FAILS at `expect(await photoFile.exists(), isFalse)` (photo file is still present — current `deleteMeal` only removes the Isar record). The second test PASSES already (no behavior change needed for the null case).

- [ ] **Step 3: Implement the photo cleanup**

In `lib/features/meals/providers/meal_provider.dart`, add the import at the top of the file (after line 1):

```dart
import 'dart:io';

import 'package:isar/isar.dart';
```

Replace `deleteMeal` (currently at lines 188-193):

```dart
  Future<void> deleteMeal(int mealId) async {
    final meal = await isar.meals.get(mealId);
    if (meal?.photoPath != null) {
      final photoFile = File(meal!.photoPath!);
      if (await photoFile.exists()) await photoFile.delete();
    }
    await isar.writeTxn(() async {
      await isar.meals.delete(mealId);
    });
    ref.invalidateSelf();
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/meal_provider_test.dart`
Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/meals/providers/meal_provider.dart test/widget/meal_provider_test.dart
git commit -m "fix: delete photo file when a meal is deleted"
```

---

### Task 2: Wire discard-on-exit into `ConfirmMealScreen` (X button + Android back gesture)

**Files:**
- Modify: `lib/features/meals/screens/confirm_meal_screen.dart:21-25` (state fields — no change needed, listed for context), `:151-198` (add `_discardAndExit`, wrap `build`'s return value, update the close button)
- Test: `test/widget/confirm_meal_screen_test.dart` (new)

**Interfaces:**
- Consumes: `MealQueueNotifier.deleteMeal(int mealId)` from Task 1.
- Produces: no new public API — this task only changes `ConfirmMealScreen`'s internal navigation behavior.

- [ ] **Step 1: Write the failing test**

Create `test/widget/confirm_meal_screen_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/screens/confirm_meal_screen.dart';

// 1x1 valid JPEG, so Image.file can decode it without erroring in the widget tree.
const _tinyJpegBase64 =
    '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAj/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gema_confirm_screen_test_');
    db.isar = await Isar.open(
      [MealSchema, MealComponentSchema],
      directory: tempDir.path,
    );
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<(int mealId, File photoFile)> seedDoneMeal() async {
    final photoFile = File('${tempDir.path}/meal.jpg')
      ..writeAsBytesSync(base64Decode(_tinyJpegBase64));
    final now = DateTime.now();
    final meal = Meal()
      ..capturedAt = now
      ..photoPath = photoFile.path
      ..source = MealSource.manual
      ..status = MealStatus.done
      ..kcalPoint = 500
      ..createdAt = now
      ..updatedAt = now;
    await db.isar.writeTxn(() => db.isar.meals.put(meal));
    return (meal.id, photoFile);
  }

  Future<void> pumpConfirmScreen(WidgetTester tester, int mealId) async {
    final router = GoRouter(
      initialLocation: '/confirm',
      routes: [
        GoRoute(
          path: '/confirm',
          builder: (_, __) => ConfirmMealScreen(mealId: mealId),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the close button deletes the meal and its photo, then goes home', (
    tester,
  ) async {
    final (mealId, photoFile) = await seedDoneMeal();
    await pumpConfirmScreen(tester, mealId);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(await db.isar.meals.get(mealId), isNull);
    expect(await photoFile.exists(), isFalse);
  });

  testWidgets('system back gesture deletes the meal and its photo, then goes home', (
    tester,
  ) async {
    final (mealId, photoFile) = await seedDoneMeal();
    await pumpConfirmScreen(tester, mealId);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(await db.isar.meals.get(mealId), isNull);
    expect(await photoFile.exists(), isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/confirm_meal_screen_test.dart`
Expected: both tests FAIL — the close button currently only navigates (meal and photo remain), and the back gesture currently pops normally without deleting anything (or is unhandled since there's no `PopScope`).

- [ ] **Step 3: Implement the discard wiring**

In `lib/features/meals/screens/confirm_meal_screen.dart`, add a new method right after `_save` (currently lines 147-149):

```dart
  Future<void> _discardAndExit() async {
    await ref.read(mealQueueNotifierProvider.notifier).deleteMeal(widget.mealId);
    if (mounted) context.go('/home');
  }
```

Change the close button's `onPressed` (currently line 195, inside the `AppBar`'s `leading: IconButton`):

```dart
          onPressed: _discardAndExit,
```

Wrap the `build` method's returned `Scaffold` in a `PopScope`. The method currently starts with `return Scaffold(` (line 190) and ends with the matching `);` (line 494). Change the opening to:

```dart
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _discardAndExit();
      },
      child: Scaffold(
```

and the closing `);` at the end of `build` to:

```dart
      ),
    );
```

(Everything between — the `appBar:`/`body:` content — is unchanged, just nested one level deeper inside `child:`.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/confirm_meal_screen_test.dart`
Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/meals/screens/confirm_meal_screen.dart test/widget/confirm_meal_screen_test.dart
git commit -m "fix: discard unconfirmed meal on close button and back gesture"
```

---

### Task 3: Make the onboarding "Continuar" button reactive to pasted/programmatic text

**Files:**
- Modify: `lib/features/onboarding/screens/onboarding_screen.dart:192-207` (button wrapping), `:279-283` (weight/height/age field keys), `:515-528` (API key field key), `:587-598` (`_field` helper signature)
- Test: `test/widget/onboarding_screen_test.dart` (new)

**Interfaces:**
- Consumes: nothing new — pure UI reactivity fix, no provider/model changes.
- Produces: no new public API. Adds test-only `Key`s: `onboarding-weight-field`, `onboarding-height-field`, `onboarding-age-field`, `onboarding-api-key-field`.

- [ ] **Step 1: Write the failing test**

Create `test/widget/onboarding_screen_test.dart`:

```dart
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
      await tester.enterText(find.byKey(const Key('onboarding-weight-field')), '80');
      await tester.enterText(find.byKey(const Key('onboarding-height-field')), '178');
      await tester.enterText(find.byKey(const Key('onboarding-age-field')), '30');
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: FAIL — `find.byKey(const Key('onboarding-weight-field'))` finds nothing yet (keys don't exist), and even after adding keys in a later attempt, the button would stay disabled after `enterText` since nothing rebuilds it today.

- [ ] **Step 3: Add field keys**

In `lib/features/onboarding/screens/onboarding_screen.dart`, update the `_field` helper (currently lines 587-598) to accept an optional key:

```dart
Widget _field(
  BuildContext context,
  TextEditingController ctrl,
  String label,
  TextInputType type, {
  Key? key,
}) {
  return TextField(
    key: key,
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(labelText: label),
  );
}
```

In `_StepPhysical.build` (currently lines 279-283), pass keys to the three calls:

```dart
          _field(
            context,
            weightCtrl,
            'Peso atual (kg)',
            TextInputType.number,
            key: const Key('onboarding-weight-field'),
          ),
          const SizedBox(height: 14),
          _field(
            context,
            heightCtrl,
            'Altura (cm)',
            TextInputType.number,
            key: const Key('onboarding-height-field'),
          ),
          const SizedBox(height: 14),
          _field(
            context,
            ageCtrl,
            'Idade',
            TextInputType.number,
            key: const Key('onboarding-age-field'),
          ),
```

In `_StepConfig.build` (currently lines 515-528), add a key to the API key `TextField`:

```dart
          TextField(
            key: const Key('onboarding-api-key-field'),
            controller: apiKeyCtrl,
            obscureText: !visible,
```

- [ ] **Step 4: Scope button reactivity with `ListenableBuilder`**

Replace the bottom button block (currently lines 192-207):

```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _weightCtrl,
                    _heightCtrl,
                    _ageCtrl,
                    _deficitCtrl,
                    _apiKeyCtrl,
                  ]),
                  builder: (context, _) => ElevatedButton(
                    onPressed: _saving || !_canAdvance() ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_page < 3 ? 'Continuar' : 'Começar'),
                  ),
                ),
              ),
            ),
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/screens/onboarding_screen.dart test/widget/onboarding_screen_test.dart
git commit -m "fix: make onboarding Continuar button react to pasted/programmatic text"
```

---

### Task 4: Full verification pass

**Files:** none (verification only)

- [ ] **Step 1: Run static analysis**

Run: `flutter analyze`
Expected: no new errors or warnings introduced by Tasks 1-3.

- [ ] **Step 2: Run the full test suite**

Run: `flutter test`
Expected: all tests PASS, including `test/unit/algorithms_test.dart` and the three new files under `test/widget/`.

- [ ] **Step 3: Manual smoke test on the emulator**

Start the emulator and app per CLAUDE.md's commands section (`emulator -avd gema_emulator -no-snapshot-load &`, `adb wait-for-device`, `flutter run`). Verify by hand:
- Capture or pick a meal photo, then tap the X on the confirm screen — the meal must not appear on the home screen, and its photo file must not remain in `getApplicationDocumentsDirectory()`.
- Repeat, this time pressing the Android back gesture instead of X — same result.
- On a fresh onboarding flow, paste a value into each of the weight/height/age/API-key fields (e.g., from the clipboard) instead of typing — the "Continuar"/"Começar" button must enable immediately after each paste.

No code changes expected from this step — it is a confirmation gate before considering the two bugs closed.
