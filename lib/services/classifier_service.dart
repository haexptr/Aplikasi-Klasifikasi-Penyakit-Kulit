// lib/services/classifier_service.dart
import 'dart:io';
import 'dart:math';
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
  int? _modelOutputSize;

  static final ClassifierService _instance = ClassifierService._internal();
  factory ClassifierService() => _instance;
  ClassifierService._internal();

  bool get isInitialized => _isInitialized;

  Future<void> initialize({int? numThreads}) async {
    try {
      final options = InterpreterOptions();
      if (numThreads != null && numThreads > 0) {
        options.threads = numThreads;
      }

      _interpreter = await Interpreter.fromAsset(
        AppConstants.modelPath,
        options: options,
      );
      debugPrint('Model loaded successfully');

      // read output tensor shape (if available)
      try {
        final outTensor = _interpreter!.getOutputTensor(0);
        final outShape = outTensor.shape; // e.g. [1, N]
        _modelOutputSize = outShape.isNotEmpty ? outShape.last : null;
        debugPrint('Model output shape: $outShape, output size: $_modelOutputSize');
      } catch (e) {
        debugPrint('Warning: could not read output tensor shape: $e');
      }

      final labelsData = await rootBundle.loadString(AppConstants.labelsPath);
      _labels = labelsData
          .split('\n')
          .map((s) => s.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      if (_modelOutputSize != null && _labels.length != _modelOutputSize) {
        debugPrint(
            'Warning: Label count mismatch: labels=${_labels.length}, model_output=$_modelOutputSize');
      }

      debugPrint('Labels loaded: ${_labels.length} categories');
      _isInitialized = true;
    } catch (e, st) {
      debugPrint('Error initializing classifier: $e\n$st');
      _isInitialized = false;
      rethrow;
    }
  }

  // Preprocess: returns List shaped [1, H, W, 3] of doubles with EfficientNet normalization [-1,1]
// tambahkan import di atas file (jika belum): import 'dart:math';
List<List<List<List<double>>>> _preprocessImage(img.Image image) {
  final int size = AppConstants.inputSize;

  final img.Image resized = img.copyResize(
    image,
    width: size,
    height: size,
    interpolation: img.Interpolation.linear,
  );

  // helper: ekstraksi RGB yang kompatibel dengan berbagai versi package:image
  int _extractR(dynamic pixel) {
    if (pixel is int) {
      // pixel biasanya ARGB 0xAARRGGBB
      return (pixel >> 16) & 0xFF;
    }
    // Pixel class (package:image newer versions) -> has r property
    try {
      return (pixel.r as int);
    } catch (_) {}
    // fallback: try as map-like
    try {
      return (pixel['r'] as int);
    } catch (_) {}
    return 0;
  }

  int _extractG(dynamic pixel) {
    if (pixel is int) {
      return (pixel >> 8) & 0xFF;
    }
    try {
      return (pixel.g as int);
    } catch (_) {}
    try {
      return (pixel['g'] as int);
    } catch (_) {}
    return 0;
  }

  int _extractB(dynamic pixel) {
    if (pixel is int) {
      return pixel & 0xFF;
    }
    try {
      return (pixel.b as int);
    } catch (_) {}
    try {
      return (pixel['b'] as int);
    } catch (_) {}
    return 0;
  }

  return [
    List.generate(size, (y) {
      return List.generate(size, (x) {
        final dynamic pixel = resized.getPixel(x, y); // dynamic, handle below
        final int r = _extractR(pixel);
        final int g = _extractG(pixel);
        final int b = _extractB(pixel);

        // EfficientNet preprocess: (v/255 - 0.5) * 2 -> [-1, 1]
        final double rf = (r / 255.0 - 0.5) * 2.0;
        final double gf = (g / 255.0 - 0.5) * 2.0;
        final double bf = (b / 255.0 - 0.5) * 2.0;

        return [rf, gf, bf];
      });
    }),
  ];
}

  // Softmax helper
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    final maxLogit = logits.reduce(max);
    final exps = logits.map((v) => mathExp(v - maxLogit)).toList();
    final sumExp = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExp).toList();
  }

  double mathExp(double v) => exp(v); // using dart:math exp

  /// Classify an image and return top N predictions (confidences are probabilities 0..1)
  Future<List<PredictionResult>> classifyImage(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Classifier not initialized');
    }

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess
      final input = _preprocessImage(image);

      final int outSize = _modelOutputSize ?? _labels.length;
      // prepare output container shape [1, outSize]
      final output = List.generate(1, (_) => List.filled(outSize, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Convert output to List<double>
      final List<double> raw = output[0].map((e) => (e as num).toDouble()).toList();

      // Debug raw
      try {
        debugPrint('TFLite raw output (len=${raw.length}): ${raw.take(10).toList()} ${raw.length > 10 ? '...' : ''}');
      } catch (_) {}

      // Detect whether the output is likely already probabilities.
      // If any value < 0 OR sum not ~1, treat as logits and softmax.
      final sum = raw.fold(0.0, (p, n) => p + n);
      final anyNegative = raw.any((v) => v < 0.0);
      final isProbLike = !anyNegative && (sum > 0.999 && sum < 1.001);

      List<double> probs;
      if (isProbLike) {
        probs = raw.map((v) => AppConstants.normalizeConfidence(v)).toList();
      } else {
        // treat as logits or unnormalized scores -> apply softmax
        try {
          probs = _softmax(raw);
        } catch (e) {
          // fallback: normalize by max & sum
          final maxV = raw.reduce(max);
          final shifted = raw.map((v) => v - maxV).map((v) => exp(v)).toList();
          final s = shifted.fold(0.0, (p, n) => p + n);
          probs = shifted.map((v) => v / (s == 0 ? 1 : s)).toList();
        }
      }

      // build predictions list (limit by labels length & output length)
      final List<PredictionResult> predictions = [];
      final limit = min(_labels.length, probs.length);
      for (int i = 0; i < limit; i++) {
        // probs already sum to 1 and in 0..1
        final p = AppConstants.normalizeConfidence(probs[i]);
        predictions.add(PredictionResult(label: _labels[i], confidence: p));
      }

      // sort descending
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      // debug top3
      try {
        final top3Dbg = predictions.take(3).map((p) => '${p.label}:${(p.confidence * 100).toStringAsFixed(1)}%').toList();
        debugPrint('Top3 predictions: $top3Dbg');
      } catch (_) {}

      return predictions.take(AppConstants.numResults).toList();
    } catch (e, st) {
      debugPrint('Error during classification: $e\n$st');
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
