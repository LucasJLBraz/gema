import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String barcode;

  late String name;
  String? brand;
  late double kcal100g;
  late double protein100g;
  late double carb100g;
  late double fat100g;
  late DateTime lastScannedAt;
}
