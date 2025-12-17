import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'DiagnosisKulit';
  static const String appVersion = '1.0.0';
  
  // Model Configuration
  static const String modelPath = 'assets/model_dynamic_quant.tflite';
  static const String labelsPath = 'assets/labels.txt';
  static const int inputSize = 224;
  static const int numResults = 3; // Top 3 predictions
  static const double confidenceThreshold = 0.50; // 50%
  
  // Database
  static const String databaseName = 'diagnosis_kulit.db';
  static const int databaseVersion = 1;
  static const String tableName = 'predictions';
  
  // Colors - Premium Medical Theme
  static const Color primaryColor = Color(0xFF0D47A1); // Premium Deep Blue
  static const Color secondaryColor = Color(0xFF2196F3); // Bright Blue
  static const Color backgroundColor = Color(0xFFF8F9FA); // Clean White/Grey
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1F2C); // Dark Blue-Grey
  static const Color textSecondary = Color(0xFF62757F); // Metal Blue-Grey
  
  // Confidence Colors
  static const Color highConfidence = Color(0xFF4CAF50); // Hijau (≥75%)
  static const Color mediumConfidence = Color(0xFFFF9800); // Oranye (50-75%)
  static const Color lowConfidence = Color(0xFFF44336); // Merah (<50%)
  
  // Disease Labels (22 Categories)
  static const List<String> diseaseLabels = [
    'Acne',
    'Actinic_Keratosis',
    'Benign_tumors',
    'Bullous',
    'Candidiasis',
    'DrugEruption',
    'Eczema',
    'Infestations_Bites',
    'Lichen',
    'Lupus',
    'Moles',
    'Psoriasis',
    'Rosacea',
    'Seborrh_Keratoses',
    'SkinCancer',
    'Sun_Sunlight_Damage',
    'Tinea',
    'Unknown_Normal',
    'Vascular_Tumors',
    'Vasculitis',
    'Vitiligo',
    'Warts',
  ];
  
  // Disease Labels in Indonesian
  static const Map<String, String> diseaseLabelsIndo = {
    'Acne': 'Jerawat',
    'Actinic_Keratosis': 'Keratosis Aktinik',
    'Benign_tumors': 'Tumor Jinak',
    'Bullous': 'Penyakit Kulit Melepuh',
    'Candidiasis': 'Kandidiasis',
    'DrugEruption': 'Erupsi Obat',
    'Eczema': 'Eksim',
    'Infestations_Bites': 'Infestasi & Gigitan',
    'Lichen': 'Liken',
    'Lupus': 'Lupus',
    'Moles': 'Tahi Lalat',
    'Psoriasis': 'Psoriasis',
    'Rosacea': 'Rosacea',
    'Seborrh_Keratoses': 'Keratosis Seboroik',
    'SkinCancer': 'Kanker Kulit',
    'Sun_Sunlight_Damage': 'Kerusakan Sinar Matahari',
    'Tinea': 'Kurap',
    'Unknown_Normal': 'Normal',
    'Vascular_Tumors': 'Tumor Vaskular',
    'Vasculitis': 'Vaskulitis',
    'Vitiligo': 'Vitiligo',
    'Warts': 'Kutil',
  };
  
  // Messages
  static const String disclaimer = 
      'Hasil prediksi hanya bersifat indikatif dan bukan diagnosis medis. '
      'Konsultasikan ke dokter/dermatolog untuk diagnosis dan penanganan yang tepat.';
  
  static const String lowConfidenceWarning = 
      'Hasil kurang yakin, sebaiknya konsultasi dokter.';
  
  static const String welcomeMessage = 
      'Aplikasi ini menggunakan teknologi AI untuk membantu mengidentifikasi '
      'kemungkinan penyakit kulit berdasarkan gambar.';
  
  static const String invalidImageTitle = 'Objek Tidak Dikenali';
  static const String invalidImageMessage = 
      'Sistem kami mendeteksi gambar ini mungkin bukan kondisi kulit atau kualitasnya kurang jelas. '
      'Mohon ambil ulang foto yang fokus pada area kulit.';
  
  // Helper Methods

  /// Normalizes a confidence number into range 0.0 .. 1.0.
  /// Accepts:
  ///  - values already in 0..1 (e.g. 0.95) -> returns same (clamped)
  ///  - values in 0..100 (e.g. 95.72) -> returns 0.9572
  ///  - negative or extreme values are clamped into [0,1]
  static double normalizeConfidence(double confidence) {
    if (confidence.isNaN) return 0.0;
    // If likely a percent (e.g. >1 and <=100), divide by 100
    if (confidence > 1.0 && confidence <= 100.0) {
      confidence = confidence / 100.0;
    }
    // finally clamp to 0..1
    return confidence.clamp(0.0, 1.0);
  }

  /// Returns color based on normalized confidence
  static Color getConfidenceColor(double confidence) {
    final c = normalizeConfidence(confidence);
    if (c >= 0.75) return highConfidence;
    if (c >= 0.50) return mediumConfidence;
    return lowConfidence;
  }
  
  /// Returns human-friendly text based on normalized confidence
  static String getConfidenceText(double confidence) {
    final c = normalizeConfidence(confidence);
    if (c >= 0.75) return 'Kepercayaan Tinggi';
    if (c >= 0.50) return 'Kepercayaan Sedang';
    return 'Kepercayaan Rendah';
  }
  
  /// Produces a percentage string robustly whether input is 0..1 or 0..100.
  /// Example: 0.957 -> '95.7%', 95.7 -> '95.7%'
  static String formatConfidence(double confidence) {
    final c = normalizeConfidence(confidence) * 100.0;
    return '${c.toStringAsFixed(1)}%';
  }
}
