import 'dart:convert';
import 'package:flutter/services.dart';

class SurahInfoLoader {
  static Map<String, dynamic>? _cache;

  /// Load surah_info.json from assets
  static Future<Map<String, dynamic>> load() async {
    if (_cache != null) return _cache!;
    final data = await rootBundle.loadString('assets/surah_info.json');
    _cache = json.decode(data);
    return _cache!;
  }
}
