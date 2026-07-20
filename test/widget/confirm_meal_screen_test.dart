import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gema/features/meals/models/meal.dart';
import 'package:gema/features/meals/providers/meal_provider.dart';
import 'package:gema/features/meals/screens/confirm_meal_screen.dart';

class _FakeMealQueueNotifier extends MealQueueNotifier {
  int? deletedMealId;

  @override
  Future<List<Meal>> build() async => [];

  @override
  Future<void> deleteMeal(int mealId) async {
    deletedMealId = mealId;
  }
}

const _mealId = 42;

Meal _buildDoneMeal() {
  final now = DateTime.now();
  return Meal()
    ..id = _mealId
    ..capturedAt = now
    ..source = MealSource.manual
    ..status = MealStatus.done
    ..kcalPoint = 500
    ..createdAt = now
    ..updatedAt = now;
}

void main() {
  Future<_FakeMealQueueNotifier> pumpConfirmScreen(WidgetTester tester) async {
    final fakeNotifier = _FakeMealQueueNotifier();
    final router = GoRouter(
      initialLocation: '/confirm',
      routes: [
        GoRoute(
          path: '/confirm',
          builder: (_, __) => const ConfirmMealScreen(mealId: _mealId),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealByIdProvider(_mealId).overrideWith((ref) => _buildDoneMeal()),
          mealQueueNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return fakeNotifier;
  }

  testWidgets(
    'tapping the close button deletes the meal via the notifier, then goes home',
    (tester) async {
      final fakeNotifier = await pumpConfirmScreen(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(fakeNotifier.deletedMealId, _mealId);
    },
  );

  testWidgets(
    'system back gesture deletes the meal via the notifier, then goes home',
    (tester) async {
      final fakeNotifier = await pumpConfirmScreen(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(fakeNotifier.deletedMealId, _mealId);
    },
  );
}
