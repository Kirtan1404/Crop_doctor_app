class DiseaseResult {
  /// Matches a key in assets/data/treatments.json, e.g. "tomato_early_blight"
  final String diseaseKey;

  /// Human-readable name, e.g. "Tomato — Early Blight"
  final String displayName;

  /// 0.0 - 1.0
  final double confidence;

  const DiseaseResult({
    required this.diseaseKey,
    required this.displayName,
    required this.confidence,
  });

  bool get isHealthy => diseaseKey.contains('healthy');
}
