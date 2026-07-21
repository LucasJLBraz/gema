# Unify Camera/Gallery Context Flow + Flash Toggle — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the native-camera capture flow ask for meal context the same way the gallery flow already does, fix a latent bug where the "Pular" button silently kept typed text instead of discarding it, and add a two-state flash toggle to the in-app camera.

**Architecture:** All changes are confined to `lib/features/meals/screens/capture_screen.dart`. The existing gallery-only context bottom sheet (`_GalleryContextSheet`) becomes a shared, public widget (`MealContextSheet`) used by both the camera-capture and gallery-pick code paths through one new shared method, `_handleCapturedPhoto`. The per-screen duplicate speech-to-text wiring in the main screen state is deleted — STT now lives only inside `MealContextSheet`.

**Tech Stack:** Flutter/Dart, `camera` package (`CameraController`, `FlashMode`), `image_picker`, `speech_to_text`, `flutter_test`.

## Global Constraints

- This change **must** ship via Pull Request — do not squash-merge directly to `main` like the rest of the backlog (per `docs/superpowers/specs/2026-07-21-unify-camera-context-flash-design.md`, "Processo de integração").
- `flutter analyze` must pass before considering the branch complete (project-wide rule, `CLAUDE.md`).
- Generated files (`*.g.dart`) are not touched by this work — no schema changes involved.
- No new pub dependencies.

---

### Task 1: Create the working branch and confirm baseline is green

**Files:** none (repo-level setup)

- [ ] **Step 1: Confirm the working tree is clean**

Run: `git status --short`
Expected: no output (clean tree). If there's unexpected output, stop and investigate before proceeding — do not discard anything without checking with the user first.

- [ ] **Step 2: Create and switch to the feature branch**

```bash
git checkout -b unify-camera-context-and-flash
```

- [ ] **Step 3: Run the full test suite to confirm a green baseline**

Run: `flutter test`
Expected: all tests pass (same count as `main`, no pre-existing failures).

---

### Task 2: Make the context sheet shared and fix the "Pular" bug

**Files:**
- Modify: `lib/features/meals/screens/capture_screen.dart` (class `_GalleryContextSheet` → `MealContextSheet`, `_GalleryContextSheetState` → `_MealContextSheetState`)
- Test: `test/widget/capture_screen_test.dart` (create)

**Interfaces:**
- Produces: `class MealContextSheet extends StatefulWidget` with constructor `MealContextSheet({required String existingNote})` — public so it can be pumped directly from a test file in a different library, and so Task 3 can reference it from both call sites. Returns `String?` via `Navigator.pop` when used with `showModalBottomSheet<String>`: `null` when the user taps "Pular" (text discarded), the typed text when the user taps "Adicionar".

The current code (`capture_screen.dart:370-528`) has the bug: both buttons call `Navigator.of(context).pop(_ctrl.text)`, so "Pular" doesn't actually discard anything. Fix it and rename the class/state in the same pass.

- [ ] **Step 1: Write the failing test**

Create `test/widget/capture_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/meals/screens/capture_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sttChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sttChannel, (call) async {
      if (call.method == 'initialize') return false;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sttChannel, null);
  });

  Future<String?> pumpSheetAndTap(
    WidgetTester tester, {
    required String existingNote,
    required String buttonLabel,
    String? typeText,
  }) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => MealContextSheet(existingNote: existingNote),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    if (typeText != null) {
      await tester.enterText(find.byType(TextField), typeText);
      await tester.pump();
    }

    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Pular descarta o texto digitado', (tester) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: '',
      buttonLabel: 'Pular',
      typeText: 'frango grelhado',
    );
    expect(result == null || result!.isEmpty, isTrue);
  });

  testWidgets('Adicionar devolve o texto digitado', (tester) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: '',
      buttonLabel: 'Adicionar',
      typeText: 'frango grelhado',
    );
    expect(result, 'frango grelhado');
  });

  testWidgets('Pular descarta mesmo quando já havia nota existente', (
    tester,
  ) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: 'nota antiga',
      buttonLabel: 'Pular',
      typeText: 'texto novo digitado',
    );
    expect(result == null || result!.isEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/capture_screen_test.dart`
