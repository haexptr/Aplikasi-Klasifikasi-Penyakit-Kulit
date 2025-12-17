// lib/models/prediction.dart
import '../utils/constants.dart';

class Prediction {
  final int? id;
  final String imagePath;
  final String diseaseName;
  final double confidence; // 0..1 normalized
  final String top3Predictions; // JSON string
  final DateTime createdAt;

  Prediction({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.top3Predictions,
    required this.createdAt,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'disease_name': diseaseName,
      // store as double (0..1)
      'confidence': confidence,
      'top3_predictions': top3Predictions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert from Map (Database)
  factory Prediction.fromMap(Map<String, dynamic> map) {
    // map['confidence'] could be stored as int/double/string; normalize robustly
    double rawConf;
    final c = map['confidence'];
    if (c is int) {
      rawConf = c.toDouble();
    } else if (c is double) {
      rawConf = c;
    } else if (c is String) {
      rawConf = double.tryParse(c) ?? 0.0;
    } else {
      rawConf = 0.0;
    }

    final normalized = AppConstants.normalizeConfidence(rawConf);

    return Prediction(
      id: map['id'] is int ? map['id'] as int : (map['id'] != null ? int.tryParse('${map['id']}') : null),
      imagePath: map['image_path'] ?? '',
      diseaseName: map['disease_name'] ?? '',
      confidence: normalized,
      top3Predictions: map['top3_predictions'] ?? '[]',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class PredictionResult {
  final String label;
  final double confidence; // should be 0..1

  PredictionResult({
    required this.label,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
    };
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // json['confidence'] might be int/double/string -> robust parse
    double rawConf = 0.0;
    final c = json['confidence'];
    if (c is int) {
      rawConf = c.toDouble();
    } else if (c is double) {
      rawConf = c;
    } else if (c is String) {
      rawConf = double.tryParse(c) ?? 0.0;
    }

    final normalized = AppConstants.normalizeConfidence(rawConf);

    return PredictionResult(
      label: json['label'] ?? '',
      confidence: normalized,
    );
  }

  @override
  String toString() => 'PredictionResult(label: $label, confidence: $confidence)';
}
