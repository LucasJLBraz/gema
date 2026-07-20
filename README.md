<div align="center">

# GEMA

**Offline-first diet tracker for Android with AI-powered meal estimation.**

Snap a photo, scan a barcode, or just say what you ate — GEMA estimates calories and
macros with Gemini, logs everything locally, and projects your weight trend without
ever requiring a backend.

[![CI](https://github.com/LucasJLBraz/gema/actions/workflows/ci.yml/badge.svg)](https://github.com/LucasJLBraz/gema/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)](https://flutter.dev)

</div>

---

## What is GEMA

GEMA is a personal diet-tracking app built to remove the two biggest sources of
friction in food logging: **manual macro entry** and **dependency on a server you
don't control**.

- **Offline-first.** All data lives in a local [Isar](https://isar.dev) database on
  the device. There is no backend — the app works fully offline except for the AI
  estimation call itself.
- **AI meal estimation.** Take a photo, type a quick description, or use voice input;
  [Gemini 2.5 Flash-Lite](https://ai.google.dev) is called directly from the device
  with structured JSON output to estimate calories and macros as a **range**
  (min/max/point), not a false-precision single number.
- **Bring your own API key.** You provide your own free-tier Gemini API key during
  onboarding. It's stored in the OS secure enclave (`flutter_secure_storage`) and is
  never bundled with the app or sent anywhere but Google's API.
- **Statistically honest projections.** Weight trend uses time-aware EMA smoothing
  (not a naive moving average) and shows weight/goal projections as a confidence
  band, not a single point estimate.
- **No streak-shaming.** XP is cumulative — an off-plan day earns 0 XP but never
  resets progress.

See [`docs/spec_diet_tracker_v2.md`](docs/spec_diet_tracker_v2.md) for the full
product/architecture spec this implementation follows, and
[`HANDOFF.md`](HANDOFF.md) for a detailed engineering status snapshot.

## Features

| Area | What it does |
|---|---|
| **Meal capture** | Photo capture, free-text/voice description, barcode scan (Open Food Facts), or manual/quick-add entry |
| **Meal pipeline** | Every meal moves through `provisional → queued → processing → done \| error`; nothing is ever silently dropped |
| **Home dashboard** | Calorie ring, macro bars, water intake strip, recent meals list |
| **Analytics** | Daily summaries materialized from raw logs, trend charts |
| **Weight tracking** | EMA-smoothed weigh-in log with OLS trend projection and confidence band |
| **Goals** | Versioned goals with dynamic TDEE — Mifflin/Katch-McArdle bootstrap for the first 21 days, then empirical energy-balance TDEE |
| **Gamification** | Cumulative XP log, levels — no streaks, no punishment for off days |
| **Water tracking** | One-tap water log |
| **Data export** | Export your own data locally, no cloud round-trip |
| **Settings** | Manage your Gemini API key and app preferences |

## Tech stack

- **Language / framework:** Dart, Flutter (stable channel)
- **State management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod` + `riverpod_annotation`, code-generated)
- **Local database:** [Isar](https://isar.dev) — reactive, typed, offline-first
- **AI:** Gemini 2.5 Flash-Lite via structured JSON output, called directly from the device
- **Background processing:** `workmanager` (offline outbox queue for meal processing)
- **Secure storage:** `flutter_secure_storage` for the user's Gemini API key
- **Routing:** `go_router`
- **Target:** Android (API 36)

## Project structure

```
lib/
  features/
    meals/          # photo capture, quick-add, barcode, meal status pipeline
    goals/          # TDEE, deficit/surplus targets, versioned goals
    weight/         # weigh-in logging, EMA smoothing, OLS projection
    summary/        # daily_summary materialization, macro bars, calorie ring
    gamification/   # XP log, levels
    water/          # water_log quick entry
    products/       # barcode cache, Open Food Facts lookups
    onboarding/     # setup flow (incl. Gemini API key entry)
    settings/       # app preferences, API key management
  core/
    db/             # Isar instance, collection registrations
    gemini/         # API client, retry/backoff, structured-output schema
    algorithms/      # EMA smoothing, TDEE bootstrap, OLS projection
    router/          # go_router configuration
    theme/           # color tokens, typography
    export/          # local data export
    background/      # workmanager task registration
```

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart SDK `^3.12.1`)
- Android SDK (API 36) and a device or emulator
- A free [Gemini API key](https://ai.google.dev/) (entered inside the app, not needed to build)

### Setup

```bash
git clone https://github.com/LucasJLBraz/gema.git
cd gema
flutter pub get
```

### Run

```bash
flutter run
```

On first launch, the onboarding flow will ask for your Gemini API key — get a free
one at [aistudio.google.com](https://aistudio.google.com/app/apikey). The key never
leaves your device except in direct calls to Google's Gemini API.

### Build a release APK

```bash
flutter build apk
```

## Testing

```bash
flutter analyze              # static analysis — must pass before committing
flutter test                 # all tests
flutter test test/unit/      # pure-Dart unit tests (no emulator needed) — EMA smoothing, TDEE, OLS, XP, macro scaling
```

Widget tests live in `test/widget/` and integration tests (full meal-logging and
onboarding flows) run against an emulator in `integration_test/`.

## CI/CD

Every push and pull request to `main` runs through [GitHub Actions](.github/workflows/ci.yml):

1. **Static analysis** — `dart format --set-exit-if-changed`, `flutter analyze`, and a check that generated (`*.g.dart`) code is up to date with `build_runner`.
2. **Tests** — full test suite with coverage, uploaded as a build artifact.
3. **Build** — a debug APK is built and published as a downloadable workflow artifact.

## Isar schema

Collections: `meals`, `meal_components`, `weight_history`, `goals`, `daily_summary`,
`xp_log`, `products`, `water_log`. If you change any `@collection` class, regenerate
the schema and Riverpod providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Design

Color palette and typography tokens are defined in `docs/gema-palette.jsx` and
`docs/gema-storybook.jsx`. UI code should reference semantic token names (e.g.
`primaryAmber`, `surfaceCream`) rather than hard-coded hex values.

## Contributing

This started as a personal project but is open to contributions — issues and pull
requests are welcome. Please run `flutter analyze` and `flutter test` before
submitting a PR; CI will enforce both.

## License

GEMA is licensed under the [GNU General Public License v3.0](LICENSE).
