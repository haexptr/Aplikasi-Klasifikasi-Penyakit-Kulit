import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'disease_info_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final List<PredictionResult> predictions;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.predictions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isSaved = false;

  Future<void> _savePrediction() async {
    try {
      final prediction = Prediction(
        imagePath: widget.imagePath,
        diseaseName: widget.predictions[0].label,
        confidence: widget.predictions[0].confidence,
        top3Predictions: jsonEncode(
          widget.predictions.map((p) => p.toJson()).toList(),
        ),
        createdAt: DateTime.now(),
      );

      await _databaseService.insertPrediction(prediction);
      
      setState(() => _isSaved = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasil disimpan ke riwayat'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPrediction = widget.predictions[0];
    final isLowConfidence = topPrediction.confidence < AppConstants.confidenceThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosis'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 300,
              color: Colors.black,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Gambar tidak dapat ditampilkan'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Low Confidence Warning
                  if (isLowConfidence)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppConstants.lowConfidenceWarning,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Result Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Diagnosis Utama',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Disease Name
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppConstants.diseaseLabelsIndo[topPrediction.label] ?? topPrediction.label,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  topPrediction.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confidence
                          _buildConfidenceIndicator(
                            topPrediction.confidence,
                            isMain: true,
                          ),

                          const SizedBox(height: 16),

                          // Info Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiseaseInfoScreen(
                                      diseaseKey: topPrediction.label,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Lihat Info Penyakit'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Alternative Predictions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kemungkinan Lain',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...widget.predictions.skip(1).map((pred) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAlternativePrediction(pred),
                          )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppConstants.disclaimer,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Diagnosis Lagi'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaved ? null : _savePrediction,
                          icon: Icon(_isSaved ? Icons.check : Icons.save),
                          label: Text(_isSaved ? 'Tersimpan' : 'Simpan'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence, {bool isMain = false}) {
    final percentage = confidence * 100;
    final color = AppConstants.getConfidenceColor(confidence);
    final text = AppConstants.getConfidenceText(confidence);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: isMain ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: isMain ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: isMain ? 12 : 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativePrediction(PredictionResult pred) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppConstants.diseaseLabelsIndo[pred.label] ?? pred.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              AppConstants.formatConfidence(pred.confidence),
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.getConfidenceColor(pred.confidence),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildConfidenceIndicator(pred.confidence),
      ],
    );
  }
}