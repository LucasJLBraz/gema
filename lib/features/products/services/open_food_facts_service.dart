import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsResult {
  const OpenFoodFactsResult({
    required this.name,
    this.brand,
    required this.kcal100g,
    required this.protein100g,
    required this.carb100g,
    required this.fat100g,
  });

  final String name;
  final String? brand;
  final double kcal100g;
  final double protein100g;
  final double carb100g;
  final double fat100g;
}

class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  static const _fields = 'product_name,brands,nutriments';

  Future<OpenFoodFactsResult?> lookup(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl/$barcode.json?fields=$_fields');
      final res = await http
          .get(uri, headers: {'User-Agent': 'GemaApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['status'] != 1) return null;

      final product = body['product'] as Map<String, dynamic>? ?? {};
      final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

      final name = (product['product_name'] as String? ?? '').trim();
      if (name.isEmpty) return null;

      return OpenFoodFactsResult(
        name: name,
        brand: (product['brands'] as String?)?.split(',').first.trim(),
        kcal100g: _n(nutriments['energy-kcal_100g']),
        protein100g: _n(nutriments['proteins_100g']),
        carb100g: _n(nutriments['carbohydrates_100g']),
        fat100g: _n(nutriments['fat_100g']),
      );
    } catch (_) {
      return null;
    }
  }

  double _n(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
