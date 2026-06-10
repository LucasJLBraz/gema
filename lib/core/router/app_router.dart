import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/meals/screens/capture_screen.dart';
import '../../features/meals/screens/confirm_meal_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/onboarding_guard.dart';
import '../../features/products/screens/barcode_screen.dart';
import '../shell/main_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final guard = ref.read(onboardingGuardProvider);
      final done = await guard.isComplete();
      if (!done && !state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const SizedBox.shrink()),
          GoRoute(
            path: '/history',
            builder: (_, __) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      GoRoute(path: '/capture', builder: (_, __) => const CaptureScreen()),
      GoRoute(
        path: '/confirm',
        builder: (_, state) {
          final mealId = int.parse(state.uri.queryParameters['mealId'] ?? '0');
          return ConfirmMealScreen(mealId: mealId);
        },
      ),
      GoRoute(path: '/barcode', builder: (_, __) => const BarcodeScreen()),
    ],
  );
}
