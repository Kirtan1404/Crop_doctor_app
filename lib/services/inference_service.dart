import 'dart:io';
import 'dart:math';
import '../models/disease_result.dart';

/// Anything that can look at a photo and return a diagnosis implements this.
/// This lets the rest of the app not care whether it's talking to the
/// mock AI (Day 1) or the real on-device model (Day 2+).
abstract class InferenceService {
  Future<DiseaseResult> classify(File imageFile);
}

/// DAY 1: A fake AI so the whole app works end-to-end before you have a
/// trained model. It "analyzes" for 2 seconds, then returns a random
/// realistic-looking result. Swap this out in home_screen.dart once your
/// real model is ready — see TFLiteInferenceService in
/// tflite_inference_service.dart.
class MockInferenceService implements InferenceService {
  final _rand = Random();

  final _sample = const [
    DiseaseResult(diseaseKey: 'tomato_early_blight', displayName: 'Tomato — Early Blight', confidence: 0.91),
    DiseaseResult(diseaseKey: 'tomato_late_blight', displayName: 'Tomato — Late Blight', confidence: 0.88),
    DiseaseResult(diseaseKey: 'tomato_healthy', displayName: 'Tomato — Healthy', confidence: 0.97),
    DiseaseResult(diseaseKey: 'potato_early_blight', displayName: 'Potato — Early Blight', confidence: 0.86),
    DiseaseResult(diseaseKey: 'apple_scab', displayName: 'Apple — Scab', confidence: 0.85),
    DiseaseResult(diseaseKey: 'corn_common_rust', displayName: 'Corn — Common Rust', confidence: 0.90),
  ];

  @override
  Future<DiseaseResult> classify(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2)); // feels like real analysis
    return _sample[_rand.nextInt(_sample.length)];
  }
}
