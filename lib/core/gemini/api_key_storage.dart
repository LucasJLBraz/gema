import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Split out from gemini_service.dart so that file (and anything that only
// needs callGemini/prompt/schema constants, like tool/benchmark_kcal.dart)
// stays free of Flutter engine dependencies — flutter_secure_storage
// transitively requires dart:ui, which plain `dart run` cannot provide.

const _apiKeyStorageKey = 'gemini_api_key';

const _storage = FlutterSecureStorage();

Future<String?> loadApiKey() => _storage.read(key: _apiKeyStorageKey);

Future<void> saveApiKey(String key) =>
    _storage.write(key: _apiKeyStorageKey, value: key);

Future<void> deleteApiKey() => _storage.delete(key: _apiKeyStorageKey);
