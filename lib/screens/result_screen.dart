import 'dart:io';
import 'package:flutter/material.dart';
import '../models/disease_result.dart';
import '../models/treatment.dart';
import '../services/inference_service.dart';
import '../services/treatment_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final InferenceService inference;

  const ResultScreen({super.key, required this.imageFile, required this.inference});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  DiseaseResult? _result;
  Treatment? _treatment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final result = await widget.inference.classify(widget.imageFile);
      final treatment = await TreatmentService.getByKey(result.diseaseKey);
      if (!mounted) return;
      setState(() {
        _result = result;
        _treatment = treatment;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong analyzing this photo. Try another one.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(widget.imageFile, height: 240, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            if (_error != null) _ErrorCard(message: _error!),
            if (_error == null && _result == null) const _AnalyzingCard(),
            if (_result != null) ...[
              _ResultCard(result: _result!),
              const SizedBox(height: 16),
              if (_treatment != null)
                _TreatmentCard(treatment: _treatment!)
              else
                _NoDataCard(diseaseName: _result!.displayName),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalyzingCard extends StatelessWidget {
  const _AnalyzingCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing leaf...'),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final DiseaseResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = (result.confidence * 100).toStringAsFixed(0);
    final healthy = result.isHealthy;
    return Card(
      color: healthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              healthy ? Icons.check_circle : Icons.warning_amber_rounded,
              color: healthy ? Colors.green : Colors.orange,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.displayName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$pct% confidence', style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  final Treatment treatment;
  const _TreatmentCard({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(treatment.symptoms),
            const SizedBox(height: 20),
            const Text('Organic treatment', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...treatment.organicTreatment.map((t) => _Bullet(text: t)),
            const SizedBox(height: 20),
            const Text('Prevention', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...treatment.prevention.map((t) => _Bullet(text: t)),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  final String diseaseName;
  const _NoDataCard({required this.diseaseName});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No treatment entry found for "$diseaseName" yet. Add one to assets/data/treatments.json.',
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message),
      ),
    );
  }
}
