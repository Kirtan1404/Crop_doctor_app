Put your trained model here on Day 2:

- model.tflite
- labels.txt

Then uncomment the two asset lines in pubspec.yaml, and switch
MockInferenceService() to TFLiteInferenceService() in lib/screens/home_screen.dart.

See lib/services/tflite_inference_service.dart for full setup notes.
