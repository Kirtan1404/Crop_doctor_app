# Crop Doctor — 3-day sprint guide

This is a working Flutter app. Today it runs with a realistic **fake AI**
(mock mode) so you have a fully functional app immediately. Tomorrow you
swap in a real trained model. No prior Flutter experience needed to follow
these steps — just copy/paste the commands.

---

## DAY 1 — Get it running (1-3 hours)

1. Install Flutter: follow the official installer for your OS at
   `docs.flutter.dev/get-started/install` (includes Android Studio for the
   emulator). This is the only slow step — let it run in the background.
2. Once installed, open a terminal in this `crop_doctor` folder and run:
   ```
   flutter pub get
   ```
3. Plug in your Android phone (enable Developer Options → USB debugging)
   or start an emulator from Android Studio.
4. **Add camera permission.** Open
   `android/app/src/main/AndroidManifest.xml` and add this line just above
   the `<application ...>` tag:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   ```
5. Run the app:
   ```
   flutter run
   ```

You now have a fully working app: home screen → take/pick a photo →
"analyzing" → a disease result with an organic treatment plan. It's using
`MockInferenceService`, so the diagnosis is randomly picked from realistic
sample results — the whole flow, UI, and offline treatment lookup are 100%
real and working.

---

## DAY 2 — Train the real model (3-5 hours)

**Fastest path for a beginner: Google's Teachable Machine (no code).**

1. Go to `teachablemachine.withgoogle.com` → New Project → Image Project →
   Standard image model.
2. Create one class per disease you want to detect. **Name each class
   exactly like the keys in `assets/data/treatments.json`** so the app can
   match them automatically — for example: `tomato_early_blight`,
   `tomato_late_blight`, `tomato_healthy`.
3. Upload 30-80 sample leaf photos per class. Search "PlantVillage dataset"
   (a free public dataset on Kaggle) to get real labeled leaf photos fast —
   download only the folders for the classes you named above.
4. Click **Train Model**.
5. Click **Export Model** → **Tensorflow Lite** → **Floating point** →
   Download. This gives you `model_unquant.tflite` (or similar) and
   `labels.txt`.
6. Rename the `.tflite` file to `model.tflite` and put both files into
   `assets/model/`.
7. In `pubspec.yaml`, uncomment the two model asset lines.
8. In `lib/screens/home_screen.dart`, change:
   ```dart
   final InferenceService _inference = MockInferenceService();
   ```
   to:
   ```dart
   final InferenceService _inference = TFLiteInferenceService();
   ```
   and add this import at the top of the file:
   ```dart
   import '../services/tflite_inference_service.dart';
   ```
9. Run `flutter pub get` again, then `flutter run`. You're now diagnosing
   real photos with a real on-device AI model, fully offline.

If a prediction doesn't match a treatment entry, add it to
`assets/data/treatments.json` — the format is copy-pasteable, just follow
the existing pattern.

---

## DAY 3 — Polish and ship (2-4 hours)

- Test outdoors with real leaves — lighting affects accuracy, so check a
  few real-world photos, not just clean lab-style ones.
- Add more classes/treatments to `treatments.json` if you have time.
- Tighten up anything visual — app icon, splash screen, colors in
  `lib/theme/app_theme.dart`.
- Build a shareable APK:
  ```
  flutter build apk --release
  ```
  The file appears at `build/app/outputs/flutter-apk/app-release.apk` —
  send it to your own phone or anyone testing it.

---

## Project structure
```
lib/
  main.dart                        entry point
  theme/app_theme.dart             colors, buttons, cards
  models/                          data shapes (DiseaseResult, Treatment)
  services/
    inference_service.dart         mock AI (Day 1)
    tflite_inference_service.dart  real on-device AI (Day 2)
    treatment_service.dart         loads the offline treatment database
  screens/
    home_screen.dart                capture screen
    result_screen.dart              diagnosis + treatment screen
assets/
  data/treatments.json              offline disease + organic treatment database
  model/                            put model.tflite + labels.txt here (Day 2)
```
