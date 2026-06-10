import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../goals/models/goal.dart';

part 'onboarding_guard.g.dart';

@riverpod
OnboardingGuard onboardingGuard(OnboardingGuardRef ref) => OnboardingGuard();

class OnboardingGuard {
  final _storage = const FlutterSecureStorage();

  Future<bool> isComplete() async {
    final goal = await isar.goals.where().findFirst();
    if (goal == null) return false;
    final key = await _storage.read(key: 'gemini_api_key');
    return key != null && key.isNotEmpty;
  }
}
