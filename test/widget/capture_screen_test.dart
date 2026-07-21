import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gema/features/meals/screens/capture_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sttChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sttChannel, (call) async {
      if (call.method == 'initialize') return false;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sttChannel, null);
  });

  Future<String?> pumpSheetAndTap(
    WidgetTester tester, {
    required String existingNote,
    required String buttonLabel,
    String? typeText,
  }) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (_) => MealContextSheet(existingNote: existingNote),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    if (typeText != null) {
      await tester.enterText(find.byType(TextField), typeText);
      await tester.pump();
    }

    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Pular descarta o texto digitado', (tester) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: '',
      buttonLabel: 'Pular',
      typeText: 'frango grelhado',
    );
    expect(result == null || result!.isEmpty, isTrue);
  });

  testWidgets('Adicionar devolve o texto digitado', (tester) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: '',
      buttonLabel: 'Adicionar',
      typeText: 'frango grelhado',
    );
    expect(result, 'frango grelhado');
  });

  testWidgets('Pular descarta mesmo quando já havia nota existente', (
    tester,
  ) async {
    final result = await pumpSheetAndTap(
      tester,
      existingNote: 'nota antiga',
      buttonLabel: 'Pular',
      typeText: 'texto novo digitado',
    );
    expect(result == null || result!.isEmpty, isTrue);
  });
}
