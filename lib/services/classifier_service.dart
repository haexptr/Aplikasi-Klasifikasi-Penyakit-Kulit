import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/constants.dart';
import '../models/prediction.dart';

class ClassifierService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;
  ClassifierService._internal();

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      debugPrint('Model loaded successfully');

      final labelsData = await rootBundle.loadString(AppConstants.labelsPath);
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      
      if (_labels.length != 22) {
        throw Exception('Invalid labels count: expected 22, got ${_labels.length}');
      }
      
      debugPrint('Labels loaded: ${_labels.length} categories');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing classifier: $e');
      _isInitialized = false;
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    img.Image resized = img.copyResize(
      image,
      width: AppConstants.inputSize,
      height: AppConstants.inputSize,
      interpolation: img.Interpolation.linear,
    );

    return List.generate(
      1,
      (_) => List.generate(
        AppConstants.inputSize,
        (y) => List.generate(
          AppConstants.inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
  }

  Future<List<PredictionResult>> classifyImage(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Classifier not initialized');
    }

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      var input = _preprocessImage(image);
      var output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

      _interpreter!.run(input, output);

      List<double> outputList = output[0].cast<double>();

      List<PredictionResult> predictions = [];
      for (int i = 0; i < _labels.length; i++) {
        predictions.add(PredictionResult(
          label: _labels[i],
          confidence: outputList[i],
        ));
      }

      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return predictions.take(AppConstants.numResults).toList();
    } catch (e) {
      debugPrint('Error during classification: $e');
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}