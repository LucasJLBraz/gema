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
              .map(
                (s) => _SuggestionCard(
                  suggestion: s,
                  onTap: () => _duplicate(context, ref, s),
                ),
              )
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
            Text(timeLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
