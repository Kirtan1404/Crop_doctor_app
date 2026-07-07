import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/inference_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _CropOption {
  final String name;
  final String emoji;
  const _CropOption(this.name, this.emoji);
}

class _HomeScreenState extends State<HomeScreen> {
  final InferenceService _inference = MockInferenceService();
  final ImagePicker _picker = ImagePicker();

  final List<_CropOption> _crops = const [
    _CropOption('Tomato', '🍅'),
    _CropOption('Potato', '🥔'),
    _CropOption('Corn', '🌽'),
    _CropOption('Apple', '🍎'),
    _CropOption('Pepper', '🌶️'),
  ];

  String _selectedCrop = 'Tomato';

  Future<void> _scan(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(imageFile: File(picked.path), inference: _inference),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, color: Colors.white),
            SizedBox(width: 8),
            Text('Crop Doctor'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _crops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final crop = _crops[i];
                  final selected = crop.name == _selectedCrop;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCrop = crop.name),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppTheme.lightGreen.withOpacity(0.25) : Colors.grey.shade100,
                            border: Border.all(
                              color: selected ? AppTheme.primaryGreen : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(height: 6),
                        Text(crop.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🌱', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: rotate your crops each season — it cuts disease risk significantly.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _StepIcon(icon: Icons.center_focus_strong, label: 'Take a\npicture'),
                    Icon(Icons.chevron_right, color: Colors.black26),
                    _StepIcon(icon: Icons.fact_check_outlined, label: 'See\ndiagnosis'),
                    Icon(Icons.chevron_right, color: Colors.black26),
                    _StepIcon(icon: Icons.eco_outlined, label: 'Get\ntreatment'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _scan(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan a crop'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _scan(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from gallery'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StepIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE8F5E9),
          child: Icon(icon, color: AppTheme.primaryGreen),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}