Expected: FAIL — compile error, `MealContextSheet` isn't defined yet (the class is still private `_GalleryContextSheet`).

- [ ] **Step 3: Rename the class/state and fix the "Pular" button**

In `lib/features/meals/screens/capture_screen.dart`, replace:

```dart
class _GalleryContextSheet extends StatefulWidget {
  const _GalleryContextSheet({required this.existingNote});
  final String existingNote;

  @override
  State<_GalleryContextSheet> createState() => _GalleryContextSheetState();
}

class _GalleryContextSheetState extends State<_GalleryContextSheet> {
```

with:

```dart
class MealContextSheet extends StatefulWidget {
  const MealContextSheet({super.key, required this.existingNote});
  final String existingNote;

  @override
  State<MealContextSheet> createState() => _MealContextSheetState();
}

class _MealContextSheetState extends State<MealContextSheet> {
```

Then replace the two buttons at the bottom of the same widget's `build`:

```dart
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(_ctrl.text),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Pular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_ctrl.text),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Adicionar'),
                ),
              ),
```

with:

```dart
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Pular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_ctrl.text),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Adicionar'),
                ),
              ),
```

Also update the one remaining reference to the old private name — inside `_pickFromGallery`, the `builder:` line:

```dart
      builder: (_) => _GalleryContextSheet(existingNote: _noteCtrl.text),
```

becomes:

```dart
      builder: (_) => MealContextSheet(existingNote: _noteCtrl.text),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/capture_screen_test.dart`
Expected: PASS (3/3).

- [ ] **Step 5: Commit**

```bash
git add lib/features/meals/screens/capture_screen.dart test/widget/capture_screen_test.dart
git commit -m "fix: rename gallery context sheet to shared MealContextSheet, fix Pular discarding text"
```

---

### Task 3: Unify the camera-capture path through the shared context sheet

**Files:**
- Modify: `lib/features/meals/screens/capture_screen.dart`

**Interfaces:**
- Consumes: `MealContextSheet` from Task 2 (constructor `MealContextSheet({required String existingNote})`, resolves via `showModalBottomSheet<String>`).
- Produces: `Future<void> _handleCapturedPhoto(String sourcePath)` on `_CaptureScreenState` — used by both `_capture()` and `_pickFromGallery()`; Task 4 does not depend on this method.

This removes the top-of-screen `TextField` and the main screen's own duplicate speech-to-text plumbing (`_stt`, `_sttAvailable`, `_listening`, `_initStt`, `_toggleListening`, the "Ouvindo…" indicator), since that logic now lives only inside `MealContextSheet`. No test-facing behavior changes here beyond what Task 2 already locks in (`MealContextSheet`'s own contract) — this task is covered by the manual smoke test in Task 5, because exercising it end-to-end requires a real `CameraController`, which isn't available on the test host (see Task 5 for why this is a deliberate scoping decision, not a gap).

- [ ] **Step 1: Remove the duplicate STT fields and methods from `_CaptureScreenState`**

Remove these fields from the top of `_CaptureScreenState` (right after `final _noteCtrl = TextEditingController();`):

```dart
  final _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _listening = false;
```

Remove the `_initStt()` call from `initState`:

```dart
  @override
  void initState() {
    super.initState();
    _initCamera();
    _initStt();
  }
```

becomes:

```dart
  @override
  void initState() {
    super.initState();
    _initCamera();
  }
```

Remove the whole `_initStt` method:

```dart
  Future<void> _initStt() async {
    final ok = await _stt.initialize();
    if (mounted) setState(() => _sttAvailable = ok);
  }

```

Remove `_stt.stop();` from `dispose`:

```dart
  @override
  void dispose() {
    _noteCtrl.dispose();
    _controller?.dispose();
    _stt.stop();
    super.dispose();
  }
```

becomes:

```dart
  @override
  void dispose() {
    _noteCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }
```

Remove the whole `_toggleListening` method from `_CaptureScreenState` (the one right before `_capture()` — do not touch the one inside `_MealContextSheetState`, further down the file, which is unrelated and must stay):

