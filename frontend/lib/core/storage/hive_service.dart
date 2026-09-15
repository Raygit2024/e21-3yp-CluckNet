import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String cacheBoxName = 'clucknet_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(cacheBoxName);
  }

  static Box get _box => Hive.box(cacheBoxName);

  // General caching helpers
  static Future<void> cacheData(String key, dynamic value) async {
    if (value == null) {
      await _box.delete(key);
      return;
    }
    
    // Convert maps or lists to json string for safe storage
    if (value is Map || value is List) {
      await _box.put(key, jsonEncode(value));
    } else {
      await _box.put(key, value);
    }
  }

  static dynamic getCachedData(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    
    try {
      if (raw is String && (raw.startsWith('{') || raw.startsWith('['))) {
        return jsonDecode(raw);
      }
    } catch (_) {}
    return raw;
  }

  static Future<void> clearCache() async {
    await _box.clear();
  }
}
