import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class DescribeMealSheet extends ConsumerStatefulWidget {
  const DescribeMealSheet({super.key});

  @override
  ConsumerState<DescribeMealSheet> createState() => _DescribeMealSheetState();
}

class _DescribeMealSheetState extends ConsumerState<DescribeMealSheet> {
  final _ctrl = TextEditingController();
  final _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _listening = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stt.initialize().then((ok) {
      if (mounted) setState(() => _sttAvailable = ok);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _stt.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_sttAvailable) return;
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
    } else {
      setState(() => _listening = true);
      await _stt.listen(
        onResult: (r) {
          setState(() {
            _ctrl.text = r.recognizedWords;
            _ctrl.selection = TextSelection.collapsed(
              offset: _ctrl.text.length,
            );
            if (r.finalResult) _listening = false;
          });
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 30),
          localeId: 'pt_BR',
        ),
      );
    }
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);

    final mealId = await ref
        .read(mealQueueNotifierProvider.notifier)
        .createMeal(
          source: MealSource.aiPhoto,
          photoPath: null,
          userNote: text,
        );

    if (mounted) {
      Navigator.of(context).pop();
      context.push('/confirm?mealId=$mealId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;

    final canSubmit = _ctrl.text.trim().isNotEmpty && !_saving;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Descrever refeição',
            style: GemaTextStyles.headline.copyWith(
              color: isDark ? GemaColors.darkText : GemaColors.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Descreva o que comeu — o Gemini estima os valores nutricionais.',
            style: GemaTextStyles.body.copyWith(color: textSub),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Ex: uma laranja, 2 ovos mexidos com manteiga e café com leite',
              hintStyle: GemaTextStyles.body.copyWith(color: textSub),
              filled: true,
              fillColor: surfaceVar,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_sttAvailable)
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _listening
                          ? Colors.redAccent.withValues(alpha: 0.15)
                          : surfaceVar,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _listening
                            ? Colors.redAccent
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _listening ? Icons.mic : Icons.mic_none,
                          size: 16,
                          color: _listening ? Colors.redAccent : textSub,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _listening ? 'Ouvindo…' : 'Falar',
                          style: GemaTextStyles.label.copyWith(
                            color: _listening ? Colors.redAccent : textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: isDark
                      ? const Color(0xFF2A1800)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Estimar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
