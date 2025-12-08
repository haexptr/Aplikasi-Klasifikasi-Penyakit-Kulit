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
  
  // Colors - Medical Theme (Biru + Putih)
  static const Color primaryColor = Color(0xFF1976D2); // Biru medis
  static const Color secondaryColor = Color(0xFF42A5F5); // Biru muda
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
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
  
  // Helper Methods
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.75) return highConfidence;
    if (confidence >= 0.50) return mediumConfidence;
    return lowConfidence;
  }
  
  static String getConfidenceText(double confidence) {
    if (confidence >= 0.75) return 'Kepercayaan Tinggi';
    if (confidence >= 0.50) return 'Kepercayaan Sedang';
    return 'Kepercayaan Rendah';
  }
  
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}