```dart
  Future<void> _toggleListening() async {
    if (!_sttAvailable) return;
    if (_listening) {
      // Second tap: stop and commit whatever was recognized
      await _stt.stop();
      setState(() => _listening = false);
    } else {
      setState(() => _listening = true);
      await _stt.listen(
        onResult: (r) {
          // Update field live with every partial result
          _noteCtrl.text = r.recognizedWords;
          _noteCtrl.selection = TextSelection.collapsed(
            offset: _noteCtrl.text.length,
          );
          if (r.finalResult) setState(() => _listening = false);
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 30),
          localeId: 'pt_BR',
        ),
      );
    }
  }

```

- [ ] **Step 2: Add the shared `_handleCapturedPhoto` method and wire `_capture`/`_pickFromGallery` to it**

Replace:

```dart
  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final xFile = await _controller!.takePicture();
      await _saveMealFromPath(xFile.path);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao capturar: $e');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null || !mounted) return;

    // Let user add context before processing the gallery image
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealContextSheet(existingNote: _noteCtrl.text),
    );
    if (!mounted) return;
    if (note != null) _noteCtrl.text = note;
    await _saveMealFromPath(xFile.path);
  }
```

with:

```dart
  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final xFile = await _controller!.takePicture();
      await _handleCapturedPhoto(xFile.path);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao capturar: $e');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null || !mounted) return;
    await _handleCapturedPhoto(xFile.path);
  }

  // Shared by both the camera shutter and the gallery pick, so the two
  // paths always ask for context the same way.
  Future<void> _handleCapturedPhoto(String sourcePath) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealContextSheet(existingNote: _noteCtrl.text),
    );
    if (!mounted) return;
    if (note != null && note.isNotEmpty) _noteCtrl.text = note;
    await _saveMealFromPath(sourcePath);
  }
```

- [ ] **Step 3: Remove the top-of-screen `TextField` and "Ouvindo…" indicator, replace with a plain back button row**

Replace the whole top-bar block:

```dart
              // Top bar: back + note + mic
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _noteCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Descrição opcional...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          suffixIcon: _sttAvailable
                              ? IconButton(
                                  icon: Icon(
                                    _listening ? Icons.mic : Icons.mic_none,
                                    color: _listening
                                        ? Colors.redAccent
                                        : Colors.white70,
                                  ),
                                  onPressed: _toggleListening,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_listening)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Ouvindo…',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
```

with (the flash button here is a placeholder wired to a no-op — Task 4 fills in the real toggle so this task stays independently testable/compilable):

```dart
              // Top bar: back + flash toggle
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
```

- [ ] **Step 4: Remove the now-unused `speech_to_text` import check and run analyze**

`SpeechToText` is still used inside `_MealContextSheetState`, so the import stays. Run:

