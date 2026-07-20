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
