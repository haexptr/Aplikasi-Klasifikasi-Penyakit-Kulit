class Prediction {
  final int? id;
  final String imagePath;
  final String diseaseName;
  final double confidence;
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
      'confidence': confidence,
      'top3_predictions': top3Predictions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert from Map (Database)
  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      id: map['id'],
      imagePath: map['image_path'],
      diseaseName: map['disease_name'],
      confidence: map['confidence'],
      top3Predictions: map['top3_predictions'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class PredictionResult {
  final String label;
  final double confidence;

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
    return PredictionResult(
      label: json['label'],
      confidence: json['confidence'],
    );
  }
}