import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/weight_provider.dart';

class LogWeightDialog extends ConsumerStatefulWidget {
  const LogWeightDialog({super.key});

  @override
  ConsumerState<LogWeightDialog> createState() => _LogWeightDialogState();
}

class _LogWeightDialogState extends ConsumerState<LogWeightDialog> {
  final _kgCtrl = TextEditingController();
  final _bfCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _kgCtrl.dispose();
    _bfCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final kg = double.parse(_kgCtrl.text.replaceAll(',', '.'));
    final bfText = _bfCtrl.text.trim().replaceAll(',', '.');
    final bf = bfText.isEmpty ? null : double.tryParse(bfText);
    await ref.read(weightNotifierProvider.notifier).log(kg, bodyFatPct: bf);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSub = isDark ? GemaColors.darkTextSub : GemaColors.lightTextSub;

    return AlertDialog(
      title: const Text('Registrar peso'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _kgCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                suffixText: 'kg',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o peso';
                final val = double.tryParse(v.replaceAll(',', '.'));
                if (val == null || val < 20 || val > 500) {
                  return 'Peso inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bfCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Gordura corporal (opcional)',
                suffixText: '%',
                hintText: '',
                hintStyle: GemaTextStyles.body.copyWith(color: textSub),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final val = double.tryParse(v.replaceAll(',', '.'));
                if (val == null || val < 1 || val > 70) return '1–70%';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
