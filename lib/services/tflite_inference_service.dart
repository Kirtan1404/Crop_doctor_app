import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/disease_result.dart';
import 'inference_service.dart';

/// DAY 2: The real, 100%-offline AI. Runs your trained TFLite model
/// directly on the phone — no internet call, ever.
///
/// SETUP:
/// 1. Put your trained model at assets/model/model.tflite
/// 2. Put its labels file at assets/model/labels.txt
///    (one class name per line, e.g. "tomato_early_blight" — name your
///    Teachable Machine classes exactly like your treatments.json keys
///    so the lookup works automatically)
/// 3. Uncomment the two asset lines in pubspec.yaml
/// 4. In home_screen.dart, change:
///      final InferenceService _inference = MockInferenceService();
///    to:
///      final InferenceService _inference = TFLiteInferenceService();
class TFLiteInferenceService implements InferenceService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Teachable Machine models are usually trained at 224x224.
  // If your model uses a different size, change this to match.
  static const int inputSize = 224;

  Future<void> _load() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
    final labelData = await rootBundle.loadString('assets/model/labels.txt');
    _labels = labelData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        // Some exporters prefix each line with an index, e.g. "0 tomato_healthy"
        .map((e) => e.replaceFirst(RegExp(r'^\d+\s*'), ''))
        .toList();
  }

  @override
  Future<DiseaseResult> classify(File imageFile) async {
    await _load();

    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) {
      throw Exception('Could not read image file');
    }
    final resized = img.copyResize(rawImage, width: inputSize, height: inputSize);

    // Build a normalized [1, inputSize, inputSize, 3] input tensor (0.0-1.0)
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter!.run(input, output);

    final scores = output[0];
    var bestIndex = 0;
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    final key = _labels[bestIndex];
    return DiseaseResult(
      diseaseKey: key,
      displayName: _prettify(key),
      confidence: bestScore,
    );
  }

  String _prettify(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
