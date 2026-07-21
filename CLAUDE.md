# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

GEMA is an offline-first Android diet tracker built with Flutter. It uses Isar as a local reactive database and calls the Gemini API directly from the device for AI-powered meal estimation. Source code is in early development; the authoritative spec is `@docs/spec_diet_tracker_v2.md`.

## Stack

- **Language:** Dart, Flutter stable
- **State management:** Riverpod (`flutter_riverpod` + `riverpod_annotation`)
- **Database:** Isar (reactive, typed, offline-first)
- **AI:** Gemini 3.1 Flash-Lite — structured JSON output, free-tier rate limits (≤15 RPM / ~1 500 RPD)
- **Background tasks:** workmanager
- **Secure storage:** flutter_secure_storage (Gemini API key only — never hardcode or log it)
- **Target:** Android API 36 (x86_64 emulator `gema_emulator` pre-configured in devcontainer)

## Folder structure

Feature-based inside `lib/`:

```
lib/
  features/
    meals/          # photo capture, quick-add, barcode, meal status pipeline
    goals/          # TDEE, deficit/surplus targets, versioned goals
    weight/         # weigh-in logging, EMA smoothing, OLS projection
    summary/        # daily_summary materialization, macro bars, calorie ring
    gamification/   # XP log, levels
    water/          # water_log quick entry
    products/       # barcode cache, Open Food Facts
    onboarding/     # 4-screen setup flow
  core/
    db/             # Isar instance, collection registrations
    gemini/         # API client, retry/backoff, structured-output schema
    notifications/  # flutter_local_notifications setup
    theme/          # color tokens, typography (Plus Jakarta Sans, DM Mono)
```

## Key architecture rules

- **Meal status pipeline:** provisional → queued → processing → done | error. Never skip states; UI must reflect each transition.
- **Offline queue (outbox pattern):** meals are logged locally first; Gemini calls happen asynchronously. "Quick Add" creates a provisional entry immediately.
- **EMA weight smoothing** handles irregular weigh-ins — do not replace with a simple moving average. See §2.1 of the spec.
- **OLS projection** must show a confidence band (e.g., "12–19 Sept"), not a single point estimate. See §2.2.
- **Dynamic TDEE bootstrap:** use Mifflin/Katch-McArdle formula for the first 21 days, then switch to empirical energy balance. See §2.3.
- **Macro editing (V1):** only `kcal_point` is editable via slider; macros scale proportionally. Per-macro editing is deferred to V2.
- **XP is cumulative** — cheat days earn 0 XP but never reset progress. No streak mechanic.

## Gemini API constraints

- Rate-limit: process meals serially with ≥4–6 s between calls; handle 429 with exponential backoff (1–120 s, read `Retry-After` header).
- Always use `responseMimeType: "application/json"` + `responseSchema` — do not parse free-form text.
- Photo input: compress to ~800 px, JPEG quality 65% before sending.
- Photos are deleted 7 days after processing; error-status photos are kept until manual review.

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # static analysis (must pass before committing)
flutter test             # run all tests
flutter test test/unit/  # unit tests only (no emulator needed)
flutter build apk        # release APK
flutter run              # run on connected device / emulator
```

Emulator launch (devcontainer has KVM + `/dev/kvm` forwarded):

```bash
emulator -avd gema_emulator -no-snapshot-load &
adb wait-for-device
flutter run
```

## Testing

- **Unit tests** (`test/unit/`): pure Dart — cover EMA smoothing, TDEE/bootstrap, OLS projection, XP accumulation, macro scaling. No Flutter or Isar dependencies.
- **Widget tests** (`test/widget/`): use `flutter_test`; mock Isar and Riverpod providers.
- **Integration tests** (`integration_test/`): run on `gema_emulator`; cover the full meal logging and onboarding flows.

## Design tokens

Color palette and typography are defined in `docs/gema-palette.jsx` and `docs/gema-storybook.jsx`. Use the semantic token names (e.g., `primaryAmber`, `surfaceCream`) — do not hard-code hex values.

## Isar schema notes

Collections: `meals`, `meal_components`, `weight_history`, `goals`, `daily_summary`, `xp_log`, `products`, `water_log`. Schema changes require running `isar_generator`; run `flutter pub run build_runner build` after modifying any `@collection` class.
