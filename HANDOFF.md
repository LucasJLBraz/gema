# GEMA — Engineering Handoff

**Last updated:** 2026-06-10  
**Status:** Early development — core flows working, several subsystems are stubs  
**Target platform:** Android (API 36, x86_64 dev emulator `gema_emulator`)  
**Flutter channel:** stable · Dart SDK ^3.12.1

---

## Table of Contents

1. [What Is GEMA](#1-what-is-gema)
2. [Quick Start](#2-quick-start)
3. [Architecture Overview](#3-architecture-overview)
4. [Data Model](#4-data-model)
5. [State Management](#5-state-management)
6. [Key Feature Flows](#6-key-feature-flows)
7. [Algorithms](#7-algorithms)
8. [Gemini API Integration](#8-gemini-api-integration)
9. [Design System](#9-design-system)
10. [Routing](#10-routing)
11. [Background Work](#11-background-work)
12. [Testing](#12-testing)
13. [Known Gaps & Placeholders](#13-known-gaps--placeholders)
14. [V2 Scope & Future Work](#14-v2-scope--future-work)
15. [Decision Log](#15-decision-log)

---

## 1. What Is GEMA

An **offline-first Android diet tracker** that uses on-device Gemini API calls for AI-powered meal estimation from photos or natural-language descriptions. The defining product bets:

- **No server** — all user data lives in a local Isar database.
- **AI-first logging** — snap a photo or describe a meal in text; Gemini returns structured nutritional estimates with a confidence interval.
- **Statistically honest** — every macronutrient estimate carries a min/max range that propagates into the calorie ring and macro bars.
- **Gamified** — cumulative XP, never-resetting levels to keep users engaged without punishing cheat days.

The authoritative product spec is `docs/spec_diet_tracker_v2.md`.

---

## 2. Quick Start

### Prerequisites

- Flutter stable (`flutter --version` — must match `^3.x` matching Dart `^3.12.1`)
- Android SDK, `adb` on `PATH`
- KVM-enabled host (for the emulator; already configured in the devcontainer)

### First run

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Isar schemas and Riverpod providers (required after any @collection or @riverpod change)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Static analysis (must be clean before committing)
flutter analyze

# 4. Unit tests (no device needed)
flutter test test/unit/

# 5. Start emulator + deploy
emulator -avd gema_emulator -no-snapshot-load &
adb wait-for-device
flutter run
```

### Wireless ADB (physical device)

```bash
adb connect <device-ip>:<port>   # pair via Settings → Developer options → Wireless debugging
flutter run
```

### Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Reset app state during testing

To force onboarding again (useful after schema changes or flow testing):

```
Android Settings → Apps → gema → Storage → Clear Data
```

This wipes both Isar (stored in app documents dir) and `flutter_secure_storage` (the Gemini API key).

---

## 3. Architecture Overview

```
lib/
├── main.dart                   # Entry point: DB init, notifications, background tasks,
│                               # QueueProcessor.start(), ProviderScope
├── core/
│   ├── algorithms/             # Pure Dart: TDEE, BMR, EMA, OLS — no Flutter deps
│   ├── background/             # WorkManager callbackDispatcher + task registration
│   ├── db/                     # Isar instance singleton (`isar`) + initDatabase()
│   ├── gemini/                 # HTTP client, structured output, retry/backoff
│   ├── router/                 # GoRouter (riverpod_annotation-generated)
│   ├── shell/                  # Bottom nav shell (Home / History / Analytics)
│   ├── theme/                  # Color tokens, typography — GemaColors, GemaTextStyles
│   └── export/                 # CSV/JSON data export via share_plus
└── features/
    ├── meals/                  # Photo capture, text describe, confirm, tile, detail
    │   ├── models/             # Meal, MealComponent (@collection)
    │   ├── providers/          # MealQueueNotifier, todayMeals stream
    │   ├── screens/            # CaptureScreen, ConfirmMealScreen, DescribeMealSheet
    │   ├── services/           # QueueProcessor singleton (foreground AI queue)
    │   └── widgets/            # MealListTile, MealDetailSheet
    ├── goals/                  # Goal versioning (effectiveFrom), TDEE targets
    ├── weight/                 # WeightEntry, EMA, OLS projection, LogWeightDialog
    ├── summary/                # DailySummary materialization (stub)
    ├── gamification/           # XpEvent log, level computation
    ├── water/                  # WaterLog quick-entry strip
    ├── products/               # Barcode → Open Food Facts cache
    ├── onboarding/             # 4-screen setup flow + OnboardingGuard
    ├── home/                   # HomeScreen, CalorieRing, MacroBars, WaterStrip
    ├── analytics/              # Weight chart, OLS projection card, XP card
    ├── history/                # Meal log by date
    └── settings/               # Edit physical profile + goal + API key
```

### Key architectural constraints

| Rule | Why |
|---|---|
| Isar opened once in `main()` as a late global `isar` | Isar v3 does not support multiple instances; providers import it directly |
| Gemini API key lives only in `flutter_secure_storage` | Never in Isar, logs, or source code |
| `MealSource.aiPhoto` is reused for text-only meals (`photoPath: null`) | Avoids Isar schema migration; text meals are fully supported with `photoPath == null && userNote.isNotEmpty` |
| All `@collection` and `@riverpod` annotations need code generation | Run `build_runner` after any change; generated `.g.dart` files are committed |

---

## 4. Data Model

### Collections

#### `Meal` · `MealComponent`

```
Meal
  id              Isar.autoIncrement
  capturedAt      DateTime @Index            — creation timestamp
  photoPath       String?                    — null for text-only meals; deleted 7 days post-processing
  photoDeletedAt  DateTime?
  userNote        String                     — user's freeform text OR AI-generated meal_name (see §6.2)
  source          MealSource { aiPhoto, barcode, quickAdd, manual }
  status          MealStatus { provisional, queued, processing, done, error }
  kcal{Min,Max,Point}  int
  protein{Min,Max,Point}
  carb{Min,Max,Point}
  fat{Min,Max,Point}
  aiConfidence    String?   — "high" | "medium" | "low"
  aiRawJson       String?   — full Gemini JSON response (source of truth for components)
  aiEmoji         String?
  retryCount      int       — incremented on each 429; used for backoff
  userEditedKcal  bool      — true when user manually adjusted kcal via slider
  createdAt / updatedAt

MealComponent  (linked via IsarLinks<MealComponent> backlink on Meal.components)
  id
  meal            IsarLink<Meal>
  name            String
  normalizedTag   String    — ASCII-normalized for dedup
  kcalPoint       int
  grupoAlimentar  String    — controlled vocabulary (see §8)
  metodoPreparo   String    — controlled vocabulary
  estimatedMassG  int?
```

#### `WeightEntry`

```
  id, measuredOn DateTime @Index (day precision), weightKg, bodyFatPct?, note?
```

One entry per calendar day — `WeightNotifier.log()` upserts by `measuredOn`.

#### `Goal`

```
  id, effectiveFrom DateTime @Index
  goalType     GoalType { cut, maintain, bulk }
  targetWeight, targetDate
  priorActivityFactor   — null after day 21 (empirical TDEE takes over)
  bmr, tdee, kcalTarget
  proteinTargetG, carbTargetG, fatTargetG
  heightCm, weightKg, ageYears, isMale, bodyFatPct?
```

Goals are **append-only** (versioned by `effectiveFrom`). The active goal is always the one with the latest `effectiveFrom`. Never update a goal in place — insert a new one.

#### `XpEvent`

```
  id, day DateTime @Index, eventType XpEventType, xpAmount int, createdAt
```

Deduplication by `(day, eventType)` — each event type can only be awarded once per calendar day.

#### `WaterLog`

```
  id, day DateTime, ml int, loggedAt DateTime
```

Multiple entries per day; total = sum of all `ml` for that day.

#### `DailySummary` · `Product`

Schemas exist; materialization and barcode cache are partially implemented (see §13).

---

## 5. State Management

All state uses **Riverpod** with `riverpod_annotation` code generation. Pattern overview:

```dart
// Read-only computed stream (reactive)
@riverpod
Stream<List<Meal>> todayMeals(TodayMealsRef ref) { ... }

// Read-only async query
@riverpod
Future<Goal?> activeGoal(ActiveGoalRef ref) { ... }

// Mutable notifier (write operations)
@riverpod
class MealQueueNotifier extends _$MealQueueNotifier {
  @override
  Future<List<Meal>> build() async { ... }
  Future<void> createMeal(...) async { ... }
  Future<void> applyGeminiResult(...) async { ... }
}
```

### Important providers

| Provider | File | What it does |
|---|---|---|
| `todayMealsProvider` | `meal_provider.dart` | Reactive stream of today's non-error meals |
| `mealQueueNotifierProvider` | `meal_provider.dart` | `createMeal`, `applyGeminiResult`, `deleteMeal`, `updateKcalPoint` |
| `activeGoalProvider` | `goal_provider.dart` | Latest Goal by effectiveFrom |
| `smoothedWeightsProvider` | `weight_provider.dart` | EMA-smoothed `List<(DateTime, double)>` |
| `weightNotifierProvider` | `weight_provider.dart` | `log(weightKg)` — upserts by day |
| `xpLevelProvider` | `xp_provider.dart` | Current level from cumulative XP |
| `xpNotifierProvider` | `xp_provider.dart` | `award(type, day)` — idempotent |
| `todayWaterMlProvider` | `water_provider.dart` | Total ml today; `add(ml)`, `remove(ml)` |
| `routerProvider` | `app_router.dart` | GoRouter instance |

---

## 6. Key Feature Flows

### 6.1 Meal Logging Pipeline

```
User action
    │
    ├─ Camera photo ──────────────────────────────────────────┐
    │   CaptureScreen                                          │
    │   └─ _saveMealFromPath(path, note)                       │
    │       createMeal(source: aiPhoto, photoPath: path,       │
    │                  userNote: note)  → status: queued       │
    │       navigate → /confirm?mealId=X                       │
    │                                                          │
    ├─ Gallery pick ──────────────────────────────────────────>│
    │   _GalleryContextSheet (optional note + STT)             │
    │   same flow as camera ──────────────────────────────────>│
    │                                                          │
    ├─ "Descrever" (text only) ───────────────────────────────>│
    │   DescribeMealSheet                                       │
    │   createMeal(source: aiPhoto, photoPath: null,           │
    │              userNote: text)  → status: queued            │
    │   navigate → /confirm?mealId=X                           │
    │                                                          ▼
    │                                           ConfirmMealScreen
    │                                           │
    │                                           ├─ if status==queued → _runAnalysis()
    │                                           │   estimateMeal(photoPath?, userNote)
    │                                           │   applyGeminiResult(...)
    │                                           │   → status: done
    │                                           │
    │                                           ├─ if status==processing → _watchForCompletion()
    │                                           │   polls Isar every 2s until done/error
    │                                           │
    │                                           └─ "Salvar" → context.go('/home')
    │
    ├─ Quick Add ─────────────────────────────────────────────>
    │   _QuickAddSheet: kcal + note                            
    │   createMeal(source: quickAdd, kcalPoint: n)             
    │   → status: provisional (no Gemini call, immediate)      
    │
    └─ Barcode ───────────────────────────────────────────────>
        BarcodeScreen → Open Food Facts → MealComponent        
        → status: done                                         
```

### 6.2 AI Name vs User Note

`Meal.userNote` serves a dual purpose:

1. **Before Gemini**: holds whatever the user typed as context (e.g. "plate from the restaurant near work").
2. **After Gemini**: `applyGeminiResult()` overwrites `userNote` with the AI-generated `meal_name` (≤4 words, content-based). Priority order:
   ```
   AI meal_name  >  user's freeform note  >  AI meal_summary
   ```

This means the UI always shows the cleanest possible name in the tile without a separate schema field. The full AI response (including the original `meal_summary` and all components) is preserved in `aiRawJson`.

### 6.3 Queue Processor

`QueueProcessor` (`lib/features/meals/services/queue_processor.dart`) is a **foreground singleton** started in `main()`:

- Opens a **reactive Isar stream** on `status==queued` meals.
- On any emission with items, calls `_processAll()`, which serially processes each queued meal.
- Sets `status=processing` before each Gemini call (visible in UI).
- On `GeminiRateLimitException`: resets to `queued`, increments `retryCount`, waits `retryAfterSeconds`.
- On other error: sets `status=error`.
- Enforces ≥5 s gap between successful Gemini calls (spec: 4–6 s, free-tier ≤15 RPM).
- The WorkManager `gema.queue_processor` task (every 15 min) is still registered but `_runQueueProcessor()` is an empty stub — it exists as a fallback for when the app is fully closed.

### 6.4 Weight & Analytics

1. `WeightNotifier.log(kg)` upserts by day → `weightHistoryProvider` invalidated.
2. `smoothedWeightsProvider` derives time-aware EMA (τ=7 days) over all entries.
3. `AnalyticsScreen` runs OLS on the last 28 smoothed points → `ProjectionResult` with optimistic/pessimistic dates.
4. Chart only renders when `smoothed.length >= 3`; with 1–2 points, shows the latest weight and guidance text.

### 6.5 Onboarding & Goal Bootstrapping

`OnboardingScreen` (4 pages) collects:
1. Physical data (weight, height, age, sex)
2. Body composition (body fat % — optional, unlocks Katch-McArdle BMR)
3. Goal (cut/maintain/bulk, deficit magnitude, target weight)
4. Gemini API key (stored via `flutter_secure_storage`)

On finish: computes BMR → TDEE → `kcalTarget` via `macrosFromKcal()`, writes a `Goal` to Isar, logs initial weight entry.

`OnboardingGuard.isComplete()` checks: `isar.goals.count() > 0 && apiKey != null`. Both conditions must hold or the user is redirected to `/onboarding`.

**Settings screen** (`/settings`) lets the user edit all of the above post-onboarding by writing a new `Goal` with `effectiveFrom = now`.

---

## 7. Algorithms

All algorithms are **pure Dart functions** in `lib/core/algorithms/` with no Flutter or Isar dependencies. They are unit-testable without an emulator.

### 7.1 BMR (Basal Metabolic Rate)

```dart
// Katch-McArdle (preferred when bodyFatPct is known):
BMR = 370 + 21.6 × LBM        where LBM = weight × (1 - bf/100)

// Mifflin-St Jeor (fallback):
Male:   BMR = 10w + 6.25h − 5a + 5
Female: BMR = 10w + 6.25h − 5a − 161
```

### 7.2 TDEE & Bootstrapping (§2.3)

Days 0–20: `TDEE = BMR × activityFactor` (prior from onboarding).  
Days 7–21: blended with empirical estimate using weight balance:

```
tdeeEmpirical = avgDailyKcal − (ΔSmoothedWeight × 7700) / windowDays
w = clamp((daysWithData − 7) / 14, 0, 1)
blendedTDEE = (1 − w) × prior + w × empirical
```

**⚠️ Gap**: The nightly recalculation loop that should call `blendedTdee()` and update the active Goal is not wired. `kcalTarget` is currently static from onboarding/settings save.

### 7.3 EMA Weight Smoothing (§2.1)

Time-aware to handle irregular logging gaps:

```
α_eff = 1 − e^(−Δdays / τ)       τ = 7 days
EMA_t = EMA_{t-1} + α_eff × (observed − EMA_{t-1})
```

### 7.4 OLS Goal-Date Projection (§2.2)

Runs on the last 28 smoothed EMA points. Returns slope (kg/day), intercept, and standard error of the slope. `projectGoalDate()` uses a t-critical of 1.96 (n≥30) or 2.1 (n<30) to produce a 95% confidence band as two dates (optimistic / pessimistic).

Returns `null` when: fewer than 3 points, slope moves away from goal, or slope = 0.

### 7.5 XP & Levels (§2.7)

```
level = floor(sqrt(totalXP / 100))
```

XP events are idempotent per `(day, eventType)`. Awarding happens in provider callbacks; cheat days earn 0 XP but do not reset progress.

### 7.6 Macro Split

Fixed ratio applied to `kcalTarget`:

```
Protein: 30% of kcal ÷ 4 g/kcal
Carbs:   40% of kcal ÷ 4 g/kcal
Fat:     remainder ÷ 9 g/kcal
```

---

## 8. Gemini API Integration

**File:** `lib/core/gemini/gemini_service.dart`  
**Model:** `gemini-2.5-flash-lite`  
**Free tier:** ≤15 RPM / 1,000 RPD

### Request construction

```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=KEY

Body:
  system_instruction: <nutritionist persona + rules>
  contents[0].parts:
    - { inline_data: { mime_type: "image/jpeg", data: <base64> } }  ← only if photoPath != null
    - { text: userNote }                                              ← only if userNote != ""
  generationConfig:
    temperature: 0.3
    responseMimeType: "application/json"
    responseSchema: <structured schema below>
```

One request per meal — photo and text travel together in the same `parts[]` array.

### Response schema

```json
{
  "meal_name": "string",          // ≤4 words, content-based, Portuguese
  "meal_summary": "string",       // longer description, preserved in aiRawJson
  "meal_emoji": "string",         // single emoji
  "ai_confidence": "high|medium|low",
  "scale_reference_found": true,
  "estimates": {
    "calories_kcal": { "min": int, "max": int, "point": int },
    "macros_g": {
      "protein":       { "min": int, "max": int, "point": int },
      "carbohydrates": { "min": int, "max": int, "point": int },
      "fat":           { "min": int, "max": int, "point": int }
    }
  },
  "components": [{
    "name": "string",
    "normalized_tag": "string",
    "grupo_alimentar": "<controlled vocab>",
    "metodo_preparo": "<controlled vocab>",
    "estimated_mass_g": int,
    "kcal_point": int
  }],
  "clarifying_question": "string | null",
  "assumptions": ["string"]
}
```

**Controlled vocabularies:**
- `grupo_alimentar`: `proteina_animal, proteina_vegetal, laticinio, graos_cereais, tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar, bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro`
- `metodo_preparo`: `cru, cozido, grelhado, frito, assado, refogado, no_vapor, liquido, desconhecido`

### Rate limiting

| Scenario | Behaviour |
|---|---|
| HTTP 429 or 503 | `GeminiRateLimitException(retryAfterSeconds)` thrown |
| `Retry-After` header present | Use it, clamped to 1–120 s |
| No header | Exponential backoff: `min(2^retryCount × 2, 64)` |
| Between successful calls | `QueueProcessor` enforces 5 s delay |

### Image compression

Before sending, photos are compressed to max 800 px on the longest side, JPEG quality 65%. This is done in `_compressImage()` using the `image` package.

---

## 9. Design System

**Files:** `lib/core/theme/app_theme.dart`, `docs/gema-palette.jsx`, `docs/gema-storybook.jsx`

Always use semantic token names — never hardcode hex values.

### Color tokens (selected)

| Token | Light | Dark | Usage |
|---|---|---|---|
| `primaryAmber` / `darkPrimary` | `#F5A820` | `#FFD780` | Primary actions, calorie ring arc |
| `surfaceCream` / `darkSurface` | `#FFFBF5` | `#1C1A17` | Card/tile backgrounds |
| `darkTextSub` / `lightTextSub` | — | — | Secondary text, labels |
| `chartProtein{Light,Dark}` | — | — | Protein macro color |
| `chartCarbs{Light,Dark}` | — | — | Carb macro color |
| `chartFat{Light,Dark}` | — | — | Fat macro color |

### Typography

```dart
GemaTextStyles.display   // Plus Jakarta Sans Bold — large numbers, "gema" logotype
GemaTextStyles.title     // Jakarta Sans SemiBold — section headings
GemaTextStyles.label     // Jakarta Sans Medium — tile names, button text
GemaTextStyles.body      // Jakarta Sans Regular — body copy
GemaTextStyles.caption   // Jakarta Sans Regular small — section labels (ALL CAPS)
GemaTextStyles.micro     // Jakarta Sans — chip/pill labels
GemaTextStyles.dataMono  // DM Mono — numeric data (times, data values)
```

---

## 10. Routing

Managed by GoRouter (`lib/core/router/app_router.dart`). The router is a Riverpod provider so it can reference `OnboardingGuard`.

| Route | Widget | Notes |
|---|---|---|
| `/onboarding` | `OnboardingScreen` | Redirect target when guard fails |
| `/home` | `HomeScreen` (via `MainShell`) | Default route |
| `/history` | `HistoryScreen` (via `MainShell`) | |
| `/analytics` | `AnalyticsScreen` (via `MainShell`) | |
| `/capture` | `CaptureScreen` | Camera view, STT, gallery |
| `/confirm?mealId=X` | `ConfirmMealScreen` | AI analysis + edit |
| `/barcode` | `BarcodeScreen` | Mobile scanner |
| `/settings` | `SettingsScreen` | Profile + goal edit |

`MainShell` wraps the three tab routes with a bottom `NavigationBar`. The ⚙️ settings icon lives in the `HomeScreen` header, not in the bottom nav.

---

## 11. Background Work

### Foreground queue (`QueueProcessor`)

Started in `main()`, runs for the lifetime of the app. Uses an Isar reactive stream — wakes itself on new queued meals with no polling. See §6.3.

### WorkManager tasks

Registered at startup via `registerBackgroundTasks()`:

| Task name | Frequency | Status |
|---|---|---|
| `gema.nightly_summary` | Daily at midnight | Partial — fires meal reminder notifications; DailySummary materialization is a stub |
| `gema.photo_cleanup` | Weekly | Stub — logic not implemented |
| `gema.queue_processor` | Every 15 min | Stub — `_runQueueProcessor()` is empty; serves as fallback when app is killed |

WorkManager tasks run in a **separate Dart isolate**. They cannot use the Riverpod `ProviderScope` from the main isolate. Any real implementation must call `initDatabase()` directly and use Isar + `gemini_service` without Riverpod.

---

## 12. Testing

### Unit tests — `test/unit/`

Pure Dart; no Flutter or Isar dependencies. Covers:

- EMA smoothing edge cases (single entry, irregular gaps)
- TDEE bootstrap blending at various `daysWithData` values
- OLS projection (sign checks, null returns, confidence band direction)
- XP level formula
- Macro split rounding

Run with: `flutter test test/unit/`

### Widget tests — `test/widget/`

Use `flutter_test`; mock Isar via `ProviderScope(overrides: [...])`. Covers key screens and interaction flows.

### Integration tests — `integration_test/`

Run on `gema_emulator`. Cover the full meal logging flow and onboarding. Require `adb` connection.

Run with: `flutter test integration_test/`

---

## 13. Known Gaps & Placeholders

These are not bugs — they are acknowledged incomplete areas, listed from highest to lowest impact.

| # | Area | What's missing | Impact |
|---|---|---|---|
| 1 | **TDEE dynamic update** | `blendedTdee()` and `empiricalTdee()` exist and are tested but nothing calls them after onboarding. `kcalTarget` is static. | Medium — targets become stale after 3+ weeks |
| 2 | **WorkManager queue processor** | `_runQueueProcessor()` is empty. If the app is killed with queued meals, they stay queued until the user reopens the app. | Medium — foreground processor handles it while app is open |
| 3 | **DailySummary materialization** | `DailySummary` schema and collection exist; nothing writes to it. The nightly task is a stub. | Medium — history screen reads live meals instead |
| 4 | **Photo cleanup** | `_runPhotoCleanup()` is empty. Photos accumulate indefinitely. Spec says delete 7 days post-processing; error photos kept until manual review. | Low (disk space) |
| 5 | **Per-macro editing** | Slider only adjusts `kcalPoint`; macros scale proportionally. Per-macro editing deferred to V2. | Low |
| 6 | **Barcode cache** | `Product` collection exists; Open Food Facts service is stubbed. | Low (barcode flow works but doesn't cache) |
| 7 | **Connectivity guard** | No check before Gemini calls; fails gracefully with error state, but no "offline" message. | Low |
| 8 | **iOS** | Not targeted; no iOS-specific permissions or entitlements configured. | N/A for current scope |

---

## 14. V2 Scope & Future Work

Based on `docs/spec_diet_tracker_v2.md` and deferred decisions:

### High priority

- **TDEE recalibration loop** — nightly WorkManager task: fetch last 21 days of meals + weight, call `blendedTdee()`, write a new Goal if TDEE changed by >50 kcal.
- **WorkManager queue processor** — implement `_runQueueProcessor()` properly: open a fresh Isar instance in the background isolate, fetch queued meals, call `estimateMeal()`, write results.
- **Per-macro editing** — allow independent P/C/F sliders in `ConfirmMealScreen`; `userEditedKcal` flag is already in the schema.
- **Photo cleanup job** — delete `photoPath` files where `photoDeletedAt` is null and meal `status==done` and `updatedAt > 7 days ago`.

### Medium priority

- **DailySummary** — materialize daily totals into `DailySummary` collection for fast history queries and analytics.
- **Streak / habit insights** — currently XP is purely cumulative; V2 spec suggests showing meal-logging consistency without penalizing cheat days.
- **Open Food Facts cache** — cache products in `Product` collection with TTL; current barcode flow fetches fresh on every scan.
- **Export** — `data_export_service.dart` exists; wire it to a UI button in settings.
- **iOS support** — requires camera/microphone permission strings in `Info.plist`, `NSSecureUnarchivingKeyedUnarchiverErrors` handling for `flutter_secure_storage`.

### Low priority / V2+

- **Clarifying question flow** — when Gemini returns `clarifying_question` (>300 kcal impact), show a dialog, collect the answer, and re-call with it appended to `userNote`.
- **Meal templates** — save a confirmed meal as a template for quick re-logging.
- **Apple Health / Google Fit sync** — export daily summaries.
- **Widget** (home screen) — show calorie ring on Android home screen via a Glance widget.

---

## 15. Decision Log

Short record of non-obvious decisions made during development, so future engineers understand the "why" behind code that might look odd.

### D-01: `userNote` dual-purpose field

**Decision:** AI-generated `meal_name` overwrites `userNote` in `applyGeminiResult()`.  
**Why:** Avoids adding a `mealName` column to the Isar schema (which requires `build_runner` regeneration and a migration). The user's typed text is context for the AI, not a user-facing label — the AI produces a cleaner name. Full context is preserved in `aiRawJson`.  
**Trade-off:** Searching meal history by the user's original note is no longer possible. Acceptable because semantic search is V2+.

### D-02: `MealSource.aiPhoto` for text-only meals

**Decision:** Reused `aiPhoto` source with `photoPath: null` instead of adding a new `MealSource.aiText` variant.  
**Why:** Adding a new enum value requires Isar schema regeneration and `build_runner`. The `photoPath == null` check is sufficient to distinguish text-only in all relevant code paths.

### D-03: Gemini called synchronously in `ConfirmMealScreen`

**Decision:** `ConfirmMealScreen._runAnalysis()` calls Gemini in the foreground while the confirm UI is visible, rather than purely relying on the queue processor.  
**Why:** Provides immediate feedback to the user — they see analysis happening in real time. The queue processor is the fallback for when the screen is dismissed before analysis completes, or on app restart.

### D-04: `QueueProcessor` as a foreground singleton, not WorkManager

**Decision:** Primary queue processing runs as a live Isar stream listener in the main isolate, not in a WorkManager periodic task.  
**Why:** WorkManager runs in a separate Dart isolate and cannot share the Riverpod `ProviderScope`. Setting it up correctly requires duplicating the DB init and service logic. The foreground singleton is sufficient for the free-tier rate limit (meals are processed as soon as the app is open). WorkManager task is registered as a stub fallback.

### D-05: OLS on last 28 days only

**Decision:** Analytics OLS projection uses `smoothed.sublist(length - 28)` when there are more than 28 points.  
**Why:** Recent trend is more predictive than long-term history for goal projection. A user who changed diet 4 weeks ago should see a projection based on their current behaviour.

### D-06: CalorieRing — flat start, round tip

**Decision:** Progress arc uses `StrokeCap.butt` with a manually drawn filled circle at the end angle.  
**Why:** Flutter's `Canvas.drawArc` applies the same `StrokeCap` to both ends. Asymmetric caps require either a `Path` + `PathMetrics` approach or the "draw a circle at the tip" trick. The circle approach is simpler to reason about and produces identical visual output.

### D-07: Goals are append-only

**Decision:** `GoalNotifier.save()` always calls `isar.goals.put(goal)` with `Isar.autoIncrement` id, creating a new row.  
**Why:** Preserves history for the empirical TDEE calculation — the algorithm needs to know what target was active during each day of the weight window. Mutating the single goal row would destroy this.

---

*End of handoff. For questions about specific decisions not covered here, see the commit history and `docs/spec_diet_tracker_v2.md`.*