Run: `flutter analyze lib/features/meals/screens/capture_screen.dart`
Expected: no new warnings/errors (there may be a pre-existing baseline of unrelated issues elsewhere in the project per `CLAUDE.md` — only check this file's output has none).

- [ ] **Step 5: Run the full test suite**

Run: `flutter test`
Expected: all tests pass, same as Task 1's baseline plus the 3 new tests from Task 2.

- [ ] **Step 6: Commit**

```bash
git add lib/features/meals/screens/capture_screen.dart
git commit -m "refactor: unify camera-capture path through the shared context sheet"
```

---

### Task 4: Add the two-state flash toggle

**Files:**
- Modify: `lib/features/meals/screens/capture_screen.dart`

**Interfaces:**
- Consumes: `_controller` (`CameraController?`, already a field on `_CaptureScreenState`), `_CircleBtn` widget (already defined in this file, constructor `_CircleBtn({required IconData icon, required double size, required VoidCallback onTap, required String tooltip})`).
- Produces: `bool _flashOn` field and `Future<void> _toggleFlash()` method on `_CaptureScreenState`. Nothing else depends on these.

- [ ] **Step 1: Add the `_flashOn` field**

Add next to the other state fields in `_CaptureScreenState`:

```dart
  bool _capturing = false;
  String? _error;
  final _noteCtrl = TextEditingController();
  bool _flashOn = false;
```

(insert `bool _flashOn = false;` right after the existing `final _noteCtrl = TextEditingController();` line)

- [ ] **Step 2: Add the `_toggleFlash` method**

Add right after `_capture()`:

```dart
  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final next = !_flashOn;
    try {
      await _controller!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao ajustar o flash: $e');
    }
  }
```

- [ ] **Step 3: Wire the flash button into the top bar**

Replace the top bar `Row` added in Task 3:

```dart
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
```

with:

```dart
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    _CircleBtn(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      size: 44,
                      onTap: _toggleFlash,
                      tooltip: _flashOn ? 'Desligar flash' : 'Ligar flash',
                    ),
                  ],
                ),
```

- [ ] **Step 4: Run analyze and the full test suite**

Run: `flutter analyze lib/features/meals/screens/capture_screen.dart`
Expected: no new warnings/errors.

Run: `flutter test`
Expected: all tests still pass (flash logic requires a real `CameraController` to exercise end-to-end — see Task 5 for the manual verification step; the existing automated suite has nothing that constructs `CaptureScreen` directly, so this step only guards against compile errors and regressions elsewhere).

- [ ] **Step 5: Commit**

```bash
git add lib/features/meals/screens/capture_screen.dart
git commit -m "feat: add two-state flash toggle to the in-app camera"
```

---

### Task 5: Manual smoke test on the emulator, then finalize the branch

**Files:** none (verification only)

Automated widget tests can't exercise `CaptureScreen` end-to-end because `CameraController` talks to a real platform camera — there's no camera platform fake in this codebase (unlike `MealContextSheet`, which Task 2 already covers with real automated tests). This matches how prior camera-touching work in this project was verified (see `docs/backlog-handoff-2026-07-19.md`, item #1/#2's "smoke test manual completo" on `gema_emulator`). This task is the manual equivalent for this change.

- [ ] **Step 1: Boot the emulator and run the app**

```bash
emulator -avd gema_emulator -no-snapshot-load &
adb wait-for-device
flutter run
```

- [ ] **Step 2: Verify the camera path asks for context**

Navigate to capture → point the camera at anything → tap the shutter. Confirm the same bottom sheet used by the gallery flow appears (title "Adicionar contexto", text field, mic icon). Tap "Pular" and confirm the meal is created with an empty note (check the confirm screen / meal detail — no leftover text from anything typed in the sheet before tapping "Pular"). Repeat and tap "Adicionar" with typed text, confirm the note is saved.

- [ ] **Step 3: Verify the gallery path still works unchanged**

Navigate to capture → tap the gallery icon → pick any photo → confirm the same sheet appears and behaves the same as Step 2.

- [ ] **Step 4: Verify the flash toggle**

On the camera screen, tap the flash icon in the top-right. Confirm the device's flash/torch turns on and the icon switches to the "on" state. Tap again, confirm it turns off and the icon switches back.

- [ ] **Step 5: Run the full automated suite and analyzer one last time**

Run: `flutter test`
Expected: all tests pass.

Run: `flutter analyze`
Expected: same issue count as the `main` baseline, zero new issues (per `CLAUDE.md`, "must pass before committing" — compare against the count recorded in `docs/backlog-handoff-2026-07-19.md`'s most recent entries if unsure what the baseline is).

---

### Task 6: Open the Pull Request

**Files:** none

Per the spec's integration process, this branch must go through a reviewed PR — do not squash-merge directly.

- [ ] **Step 1: Push the branch**

```bash
git push -u origin unify-camera-context-and-flash
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "Unify camera/gallery context flow + camera flash toggle" --body "$(cat <<'EOF'
## Summary
- Camera capture now shows the same post-capture context bottom sheet as the gallery pick (items #3/#4 in docs/backlog-handoff-2026-07-19.md).
- Fixes a latent bug where "Pular" silently kept whatever text was typed instead of discarding it.
- Adds a two-state (off/torch) flash toggle to the in-app camera.

## Test plan
- [x] `flutter test` — full suite green, including new `test/widget/capture_screen_test.dart`.
- [x] `flutter analyze` — no new issues vs. main baseline.
- [x] Manual smoke test on `gema_emulator`: camera capture → context sheet → Pular/Adicionar; gallery pick → same sheet; flash toggle on/off.

Design spec: docs/superpowers/specs/2026-07-21-unify-camera-context-flash-design.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 3: Report the PR URL back to the user and wait for review**

Do not merge this PR without explicit approval — per the spec, this is the one backlog item that requires review before integration.
