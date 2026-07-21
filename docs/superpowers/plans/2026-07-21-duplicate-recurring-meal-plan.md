# Duplicar Refeição Recorrente — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deixar o usuário duplicar, com um toque, uma refeição recorrente (ex.: o mesmo café da manhã) direto da tela de Quick Add, sem repetir o fluxo completo de captura/estimativa.

**Architecture:** Uma nova função pura de agrupamento por similaridade (Jaccard sobre tokens normalizados) roda sobre as refeições `done` dos últimos 14 dias, filtradas por uma janela de ±90 min do horário atual, expondo até 3 sugestões via um provider Riverpod. Um novo método `duplicateMeal` em `MealQueueNotifier` cria a cópia (nunca reaproveitando foto nem `MealComponent`s). Uma nova seção de UI no `_QuickAddSheet` (`lib/features/home/home_screen.dart`) consome o provider e chama o método, com desfazer via `SnackBar`.

**Tech Stack:** Flutter/Dart, Riverpod (`riverpod_annotation`, `@riverpod`), Isar (`IsarLinks`/`IsarLink`), `flutter_test`.

## Global Constraints

- Spec de origem: `docs/superpowers/specs/2026-07-21-duplicate-recurring-meal-design.md` (item #7 do backlog, `docs/backlog-handoff-2026-07-19.md`).
- Janela de candidatas: últimos 14 dias, ±90 minutos em torno do horário atual.
- Limiar de similaridade Jaccard: ≥ 0.6 = mesmo grupo (mantém só a ocorrência mais recente por grupo).
- Até 3 candidatas retornadas, ordenadas por recência.
- `duplicateMeal` nunca copia `photoPath`/`photoDeletedAt` (duas refeições apontando pro mesmo arquivo quebra `_taskPhotoCleanup` em `lib/core/background/background_tasks.dart`, que assume 1:1 foto↔refeição).
- `duplicateMeal` sempre cria novos registros `MealComponent` — nunca reaproveita um `MealComponent` existente em duas refeições.
- Nova refeição duplicada: `status = MealStatus.done`, `source = MealSource.quickAdd`, `retryCount = 0`, `userEditedKcal = false`, `capturedAt = createdAt = updatedAt = DateTime.now()`.
- Sem dependência nova de pacote — Jaccard é Dart puro.
- Toda escrita Isar em uma única `isar.writeTxn`, espelhando `createMeal`/`deleteMeal` existentes (`lib/features/meals/providers/meal_provider.dart`).
- Fora do escopo: editar valores antes de duplicar, favoritar refeições, sugestões fora do Quick Add, re-estimativa por IA.

---

## File Structure

- **Create** `lib/core/utils/text_normalization.dart` — `normalizeText`, `jaccardSimilarity`, `mostRecentPerSimilarityGroup<T>`. Elimina a duplicação hoje existente entre `meal_provider.dart` e `queue_processor.dart` (mesma função `_normalize` copiada duas vezes).
- **Modify** `lib/features/meals/providers/meal_provider.dart` — remove `_normalize` local, importa o util compartilhado, adiciona `MealQueueNotifier.duplicateMeal`.
- **Modify** `lib/features/meals/services/queue_processor.dart` — remove `_normalize` local, importa o util compartilhado.
- **Create** `lib/features/meals/providers/recurring_meal_suggestions_provider.dart` — `MealSuggestion` (classe de valor) + `recurringMealSuggestionsProvider`.
- **Create** `lib/features/meals/widgets/recurring_meal_suggestions.dart` — `RecurringMealSuggestions` (`ConsumerWidget`, público, renderiza 0–3 cards + snackbar de desfazer).
- **Modify** `lib/features/home/home_screen.dart` — insere `RecurringMealSuggestions` no topo do `_QuickAddSheetState.build()`.
- **Test** `test/unit/text_normalization_test.dart`
- **Test** `test/widget/recurring_meal_suggestions_provider_test.dart`
- **Test** `test/widget/meal_provider_test.dart` (adiciona casos para `duplicateMeal`)
- **Test** `test/widget/recurring_meal_suggestions_test.dart`
- **Test** `test/widget/home_screen_test.dart` (novo arquivo — hoje não existe teste para `HomeScreen`)

---

### Task 1: Utilitário compartilhado de normalização + agrupamento por similaridade

**Files:**
- Create: `lib/core/utils/text_normalization.dart`
- Modify: `lib/features/meals/providers/meal_provider.dart:220-230` (remover `_normalize`, importar util)
- Modify: `lib/features/meals/providers/meal_provider.dart:156` (trocar chamada `_normalize(...)` por `normalizeText(...)`)
- Modify: `lib/features/meals/services/queue_processor.dart:157-167` (remover `_normalize`, importar util)
- Modify: `lib/features/meals/services/queue_processor.dart:142` (trocar chamada `_normalize(...)` por `normalizeText(...)`)
- Test: `test/unit/text_normalization_test.dart`

**Interfaces:**
- Produces (usado pela Task 2): `String normalizeText(String input)`, `double jaccardSimilarity(String a, String b)`, `List<T> mostRecentPerSimilarityGroup<T>({required List<T> items, required String Function(T) textOf, required DateTime Function(T) timeOf, double threshold = 0.6})`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/unit/text_normalization_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gema/core/utils/text_normalization.dart';

void main() {
  group('normalizeText', () {
    test('lowercases and strips accents', () {
      expect(normalizeText('Café com Leite'), 'cafe com leite');
      expect(normalizeText('PÃO FRANCÊS'), 'pao frances');
      expect(normalizeText('  Açaí  '), 'acai');
    });
  });

  group('jaccardSimilarity', () {
    test('identical strings score 1.0', () {
      expect(jaccardSimilarity('ovo mexido', 'ovo mexido'), 1.0);
    });

    test('partial token overlap scores between 0 and 1', () {
      final score = jaccardSimilarity(
        'ovo mexido com manteiga',
        'ovo mexido com queijo',
      );
      // tokens: {ovo,mexido,com,manteiga} vs {ovo,mexido,com,queijo}
      // intersection=3, union=5 -> 0.6
      expect(score, closeTo(0.6, 0.0001));
    });

    test('completely different strings score 0.0', () {
      expect(jaccardSimilarity('arroz com feijao', 'salada de frutas'), 0.0);
    });

    test('empty strings score 0.0', () {
      expect(jaccardSimilarity('', 'algo'), 0.0);
      expect(jaccardSimilarity('', ''), 0.0);
    });
  });

  group('mostRecentPerSimilarityGroup', () {
    test('keeps only the most recent item per similarity group', () {
      final items = [
        ('café com leite', DateTime(2026, 7, 10, 8, 0)),
        ('café com leite e pão', DateTime(2026, 7, 18, 8, 5)),
        ('salada de frutas', DateTime(2026, 7, 15, 12, 0)),
      ];

      final result = mostRecentPerSimilarityGroup<(String, DateTime)>(
        items: items,
        textOf: (i) => i.$1,
        timeOf: (i) => i.$2,
        threshold: 0.6,
      );

      expect(result.length, 2);
      expect(result[0].$1, 'café com leite e pão');
      expect(result[1].$1, 'salada de frutas');
    });

    test('returns items sorted by recency, most recent first', () {
      final items = [
        ('a', DateTime(2026, 1, 1)),
        ('b', DateTime(2026, 7, 1)),
        ('c', DateTime(2026, 3, 1)),
      ];

      final result = mostRecentPerSimilarityGroup<(String, DateTime)>(
        items: items,
        textOf: (i) => i.$1,
        timeOf: (i) => i.$2,
      );

      expect(result.map((i) => i.$1).toList(), ['b', 'c', 'a']);
    });
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/unit/text_normalization_test.dart`
Expected: FAIL com `Error: Error when reading 'lib/core/utils/text_normalization.dart': No such file or directory.`

- [ ] **Step 3: Implementar o utilitário**

Criar `lib/core/utils/text_normalization.dart`:

```dart
String normalizeText(String input) {
  return input
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[àáâãä]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c');
}

double jaccardSimilarity(String a, String b) {
  final tokensA = _tokens(a);
  final tokensB = _tokens(b);
  if (tokensA.isEmpty || tokensB.isEmpty) return 0.0;

  final intersection = tokensA.intersection(tokensB).length;
  final union = tokensA.union(tokensB).length;
  return intersection / union;
}

Set<String> _tokens(String input) {
  return normalizeText(
    input,
  ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();
}

/// Groups [items] by [jaccardSimilarity] over [textOf], keeping only the
/// most recent item (by [timeOf]) per group. Result is sorted by recency,
/// most recent first.
List<T> mostRecentPerSimilarityGroup<T>({
  required List<T> items,
  required String Function(T) textOf,
  required DateTime Function(T) timeOf,
  double threshold = 0.6,
}) {
  final sorted = [...items]..sort((a, b) => timeOf(b).compareTo(timeOf(a)));
  final representatives = <T>[];
  for (final item in sorted) {
    final text = textOf(item);
    final matchesExisting = representatives.any(
      (rep) => jaccardSimilarity(text, textOf(rep)) >= threshold,
    );
    if (!matchesExisting) representatives.add(item);
  }
  return representatives;
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/unit/text_normalization_test.dart`
Expected: PASS (7 testes)

- [ ] **Step 5: Remover a duplicação em `meal_provider.dart`**

Em `lib/features/meals/providers/meal_provider.dart`, adicionar o import (após a linha 7):

```dart
import '../../../core/utils/text_normalization.dart';
```

Substituir a linha 156 (dentro de `applyGeminiResult`):

```dart
          ..normalizedTag = _normalize(c['normalized_tag'] as String? ?? '')
```

por:

```dart
          ..normalizedTag = normalizeText(c['normalized_tag'] as String? ?? '')
```

Remover a função `_normalize` inteira no fim do arquivo (linhas 220-230).

- [ ] **Step 6: Remover a duplicação em `queue_processor.dart`**

Em `lib/features/meals/services/queue_processor.dart`, adicionar o import (após a linha 9):

```dart
import '../../../core/utils/text_normalization.dart';
```

Substituir a linha 142:

```dart
          ..normalizedTag = _normalize(c['normalized_tag'] as String? ?? '')
```

por:

```dart
          ..normalizedTag = normalizeText(c['normalized_tag'] as String? ?? '')
```

Remover a função `_normalize` inteira no fim do arquivo (linhas 157-167).

- [ ] **Step 7: Rodar analyze + suíte completa**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` e todos os testes passando (nenhuma regressão nos 55 testes existentes).

- [ ] **Step 8: Commit**

```bash
git add lib/core/utils/text_normalization.dart lib/features/meals/providers/meal_provider.dart lib/features/meals/services/queue_processor.dart test/unit/text_normalization_test.dart
git commit -m "refactor: extract shared text normalization + similarity grouping util"
```

---

### Task 2: Provider de sugestões de refeições recorrentes

**Files:**
- Create: `lib/features/meals/providers/recurring_meal_suggestions_provider.dart`
- Test: `test/widget/recurring_meal_suggestions_provider_test.dart`

**Interfaces:**
- Consumes: `normalizeText`, `jaccardSimilarity`, `mostRecentPerSimilarityGroup<T>` (Task 1); `Meal`, `MealStatus`, `MealComponent` (`lib/features/meals/models/meal.dart`); variável global `isar` (`lib/core/db/database.dart`).
- Produces (usado pela Task 4): classe `MealSuggestion { final int mealId; final String displayText; final String? emoji; final DateTime capturedAt; }`; provider `recurringMealSuggestionsProvider` (`AutoDisposeFutureProvider<List<MealSuggestion>>`, acessível via `ref.watch(recurringMealSuggestionsProvider)`).

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/widget/recurring_meal_suggestions_provider_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:gema/core/db/database.dart' as db;
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'gema_recurring_suggestions_test_',
    );
    db.isar = await Isar.open([
      MealSchema,
      MealComponentSchema,
    ], directory: tempDir.path);
  });

  tearDown(() async {
    await db.isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<int> insertDoneMeal({
    required DateTime capturedAt,
    String userNote = '',
    String? aiEmoji,
    List<String> componentNames = const [],
  }) async {
    final meal = Meal()
      ..capturedAt = capturedAt
      ..userNote = userNote
      ..source = MealSource.aiPhoto
      ..status = MealStatus.done
      ..aiEmoji = aiEmoji
      ..createdAt = capturedAt
      ..updatedAt = capturedAt;

    await db.isar.writeTxn(() async {
      await db.isar.meals.put(meal);
      if (componentNames.isNotEmpty) {
        final components = componentNames
            .map(
              (name) => MealComponent()
                ..name = name
                ..normalizedTag = name.toLowerCase()
                ..grupoAlimentar = 'outro'
                ..metodoPreparo = 'desconhecido',
            )
            .toList();
        await db.isar.mealComponents.putAll(components);
        await meal.components.load();
        meal.components.addAll(components);
        await meal.components.save();
      }
    });
    return meal.id;
  }

  test('returns candidates within the 14-day / ±90min window, grouped by similarity', () async {
    final now = DateTime.now();

    // Same breakfast, 3 different days, within the time window -> one group.
    await insertDoneMeal(
      capturedAt: now.subtract(const Duration(days: 5)),
      userNote: 'café com leite e pão',
    );
    await insertDoneMeal(
      capturedAt: now.subtract(const Duration(days: 2)),
      userNote: 'café com leite e pão',
    );
    final mostRecentId = await insertDoneMeal(
      capturedAt: now.subtract(const Duration(minutes: 30)),
      userNote: 'café com leite e pão',
    );

    // Unrelated meal, also within the time window -> separate group.
    final saladId = await insertDoneMeal(
      capturedAt: now.subtract(const Duration(days: 1)),
      userNote: 'salada de frutas',
    );

    // Outside the 14-day window -> excluded.
    await insertDoneMeal(
      capturedAt: now.subtract(const Duration(days: 20)),
      userNote: 'café com leite e pão',
    );

    // Outside the ±90min time-of-day window -> excluded.
    await insertDoneMeal(
      capturedAt: DateTime(now.year, now.month, now.day)
          .add(const Duration(hours: 3))
          .subtract(now.hour >= 3 ? Duration.zero : const Duration(days: 0)),
      userNote: 'jantar tardio',
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      recurringMealSuggestionsProvider.future,
    );

    expect(result.length, 2);
    expect(result[0].mealId, mostRecentId);
    expect(result[0].displayText, 'café com leite e pão');
    expect(result[1].mealId, saladId);
  });

  test('falls back to component names when userNote is empty', () async {
    final now = DateTime.now();
    final mealId = await insertDoneMeal(
      capturedAt: now.subtract(const Duration(hours: 1)),
      componentNames: ['Ovo mexido', 'Torrada'],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      recurringMealSuggestionsProvider.future,
    );

    expect(result.single.mealId, mealId);
    expect(result.single.displayText, 'Ovo mexido, Torrada');
  });

  test('returns at most 3 candidates', () async {
    final now = DateTime.now();
    for (var i = 0; i < 5; i++) {
      await insertDoneMeal(
        capturedAt: now.subtract(Duration(days: i + 1)),
        userNote: 'refeicao completamente distinta numero $i xyz',
      );
    }

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      recurringMealSuggestionsProvider.future,
    );

    expect(result.length, 3);
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/recurring_meal_suggestions_provider_test.dart`
Expected: FAIL — `Error: Error when reading 'lib/features/meals/providers/recurring_meal_suggestions_provider.dart'`.

- [ ] **Step 3: Implementar o provider**

Criar `lib/features/meals/providers/recurring_meal_suggestions_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/utils/text_normalization.dart';
import '../models/meal.dart';

part 'recurring_meal_suggestions_provider.g.dart';

class MealSuggestion {
  const MealSuggestion({
    required this.mealId,
    required this.displayText,
    required this.emoji,
    required this.capturedAt,
  });

  final int mealId;
  final String displayText;
  final String? emoji;
  final DateTime capturedAt;
}

const _lookbackWindow = Duration(days: 14);
const _timeOfDayWindowMinutes = 90;
const _maxSuggestions = 3;

@riverpod
Future<List<MealSuggestion>> recurringMealSuggestions(
  RecurringMealSuggestionsRef ref,
) async {
  final now = DateTime.now();
  final windowStart = now.subtract(_lookbackWindow);

  final candidates = await isar.meals
      .filter()
      .statusEqualTo(MealStatus.done)
      .capturedAtGreaterThan(windowStart)
      .findAll();

  final withinTimeOfDay = candidates.where(
    (meal) => _timeOfDayDiffMinutes(meal.capturedAt, now) <= _timeOfDayWindowMinutes,
  );

  final withText = <(Meal, String)>[];
  for (final meal in withinTimeOfDay) {
    final text = await _displayTextFor(meal);
    if (text.isNotEmpty) withText.add((meal, text));
  }

  final representatives = mostRecentPerSimilarityGroup<(Meal, String)>(
    items: withText,
    textOf: (pair) => pair.$2,
    timeOf: (pair) => pair.$1.capturedAt,
  );

  return representatives
      .take(_maxSuggestions)
      .map(
        (pair) => MealSuggestion(
          mealId: pair.$1.id,
          displayText: pair.$2,
          emoji: pair.$1.aiEmoji,
          capturedAt: pair.$1.capturedAt,
        ),
      )
      .toList();
}

int _timeOfDayDiffMinutes(DateTime a, DateTime b) {
  final aMinutes = a.hour * 60 + a.minute;
  final bMinutes = b.hour * 60 + b.minute;
  final diff = (aMinutes - bMinutes).abs();
  return diff > 720 ? 1440 - diff : diff;
}

Future<String> _displayTextFor(Meal meal) async {
  if (meal.userNote.isNotEmpty) return meal.userNote;
  await meal.components.load();
  return meal.components.map((c) => c.name).join(', ');
}
```

- [ ] **Step 4: Gerar o código Riverpod**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `[INFO] Succeeded after ...` e o arquivo `lib/features/meals/providers/recurring_meal_suggestions_provider.g.dart` criado.

- [ ] **Step 5: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/recurring_meal_suggestions_provider_test.dart`
Expected: PASS (3 testes)

- [ ] **Step 6: Commit**

```bash
git add lib/features/meals/providers/recurring_meal_suggestions_provider.dart lib/features/meals/providers/recurring_meal_suggestions_provider.g.dart test/widget/recurring_meal_suggestions_provider_test.dart
git commit -m "feat: add recurring meal suggestions provider"
```

---

### Task 3: `duplicateMeal` em `MealQueueNotifier`

**Files:**
- Modify: `lib/features/meals/providers/meal_provider.dart` (adicionar método ao final da classe `MealQueueNotifier`, antes do `}` de fechamento na linha 218)
- Test: `test/widget/meal_provider_test.dart` (adicionar casos de teste)

**Interfaces:**
- Consumes: `Meal`, `MealComponent`, `MealStatus`, `MealSource` (`lib/features/meals/models/meal.dart`); variável global `isar`.
- Produces (usado pela Task 4): `Future<int> MealQueueNotifier.duplicateMeal(int originalMealId)` — retorna o `id` do novo `Meal` criado.

- [ ] **Step 1: Escrever o teste que falha**

Adicionar ao final de `test/widget/meal_provider_test.dart` (dentro do `void main() { ... }` existente, após o teste de `deleteMeal`):

```dart
  test('duplicateMeal copies fields, resets state, and creates new components', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final photoFile = File('${tempDir.path}/original_meal.jpg')
      ..writeAsStringSync('fake-jpeg-bytes');

    final originalId = await notifier.createMeal(
      source: MealSource.aiPhoto,
      photoPath: photoFile.path,
      userNote: 'café com leite e pão',
      kcalPoint: 400,
      proteinPoint: 15,
      carbPoint: 50,
      fatPoint: 10,
    );

    final original = (await db.isar.meals.get(originalId))!;
    await db.isar.writeTxn(() async {
      original
        ..status = MealStatus.done
        ..retryCount = 2
        ..userEditedKcal = true
        ..aiConfidence = 'alta'
        ..aiEmoji = '☕';
      await db.isar.meals.put(original);

      final component = MealComponent()
        ..name = 'Pão'
        ..normalizedTag = 'pao'
        ..kcalPoint = 150
        ..grupoAlimentar = 'carboidrato'
        ..metodoPreparo = 'assado'
        ..estimatedMassG = 60;
      await db.isar.mealComponents.put(component);
      await original.components.load();
      original.components.add(component);
      await original.components.save();
    });

    final newMealId = await notifier.duplicateMeal(originalId);
    final duplicated = (await db.isar.meals.get(newMealId))!;

    expect(duplicated.id, isNot(originalId));
    expect(duplicated.userNote, 'café com leite e pão');
    expect(duplicated.kcalPoint, 400);
    expect(duplicated.proteinPoint, 15);
    expect(duplicated.carbPoint, 50);
    expect(duplicated.fatPoint, 10);
    expect(duplicated.status, MealStatus.done);
    expect(duplicated.source, MealSource.quickAdd);
    expect(duplicated.retryCount, 0);
    expect(duplicated.userEditedKcal, isFalse);
    expect(duplicated.photoPath, isNull);
    expect(duplicated.photoDeletedAt, isNull);

    await duplicated.components.load();
    expect(duplicated.components.length, 1);
    expect(duplicated.components.first.name, 'Pão');
    expect(duplicated.components.first.grupoAlimentar, 'carboidrato');

    await original.components.load();
    expect(
      duplicated.components.first.id,
      isNot(original.components.first.id),
    );

    // Original photo must survive untouched.
    expect(await photoFile.exists(), isTrue);
  });

  test('duplicateMeal never copies a photo even when the original has one', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(mealQueueNotifierProvider.notifier);

    final originalId = await notifier.createMeal(
      source: MealSource.manual,
      userNote: 'refeição sem foto',
      kcalPoint: 200,
    );

    final newMealId = await notifier.duplicateMeal(originalId);
    final duplicated = (await db.isar.meals.get(newMealId))!;

    expect(duplicated.photoPath, isNull);
  });
```

Adicionar também o import necessário no topo do arquivo de teste, junto aos existentes:

```dart
import 'package:gema/core/db/database.dart' as db;
```

(já deve existir pelo teste de `deleteMeal` — só confirme que está presente; não duplicar o import).

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/meal_provider_test.dart`
Expected: FAIL com `The method 'duplicateMeal' isn't defined for the type 'MealQueueNotifier'`.

- [ ] **Step 3: Implementar `duplicateMeal`**

Em `lib/features/meals/providers/meal_provider.dart`, adicionar dentro da classe `MealQueueNotifier`, logo após `deleteMeal` (antes do `}` de fechamento da classe, linha 218):

```dart

  Future<int> duplicateMeal(int originalMealId) async {
    final original = await isar.meals.get(originalMealId);
    if (original == null) {
      throw ArgumentError('Meal $originalMealId not found');
    }
    await original.components.load();

    final now = DateTime.now();
    final duplicate = Meal()
      ..capturedAt = now
      ..userNote = original.userNote
      ..source = MealSource.quickAdd
      ..status = MealStatus.done
      ..kcalMin = original.kcalMin
      ..kcalMax = original.kcalMax
      ..kcalPoint = original.kcalPoint
      ..carbMin = original.carbMin
      ..carbMax = original.carbMax
      ..carbPoint = original.carbPoint
      ..proteinMin = original.proteinMin
      ..proteinMax = original.proteinMax
      ..proteinPoint = original.proteinPoint
      ..fatMin = original.fatMin
      ..fatMax = original.fatMax
      ..fatPoint = original.fatPoint
      ..aiConfidence = original.aiConfidence
      ..aiEmoji = original.aiEmoji
      ..retryCount = 0
      ..userEditedKcal = false
      ..createdAt = now
      ..updatedAt = now;

    final newComponents = original.components
        .map(
          (c) => MealComponent()
            ..name = c.name
            ..normalizedTag = c.normalizedTag
            ..kcalPoint = c.kcalPoint
            ..grupoAlimentar = c.grupoAlimentar
            ..metodoPreparo = c.metodoPreparo
            ..estimatedMassG = c.estimatedMassG,
        )
        .toList();

    await isar.writeTxn(() async {
      await isar.meals.put(duplicate);
      if (newComponents.isNotEmpty) {
        await isar.mealComponents.putAll(newComponents);
        await duplicate.components.load();
        duplicate.components.addAll(newComponents);
        await duplicate.components.save();
      }
    });
    ref.invalidateSelf();
    return duplicate.id;
  }
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/meal_provider_test.dart`
Expected: PASS (4 testes: os 2 já existentes de `deleteMeal` + os 2 novos de `duplicateMeal`)

- [ ] **Step 5: Rodar analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/meals/providers/meal_provider.dart test/widget/meal_provider_test.dart
git commit -m "feat: add MealQueueNotifier.duplicateMeal"
```

---

### Task 4: Widget `RecurringMealSuggestions`

**Files:**
- Create: `lib/features/meals/widgets/recurring_meal_suggestions.dart`
- Test: `test/widget/recurring_meal_suggestions_test.dart`

**Interfaces:**
- Consumes: `recurringMealSuggestionsProvider` → `List<MealSuggestion>` (Task 2); `mealQueueNotifierProvider.notifier` → `duplicateMeal(int)`/`deleteMeal(int)` (Task 3, `deleteMeal` já existente).
- Produces: `RecurringMealSuggestions` (`ConsumerWidget`, público, sem parâmetros obrigatórios) — usado pela Task 5.

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/widget/recurring_meal_suggestions_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';
import 'package:gema/features/meals/widgets/recurring_meal_suggestions.dart';

class _FakeMealQueueNotifier extends MealQueueNotifier {
  int? duplicatedMealId;
  int? deletedMealId;
  final int nextDuplicateId;

  _FakeMealQueueNotifier({this.nextDuplicateId = 999});

  @override
  Future<List<Meal>> build() async => [];

  @override
  Future<int> duplicateMeal(int originalMealId) async {
    duplicatedMealId = originalMealId;
    return nextDuplicateId;
  }

  @override
  Future<void> deleteMeal(int mealId) async {
    deletedMealId = mealId;
  }
}

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<MealSuggestion> suggestions,
    required _FakeMealQueueNotifier fakeNotifier,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recurringMealSuggestionsProvider.overrideWith((ref) async => suggestions),
          mealQueueNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(body: RecurringMealSuggestions()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders nothing when there are no suggestions', (tester) async {
    await pumpWidget(
      tester,
      suggestions: const [],
      fakeNotifier: _FakeMealQueueNotifier(),
    );

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.text('Refeições recentes parecidas'), findsNothing);
  });

  testWidgets('renders up to 3 suggestion cards', (tester) async {
    final now = DateTime.now();
    await pumpWidget(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 1,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: now,
        ),
        MealSuggestion(
          mealId: 2,
          displayText: 'salada de frutas',
          emoji: null,
          capturedAt: now,
        ),
      ],
      fakeNotifier: _FakeMealQueueNotifier(),
    );

    expect(find.text('Refeições recentes parecidas'), findsOneWidget);
    expect(find.textContaining('café com leite e pão'), findsOneWidget);
    expect(find.textContaining('salada de frutas'), findsOneWidget);
  });

  testWidgets('tapping a card duplicates the meal and shows undo snackbar', (
    tester,
  ) async {
    final fakeNotifier = _FakeMealQueueNotifier(nextDuplicateId: 42);
    await pumpWidget(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 7,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: DateTime.now(),
        ),
      ],
      fakeNotifier: fakeNotifier,
    );

    await tester.tap(find.textContaining('café com leite e pão'));
    await tester.pump();

    expect(fakeNotifier.duplicatedMealId, 7);
    expect(find.text('Refeição duplicada'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pump();

    expect(fakeNotifier.deletedMealId, 42);
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/recurring_meal_suggestions_test.dart`
Expected: FAIL — `Error: Error when reading 'lib/features/meals/widgets/recurring_meal_suggestions.dart'`.

- [ ] **Step 3: Implementar o widget**

Criar `lib/features/meals/widgets/recurring_meal_suggestions.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meal_provider.dart';
import '../providers/recurring_meal_suggestions_provider.dart';

class RecurringMealSuggestions extends ConsumerWidget {
  const RecurringMealSuggestions({super.key});

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    MealSuggestion suggestion,
  ) async {
    final notifier = ref.read(mealQueueNotifierProvider.notifier);
    final newMealId = await notifier.duplicateMeal(suggestion.mealId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refeição duplicada'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => notifier.deleteMeal(newMealId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(recurringMealSuggestionsProvider);
    final suggestions = suggestionsAsync.valueOrNull ?? [];

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refeições recentes parecidas',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map((s) => _SuggestionCard(
                    suggestion: s,
                    onTap: () => _duplicate(context, ref, s),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.onTap});

  final MealSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(suggestion.capturedAt);
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (suggestion.emoji != null) ...[
              Text(suggestion.emoji!),
              const SizedBox(width: 6),
            ],
            Text(suggestion.displayText),
            const SizedBox(width: 6),
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/recurring_meal_suggestions_test.dart`
Expected: PASS (3 testes)

- [ ] **Step 5: Commit**

```bash
git add lib/features/meals/widgets/recurring_meal_suggestions.dart test/widget/recurring_meal_suggestions_test.dart
git commit -m "feat: add RecurringMealSuggestions widget with undo"
```

---

### Task 5: Ligar `RecurringMealSuggestions` ao Quick Add

**Files:**
- Modify: `lib/features/home/home_screen.dart:409-441` (`_QuickAddSheetState.build`)
- Test: `test/widget/home_screen_test.dart` (novo arquivo)

**Interfaces:**
- Consumes: `RecurringMealSuggestions` (Task 4); `activeGoalProvider`, `todayMealsProvider`, `todayWaterMlProvider`, `xpLevelProvider`, `mealQueueNotifierProvider`, `recurringMealSuggestionsProvider` (providers já existentes/Task 2, para overrides de teste).

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/widget/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/gamification/providers/xp_provider.dart';
import 'package:gema/features/goals/providers/goal_provider.dart';
import 'package:gema/features/home/home_screen.dart';
import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';
import 'package:gema/features/meals/providers/recurring_meal_suggestions_provider.dart';
import 'package:gema/features/meals/widgets/recurring_meal_suggestions.dart';
import 'package:gema/features/water/providers/water_provider.dart';

class _FakeMealQueueNotifier extends MealQueueNotifier {
  @override
  Future<List<Meal>> build() async => [];
}

class _FakeTodayWaterMl extends TodayWaterMl {
  @override
  Future<int> build() async => 0;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required List<MealSuggestion> suggestions,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activeGoalProvider.overrideWith((ref) async => null),
        todayMealsProvider.overrideWith((ref) => Stream.value(<Meal>[])),
        todayWaterMlProvider.overrideWith(() => _FakeTodayWaterMl()),
        xpLevelProvider.overrideWith((ref) async => 0),
        mealQueueNotifierProvider.overrideWith(() => _FakeMealQueueNotifier()),
        recurringMealSuggestionsProvider.overrideWith(
          (ref) async => suggestions,
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Quick Add sheet shows recurring meal suggestions', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      suggestions: [
        MealSuggestion(
          mealId: 1,
          displayText: 'café com leite e pão',
          emoji: '☕',
          capturedAt: DateTime.now(),
        ),
      ],
    );

    await tester.tap(find.text('⚡ Quick Add'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.textContaining('café com leite e pão'), findsOneWidget);
  });

  testWidgets('Quick Add sheet shows nothing extra when there are no suggestions', (
    tester,
  ) async {
    await _pumpHome(tester, suggestions: const []);

    await tester.tap(find.text('⚡ Quick Add'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringMealSuggestions), findsOneWidget);
    expect(find.text('Refeições recentes parecidas'), findsNothing);
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/home_screen_test.dart`
Expected: FAIL — `The getter 'RecurringMealSuggestions' isn't defined` (ainda não importado/inserido em `home_screen.dart`), ou `finds 0 widgets` para `find.byType(RecurringMealSuggestions)`.

- [ ] **Step 3: Inserir o widget no `_QuickAddSheet`**

Em `lib/features/home/home_screen.dart`, adicionar o import junto aos demais (após a linha 9):

```dart
import '../meals/widgets/recurring_meal_suggestions.dart';
```

Modificar `_QuickAddSheetState.build()` (linhas 409-441) para inserir `const RecurringMealSuggestions()` logo após o título "Quick Add":

```dart
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Add', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          const RecurringMealSuggestions(),
          TextField(
            controller: _kcalCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Calorias (kcal)',
              hintText: '500',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex: arroz com frango',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: const Text('Adicionar'),
            ),
          ),
        ],
      ),
```

(Removida a `SizedBox(height: 14)` fixa que antes separava o título do primeiro campo — `RecurringMealSuggestions` já retorna `const SizedBox.shrink()` quando vazio, e adiciona seu próprio espaçamento inferior quando tem conteúdo.)

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/home_screen_test.dart`
Expected: PASS (2 testes)

- [ ] **Step 5: Rodar toda a suíte + analyze**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` e todos os testes passando (nenhuma regressão).

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/home_screen.dart test/widget/home_screen_test.dart
git commit -m "feat: surface recurring meal suggestions in the Quick Add sheet"
```

---

## Self-Review

**1. Cobertura da spec:**
- Seção 1 (sugestão de refeições recorrentes: janela 14 dias/±90min, agrupamento Jaccard ≥0.6, até 3 candidatas por recência) → Task 2.
- Seção 2 (`duplicateMeal`: campos copiados, campos resetados, foto nunca copiada, componentes sempre novos, `writeTxn` único) → Task 3.
- Seção 3 (UI no Quick Add: seção compacta, sem estado vazio dedicado, tap duplica direto, snackbar com desfazer via `deleteMeal` existente) → Tasks 4 e 5.
- Seção 4 (testes unit/provider/widget) → cobertos em cada task correspondente.
- Riscos e limitações (seção 5 da spec) — documentados como comentários/constraints, sem ação de código necessária (nenhuma otimização de performance pedida agora).

**2. Placeholder scan:** nenhum "TBD"/"similar to Task N" — todo código é completo em cada step.

**3. Consistência de tipos:** `MealSuggestion` (Task 2) usado identicamente em Tasks 4 e 5; `duplicateMeal(int) → Future<int>` (Task 3) chamado com a mesma assinatura em `RecurringMealSuggestions` (Task 4); `deleteMeal(int)` reutiliza a assinatura já existente em `MealQueueNotifier`. `normalizeText`/`jaccardSimilarity`/`mostRecentPerSimilarityGroup` (Task 1) usados com a mesma assinatura em Task 2.

## Execution Handoff

Duas opções de execução:

1. **Subagent-Driven (recomendado)** — um subagente por task, revisão entre tasks, iteração rápida.
2. **Inline Execution** — execução em lote nesta sessão via `executing-plans`, com checkpoints de revisão.
