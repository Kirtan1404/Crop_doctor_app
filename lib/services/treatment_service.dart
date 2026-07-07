import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/treatment.dart';

/// Loads disease/treatment info from the bundled JSON file.
/// This never touches the network — it's all shipped inside the app.
class TreatmentService {
  static Map<String, Treatment>? _cache;

  static Future<Map<String, Treatment>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/treatments.json');
    final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
    _cache = data.map(
      (key, value) => MapEntry(key, Treatment.fromJson(key, value as Map<String, dynamic>)),
    );
    return _cache!;
  }

  static Future<Treatment?> getByKey(String key) async {
    final all = await loadAll();
    return all[key];
  }
}
