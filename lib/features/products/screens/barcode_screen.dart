import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/db/database.dart';
import '../../../core/theme/app_theme.dart';
import '../../meals/models/meal.dart';
import '../../meals/providers/meal_provider.dart';
import '../models/product.dart';
import '../services/open_food_facts_service.dart';

class BarcodeScreen extends ConsumerStatefulWidget {
  const BarcodeScreen({super.key});

  @override
  ConsumerState<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
  final _scanner = MobileScannerController();
  final _offService = OpenFoodFactsService();

  bool _scanning = true;
  bool _loading = false;
  String? _error;
  _ProductInfo? _found;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _scanning = false;
      _loading = true;
      _error = null;
      _found = null;
    });
    await _scanner.stop();

    // Check local cache first
    final cached = await isar.products.getByBarcode(raw);

    if (cached != null) {
      setState(() {
        _loading = false;
        _found = _ProductInfo.fromProduct(cached);
      });
      return;
    }

    // Network lookup
    final result = await _offService.lookup(raw);
    if (result == null) {
      setState(() {
        _loading = false;
        _error = 'Produto não encontrado.\nTente digitar manualmente.';
      });
      return;
    }

    // Cache locally
    final product = Product()
      ..barcode = raw
      ..name = result.name
      ..brand = result.brand
      ..kcal100g = result.kcal100g
      ..protein100g = result.protein100g
      ..carb100g = result.carb100g
      ..fat100g = result.fat100g
      ..lastScannedAt = DateTime.now();
    await isar.writeTxn(() => isar.products.put(product));

    setState(() {
      _loading = false;
      _found = _ProductInfo(
        name: result.name,
        brand: result.brand,
        kcal100g: result.kcal100g,
        protein100g: result.protein100g,
        carb100g: result.carb100g,
        fat100g: result.fat100g,
        barcode: raw,
      );
    });
  }

  void _reset() {
    setState(() {
      _scanning = true;
      _loading = false;
      _error = null;
      _found = null;
    });
    _scanner.start();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GemaColors.darkSurface : GemaColors.lightSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner de código de barras')),
      body: Stack(
        children: [
          MobileScanner(controller: _scanner, onDetect: _onDetect),
          // Viewfinder overlay
          Center(
            child: Container(
              width: 260,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_error != null)
            _BottomSheet(
              surface: surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GemaTextStyles.body.copyWith(
                      color: isDark
                          ? GemaColors.darkText
                          : GemaColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          if (_found != null)
            _BottomSheet(
              surface: surface,
              child: _ProductCard(
                info: _found!,
                isDark: isDark,
                onAdd: (gramas) => _addMeal(context, gramas),
                onRescan: _reset,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addMeal(BuildContext context, double gramas) async {
    final info = _found!;
    final factor = gramas / 100.0;
    final kcal = (info.kcal100g * factor).round();
    final protein = (info.protein100g * factor).round();
    final carb = (info.carb100g * factor).round();
    final fat = (info.fat100g * factor).round();

    await ref
        .read(mealQueueNotifierProvider.notifier)
        .createMeal(
          source: MealSource.barcode,
          userNote: '${info.name} — ${gramas.round()}g',
          kcalPoint: kcal,
          proteinPoint: protein,
          carbPoint: carb,
          fatPoint: fat,
        );

    if (context.mounted) Navigator.of(context).pop(true);
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.child, required this.surface});
  final Widget child;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.info,
    required this.isDark,
    required this.onAdd,
    required this.onRescan,
  });
  final _ProductInfo info;
  final bool isDark;
  final void Function(double gramas) onAdd;
  final VoidCallback onRescan;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  final _gramCtrl = TextEditingController(text: '100');

  @override
  void dispose() {
    _gramCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.isDark ? GemaColors.darkText : GemaColors.lightText;
    final textSub = widget.isDark
        ? GemaColors.darkTextSub
        : GemaColors.lightTextSub;
    final info = widget.info;

    final gramas =
        double.tryParse(_gramCtrl.text.replaceAll(',', '.')) ?? 100.0;
    final factor = gramas / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.barcode_reader, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                info.brand != null
                    ? '${info.name}  ·  ${info.brand}'
                    : info.name,
                style: GemaTextStyles.title.copyWith(color: text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Macro preview
        _MacroRow(
          kcal: (info.kcal100g * factor).round(),
          protein: (info.protein100g * factor).round(),
          carb: (info.carb100g * factor).round(),
          fat: (info.fat100g * factor).round(),
          isDark: widget.isDark,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _gramCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Gramas',
                  suffixText: 'g',
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.onRescan,
              child: const Text('Re-escanear'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: gramas > 0 ? () => widget.onAdd(gramas) : null,
              child: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Por 100 g: ${info.kcal100g.round()} kcal  ·  P ${info.protein100g.round()}g  C ${info.carb100g.round()}g  G ${info.fat100g.round()}g',
          style: GemaTextStyles.micro.copyWith(
            color: textSub,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.isDark,
  });
  final int kcal, protein, carb, fat;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _chip('$kcal', 'kcal', primary),
        _chip(
          '${protein}g',
          'prot',
          isDark ? GemaColors.chartProteinDark : GemaColors.chartProteinLight,
        ),
        _chip(
          '${carb}g',
          'carb',
          isDark ? GemaColors.chartCarbsDark : GemaColors.chartCarbsLight,
        ),
        _chip(
          '${fat}g',
          'gord',
          isDark ? GemaColors.chartFatDark : GemaColors.chartFatLight,
        ),
      ],
    );
  }

  Widget _chip(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: GemaTextStyles.title.copyWith(color: color)),
        Text(
          label,
          style: GemaTextStyles.micro.copyWith(
            color: color.withValues(alpha: 0.75),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ProductInfo {
  const _ProductInfo({
    required this.name,
    this.brand,
    required this.kcal100g,
    required this.protein100g,
    required this.carb100g,
    required this.fat100g,
    required this.barcode,
  });

  factory _ProductInfo.fromProduct(Product p) => _ProductInfo(
    name: p.name,
    brand: p.brand,
    kcal100g: p.kcal100g,
    protein100g: p.protein100g,
    carb100g: p.carb100g,
    fat100g: p.fat100g,
    barcode: p.barcode,
  );

  final String name;
  final String? brand;
  final double kcal100g;
  final double protein100g;
  final double carb100g;
  final double fat100g;
  final String barcode;
}
