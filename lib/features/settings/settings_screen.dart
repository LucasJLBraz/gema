import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/algorithms/tdee_algorithms.dart';
import '../../core/gemini/api_key_storage.dart' as gemini;
import '../../core/theme/app_theme.dart';
import '../goals/models/goal.dart';
import '../goals/providers/goal_provider.dart';
import '../weight/providers/weight_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bfCtrl = TextEditingController();
  final _deficitCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();

  bool _isMale = true;
  double _activityFactor = 1.55;
  GoalType _goalType = GoalType.cut;
  bool _apiKeyVisible = false;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  // Cached original weight to detect changes
  double? _originalWeightKg;

  static const _activityOptions = [
    (1.2, 'Sedentário', 'pouco ou sem exercício'),
    (1.375, 'Levemente ativo', 'exercício leve 1–3 dias/semana'),
    (1.55, 'Moderadamente ativo', 'exercício moderado 3–5 dias/semana'),
    (1.725, 'Muito ativo', 'exercício intenso 6–7 dias/semana'),
    (1.9, 'Extra ativo', 'trabalho físico pesado ou atleta'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final goal = await ref.read(activeGoalProvider.future);
    final apiKey = await gemini.loadApiKey();
    if (!mounted) return;

    if (goal != null) {
      _weightCtrl.text = goal.weightKg.toStringAsFixed(1);
      _heightCtrl.text = goal.heightCm.toStringAsFixed(0);
      _ageCtrl.text = goal.ageYears.toString();
      _bfCtrl.text = goal.bodyFatPct?.toStringAsFixed(1) ?? '';
      _isMale = goal.isMale;
      _goalType = goal.goalType;
      _activityFactor = goal.priorActivityFactor ?? 1.55;
      _originalWeightKg = goal.weightKg;

      // Derive stored deficit: positive = cut, negative = bulk
      final storedDeficit = (goal.tdee - goal.kcalTarget).round();
      _deficitCtrl.text = storedDeficit.abs().toString();

      _targetWeightCtrl.text = goal.targetWeight?.toStringAsFixed(1) ?? '';
    }
    if (apiKey != null) _apiKeyCtrl.text = apiKey;

    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    _bfCtrl.dispose();
    _deficitCtrl.dispose();
    _targetWeightCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final weightKg = double.parse(_weightCtrl.text.replaceAll(',', '.'));
      final heightCm = double.parse(_heightCtrl.text.replaceAll(',', '.'));
      final age = int.parse(_ageCtrl.text);
      final bf = _bfCtrl.text.trim().isNotEmpty
          ? double.tryParse(_bfCtrl.text.replaceAll(',', '.'))
          : null;
      final deficitMag = int.tryParse(_deficitCtrl.text) ?? 0;
      final targetWeight = _targetWeightCtrl.text.trim().isNotEmpty
          ? double.tryParse(_targetWeightCtrl.text.replaceAll(',', '.'))
          : null;

      // Positive deficit for cut, negative for bulk, 0 for maintain
      final adjustment = switch (_goalType) {
        GoalType.cut => deficitMag,
        GoalType.maintain => 0,
        GoalType.bulk => -deficitMag,
      };

      final bmr = computeBmr(
        weightKg: weightKg,
        heightCm: heightCm,
        ageYears: age,
        isMale: _isMale,
        bodyFatPct: bf,
      );
      final tdee = bmr * _activityFactor;
      final kcalTarget = (tdee - adjustment).round().clamp(1200, 9999);
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

      // Log new weight entry only if the value changed
      if (_originalWeightKg == null ||
          (weightKg - _originalWeightKg!).abs() > 0.05) {
        await ref
            .read(weightNotifierProvider.notifier)
            .log(weightKg, bodyFatPct: bf);
      }

      final apiKey = _apiKeyCtrl.text.trim();
      if (apiKey.isNotEmpty) await gemini.saveApiKey(apiKey);

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = 'Verifique os dados e tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    final onPrimary = isDark ? const Color(0xFF2A1800) : Colors.white;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
    final surfaceVar = isDark
        ? GemaColors.darkSurfaceVar
        : GemaColors.lightSurfaceVar;

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Live TDEE preview
    double? previewTdee;
    double? previewKcal;
    try {
      final w = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
      final h = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
      final a = int.tryParse(_ageCtrl.text);
      final bf = _bfCtrl.text.trim().isNotEmpty
          ? double.tryParse(_bfCtrl.text.replaceAll(',', '.'))
          : null;
      final def = int.tryParse(_deficitCtrl.text) ?? 0;
      if (w != null && h != null && a != null) {
        final bmr = computeBmr(
          weightKg: w,
          heightCm: h,
          ageYears: a,
          isMale: _isMale,
          bodyFatPct: bf,
        );
        previewTdee = bmr * _activityFactor;
        final adj = switch (_goalType) {
          GoalType.cut => def,
          GoalType.maintain => 0,
          GoalType.bulk => -def,
        };
        previewKcal = (previewTdee - adj).clamp(1200, 9999).toDouble();
      }
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Section(label: 'DADOS FÍSICOS', textSub: textSub),
            const SizedBox(height: 12),

            // Weight + height row
            Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: _weightCtrl,
                    label: 'Peso',
                    suffix: 'kg',
                    numeric: true,
                    validator: (v) {
                      final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (n == null || n < 20 || n > 500) return 'inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    ctrl: _heightCtrl,
                    label: 'Altura',
                    suffix: 'cm',
                    numeric: true,
                    validator: (v) {
                      final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (n == null || n < 50 || n > 250) return 'inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Age + body fat row
            Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: _ageCtrl,
                    label: 'Idade',
                    suffix: 'anos',
                    numeric: true,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 10 || n > 120) return 'inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    ctrl: _bfCtrl,
                    label: 'Gordura corporal',
                    suffix: '%',
                    numeric: true,
                    required: false,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null || n < 1 || n > 70) return '1–70%';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Sex toggle
            Container(
              decoration: BoxDecoration(
                color: surfaceVar,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleBtn(
                      label: '♂ Masculino',
                      selected: _isMale,
                      primary: primary,
                      surfaceVar: surfaceVar,
                      onTap: () => setState(() => _isMale = true),
                      isLeft: true,
                    ),
                  ),
                  Expanded(
                    child: _ToggleBtn(
                      label: '♀ Feminino',
                      selected: !_isMale,
                      primary: primary,
                      surfaceVar: surfaceVar,
                      onTap: () => setState(() => _isMale = false),
                      isLeft: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _Section(label: 'NÍVEL DE ATIVIDADE', textSub: textSub),
            const SizedBox(height: 12),
            ...(_activityOptions.map(
              (opt) => _ActivityTile(
                factor: opt.$1,
                title: opt.$2,
                subtitle: opt.$3,
                selected: (_activityFactor - opt.$1).abs() < 0.01,
                primary: primary,
                surfaceVar: surfaceVar,
                onTap: () => setState(() => _activityFactor = opt.$1),
              ),
            )),
            const SizedBox(height: 24),

            _Section(label: 'OBJETIVO', textSub: textSub),
            const SizedBox(height: 12),

            // Goal type
            Container(
              decoration: BoxDecoration(
                color: surfaceVar,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  for (final type in GoalType.values)
                    Expanded(
                      child: _ToggleBtn(
                        label: _goalLabel(type),
                        selected: _goalType == type,
                        primary: primary,
                        surfaceVar: surfaceVar,
                        onTap: () => setState(() => _goalType = type),
                        isLeft: type == GoalType.cut,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_goalType != GoalType.maintain) ...[
              _Field(
                ctrl: _deficitCtrl,
                label: _goalType == GoalType.cut
                    ? 'Déficit calórico'
                    : 'Superávit calórico',
                suffix: 'kcal/dia',
                numeric: true,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0 || n > 1500) return '0–1500';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            _Field(
              ctrl: _targetWeightCtrl,
              label: 'Peso alvo',
              suffix: 'kg',
              numeric: true,
              required: false,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n < 20 || n > 500) return 'inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Live TDEE preview card
            if (previewTdee != null && previewKcal != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? GemaColors.darkPrimaryCont
                      : GemaColors.lightPrimaryCont,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PreviewStat(
                      label: 'TDEE estimado',
                      value: '${previewTdee.round()} kcal',
                      color: isDark
                          ? GemaColors.darkOnPrimCont
                          : GemaColors.lightOnPrimCont,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color:
                          (isDark
                                  ? GemaColors.darkOnPrimCont
                                  : GemaColors.lightOnPrimCont)
                              .withValues(alpha: 0.2),
                    ),
                    _PreviewStat(
                      label: 'Meta calórica',
                      value: '${previewKcal.round()} kcal',
                      color: primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            _Section(label: 'CHAVE GEMINI', textSub: textSub),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apiKeyCtrl,
              obscureText: !_apiKeyVisible,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'AIza...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _apiKeyVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _apiKeyVisible = !_apiKeyVisible),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nunca compartilhada — armazenada apenas neste dispositivo.',
              style: GemaTextStyles.micro.copyWith(
                color: textSub,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 28),

            if (_error != null) ...[
              Text(
                _error!,
                style: GemaTextStyles.body.copyWith(
                  color: isDark ? GemaColors.darkError : GemaColors.lightError,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primary,
                  foregroundColor: onPrimary,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar configurações'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _goalLabel(GoalType t) => switch (t) {
    GoalType.cut => '↓ Emagrecer',
    GoalType.maintain => '= Manter',
    GoalType.bulk => '↑ Ganhar',
  };
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.textSub});
  final String label;
  final Color textSub;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: GemaTextStyles.caption.copyWith(color: textSub));
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.suffix,
    this.numeric = false,
    this.required = true,
    this.validator,
  });
  final TextEditingController ctrl;
  final String label;
  final String suffix;
  final bool numeric;
  final bool required;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: required ? label : '$label (opcional)',
        suffixText: suffix,
      ),
      validator: validator,
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.primary,
    required this.surfaceVar,
    required this.onTap,
    required this.isLeft,
  });
  final String label;
  final bool selected;
  final Color primary;
  final Color surfaceVar;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary : surfaceVar,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GemaTextStyles.label.copyWith(
              color: selected ? const Color(0xFF2A1800) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.factor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.primary,
    required this.surfaceVar,
    required this.onTap,
  });
  final double factor;
  final String title;
  final String subtitle;
  final bool selected;
  final Color primary;
  final Color surfaceVar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.12) : surfaceVar,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GemaTextStyles.label.copyWith(
                      color: selected ? primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GemaTextStyles.micro.copyWith(letterSpacing: 0),
                  ),
                ],
              ),
            ),
            Text(
              '×${factor.toStringAsFixed(factor == factor.truncateToDouble() ? 0 : 3)}',
              style: GemaTextStyles.dataMono.copyWith(
                color: selected ? primary : null,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GemaTextStyles.title.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: GemaTextStyles.micro.copyWith(
            color: color.withValues(alpha: 0.7),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
