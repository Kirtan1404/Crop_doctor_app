class Treatment {
  final String key;
  final String displayName;
  final String crop;
  final String symptoms;
  final List<String> organicTreatment;
  final List<String> prevention;
  final String severity; // "low", "medium", "high"

  Treatment({
    required this.key,
    required this.displayName,
    required this.crop,
    required this.symptoms,
    required this.organicTreatment,
    required this.prevention,
    required this.severity,
  });

  factory Treatment.fromJson(String key, Map<String, dynamic> json) {
    return Treatment(
      key: key,
      displayName: json['displayName'] as String,
      crop: json['crop'] as String,
      symptoms: json['symptoms'] as String,
      organicTreatment: List<String>.from(json['organicTreatment'] as List),
      prevention: List<String>.from(json['prevention'] as List),
      severity: json['severity'] as String,
    );
  }
}
