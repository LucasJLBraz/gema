import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/algorithms/tdee_algorithms.dart';
import '../../../core/gemini/api_key_storage.dart' as gemini;
import '../../../core/theme/app_theme.dart';
import '../../goals/models/goal.dart';
import '../../goals/providers/goal_provider.dart';
import '../../weight/providers/weight_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;
  final _pageController = PageController();

  // Step 1 — physical data
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _isMale = true;

  // Step 2 — body composition
  final _bfCtrl = TextEditingController();

  // Step 3 — goal
  GoalType _goalType = GoalType.cut;
  final _targetWeightCtrl = TextEditingController();
  final _deficitCtrl = TextEditingController(text: '500');
  double _activityFactor = 1.55;

  // Step 4 — app config
  final _apiKeyCtrl = TextEditingController();
  bool _apiKeyVisible = false;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    _bfCtrl.dispose();
    _targetWeightCtrl.dispose();
    _deficitCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  bool _canAdvance() {
    switch (_page) {
      case 0:
        return _weightCtrl.text.isNotEmpty &&
            _heightCtrl.text.isNotEmpty &&
            _ageCtrl.text.isNotEmpty;
      case 1:
        return true;
      case 2:
        return _deficitCtrl.text.isNotEmpty;
      case 3:
        return _apiKeyCtrl.text.trim().isNotEmpty;
    }
    return false;
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final weightKg = double.parse(_weightCtrl.text);
      final heightCm = double.parse(_heightCtrl.text);
      final age = int.parse(_ageCtrl.text);
      final bf = _bfCtrl.text.isNotEmpty ? double.tryParse(_bfCtrl.text) : null;
      final deficit = int.parse(_deficitCtrl.text);
      final targetWeight = _targetWeightCtrl.text.isNotEmpty
          ? double.tryParse(_targetWeightCtrl.text)
          : null;

      final bmr = computeBmr(
        weightKg: weightKg,
        heightCm: heightCm,
        ageYears: age,
        isMale: _isMale,
        bodyFatPct: bf,
      );
      final tdee = bmr * _activityFactor;
      final kcalTarget = (tdee - deficit).round().clamp(1200, 9999);
      final macros = macrosFromKcal(kcalTarget);

      final goal = Goal()
        ..effectiveFrom = DateTime.now()
        ..goalType = _goalType
        ..targetWeight = targetWeight
        ..priorActivityFactor = _activityFactor
        ..bmr = bmr
        ..tdee = tdee
        ..kcalTarget = kcalTarget
        ..proteinTargetG = macros.proteinG
        ..carbTargetG = macros.carbG
        ..fatTargetG = macros.fatG
        ..heightCm = heightCm
        ..weightKg = weightKg
        ..ageYears = age
        ..isMale = _isMale
        ..bodyFatPct = bf;

      await ref.read(goalNotifierProvider.notifier).save(goal);
      await ref
          .read(weightNotifierProvider.notifier)
          .log(weightKg, bodyFatPct: bf);
      await gemini.saveApiKey(_apiKeyCtrl.text.trim());

      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Erro: verifique os dados e tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(current: _page, total: 4, primary: primary),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _StepPhysical(
                    weightCtrl: _weightCtrl,
                    heightCtrl: _heightCtrl,
                    ageCtrl: _ageCtrl,
                    isMale: _isMale,
                    onGenderChanged: (v) => setState(() => _isMale = v),
                  ),
                  _StepBodyComp(bfCtrl: _bfCtrl),
                  _StepGoal(
                    goalType: _goalType,
                    targetWeightCtrl: _targetWeightCtrl,
                    deficitCtrl: _deficitCtrl,
                    activityFactor: _activityFactor,
                    onGoalTypeChanged: (v) => setState(() => _goalType = v),
                    onActivityChanged: (v) =>
                        setState(() => _activityFactor = v),
                  ),
                  _StepConfig(
                    apiKeyCtrl: _apiKeyCtrl,
                    visible: _apiKeyVisible,
                    onToggleVisibility: () =>
                        setState(() => _apiKeyVisible = !_apiKeyVisible),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    _weightCtrl,
                    _heightCtrl,
                    _ageCtrl,
                    _deficitCtrl,
                    _apiKeyCtrl,
                  ]),
                  builder: (context, _) => ElevatedButton(
                    onPressed: _saving || !_canAdvance() ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_page < 3 ? 'Continuar' : 'Começar'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.current,
    required this.total,
    required this.primary,
  });
  final int current;
  final int total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active ? primary : primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepPhysical extends StatelessWidget {
  const _StepPhysical({
    required this.weightCtrl,
    required this.heightCtrl,
    required this.ageCtrl,
    required this.isMale,
    required this.onGenderChanged,
  });
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController ageCtrl;
  final bool isMale;
  final ValueChanged<bool> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados físicos',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Usados apenas para calcular seu gasto energético basal.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          _field(
            context,
            weightCtrl,
            'Peso atual (kg)',
            TextInputType.number,
            key: const Key('onboarding-weight-field'),
          ),
          const SizedBox(height: 14),
          _field(
            context,
            heightCtrl,
            'Altura (cm)',
            TextInputType.number,
            key: const Key('onboarding-height-field'),
          ),
          const SizedBox(height: 14),
          _field(
            context,
            ageCtrl,
            'Idade',
            TextInputType.number,
            key: const Key('onboarding-age-field'),
          ),
          const SizedBox(height: 20),
          Text('Sexo biológico', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Masculino')),
              ButtonSegment(value: false, label: Text('Feminino')),
            ],
            selected: {isMale},
            onSelectionChanged: (s) => onGenderChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _StepBodyComp extends StatelessWidget {
  const _StepBodyComp({required this.bfCtrl});
  final TextEditingController bfCtrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Composição corporal',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Opcional. Se informado, usa Katch-McArdle (mais preciso).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          _field(
            context,
            bfCtrl,
            '% gordura corporal (opcional)',
            TextInputType.number,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => bfCtrl.clear(),
            child: const Text('Não sei — pular'),
          ),
        ],
      ),
    );
  }
}

