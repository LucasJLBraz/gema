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