class _StepGoal extends StatelessWidget {
  const _StepGoal({
    required this.goalType,
    required this.targetWeightCtrl,
    required this.deficitCtrl,
    required this.activityFactor,
    required this.onGoalTypeChanged,
    required this.onActivityChanged,
  });
  final GoalType goalType;
  final TextEditingController targetWeightCtrl;
  final TextEditingController deficitCtrl;
  final double activityFactor;
  final ValueChanged<GoalType> onGoalTypeChanged;
  final ValueChanged<double> onActivityChanged;

  static const _activityLabels = [
    (1.2, 'Sedentário'),
    (1.375, 'Levemente ativo'),
    (1.55, 'Moderadamente ativo'),
    (1.725, 'Muito ativo'),
    (1.9, 'Extremamente ativo'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meta', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text('Objetivo', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          SegmentedButton<GoalType>(
            segments: const [
              ButtonSegment(value: GoalType.cut, label: Text('Corte')),
              ButtonSegment(
                value: GoalType.maintain,
                label: Text('Manutenção'),
              ),
              ButtonSegment(value: GoalType.bulk, label: Text('Ganho')),
            ],
            selected: {goalType},
            onSelectionChanged: (s) => onGoalTypeChanged(s.first),
          ),
          const SizedBox(height: 20),
          _field(
            context,
            targetWeightCtrl,
            'Peso-alvo (kg, opcional)',
            TextInputType.number,
          ),
          const SizedBox(height: 14),
          _field(
            context,
            deficitCtrl,
            'Déficit/superávit desejado (kcal/dia)',
            TextInputType.number,
          ),
          const SizedBox(height: 20),
          Text(
            'Nível de atividade',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          RadioGroup<double>(
            groupValue: activityFactor,
            onChanged: (v) {
              if (v != null) onActivityChanged(v);
            },
            child: Column(
              children: [
                ..._activityLabels.map(
                  (pair) => RadioListTile<double>(
                    title: Text(pair.$2),
                    subtitle: Text(
                      '×${pair.$1}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: pair.$1,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConfig extends StatelessWidget {
  const _StepConfig({
    required this.apiKeyCtrl,
    required this.visible,
    required this.onToggleVisibility,
  });
  final TextEditingController apiKeyCtrl;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chave da API',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'O GEMA usa Gemini para analisar suas refeições. A chave é salva somente no seu celular — nunca enviamos nada para nossos servidores.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textSub),
          ),
          const SizedBox(height: 24),

          // Step-by-step instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceVar,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como obter sua chave gratuita',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _Step(
                  number: '1',
                  primary: primary,
                  text:
                      'Abra aistudio.google.com no navegador. Faça login com sua conta Google.',
                ),
                _Step(
                  number: '2',
                  primary: primary,
                  text:
                      'Clique em "Get API key" no menu lateral esquerdo. Em seguida, "Create API key".',
                ),
                _Step(
                  number: '3',
                  primary: primary,
                  text:
                      'Selecione "Create API key in new project" (ou escolha um projeto existente). Clique em "Create".',
                ),
                _Step(
                  number: '4',
                  primary: primary,
                  text:
                      'Copie a chave gerada — ela começa com "AIza". Cole no campo abaixo.',
                ),
                const SizedBox(height: 6),
                Text(
                  'A chave gratuita tem limite de 15 requisições/minuto e 1.000/dia — suficiente para uso pessoal normal.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            key: const Key('onboarding-api-key-field'),
            controller: apiKeyCtrl,
            obscureText: !visible,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Chave da API Gemini',
              hintText: 'AIza...',
              suffixIcon: IconButton(
                icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Você pode alterar ou trocar a chave depois em Configurações.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSub),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.primary,
    required this.text,
  });
  final String number;
  final Color primary;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

Widget _field(
  BuildContext context,
  TextEditingController ctrl,
  String label,
  TextInputType type, {
  Key? key,
}) {
  return TextField(
    key: key,
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(labelText: label),
  );
}
