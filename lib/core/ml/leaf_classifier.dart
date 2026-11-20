import 'dart:math' as math;
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_preprocessor.dart';
import 'inference_result.dart';
import 'model_config.dart';
import 'model_loader.dart';

/// Menjalankan inferensi model klasifikasi daun (MobileNetV2).
///
/// Input : Uint8List bytes gambar (JPEG / PNG).
/// Output: [LeafInferenceResult] dengan kelas, confidence, dan flag keyakinan.
class LeafClassifier {
  final _preprocessor = const ImagePreprocessor();

  /// Jalankan inferensi model daun.
  ///
  /// Throws [Exception] jika model gagal dimuat atau terjadi error inference.
  Future<LeafInferenceResult> classify(Uint8List imageBytes) async {
    // 1. Preprocessing: resize 224×224 + normalisasi [-1,1]
    final input = _preprocessor.preprocessForLeaf(imageBytes);

    // 2. Siapkan tensor input sebagai nested list [1, 224, 224, 3]
    final size = ModelConfig.leafInputSize;
    final inputTensor = input.reshape([1, size, size, 3]);

    // 3. Siapkan tensor output [1, 6]
    final outputTensor = List.generate(
      1,
      (_) => List<double>.filled(ModelConfig.leafNumClasses, 0.0),
    );

    // 4. Load interpreter dan jalankan inference
    final interpreter = await ModelLoader.getLeafInterpreter();
    interpreter.run(inputTensor, outputTensor);

    // 5. Ambil output [6] scores
    final scores = List<double>.from(outputTensor[0]);

    // 6. Cari kelas dengan skor tertinggi
    int topIndex = 0;
    double topScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > topScore) {
        topScore = scores[i];
        topIndex = i;
      }
    }

    // 7. Normalisasi dengan softmax (handle kasus model dengan/tanpa softmax akhir)
    final confidence = _confidenceFromScores(scores, topIndex);

    final isHighConfidence = confidence >= ModelConfig.leafConfidenceThreshold;
    final className = topIndex < ModelConfig.leafLabels.length
        ? ModelConfig.leafLabels[topIndex]
        : 'Unknown';

    return LeafInferenceResult(
      className: className,
      classIndex: topIndex,
      confidence: confidence,
      isHighConfidence: isHighConfidence,
    );
  }

  /// Hitung confidence kelas teratas.
  ///
  /// Jika seluruh skor berada di rentang 0–1 dan totalnya ≈ 1, output sudah
  /// softmax → ambil langsung. Selain itu dianggap logits → softmax manual.
  double _confidenceFromScores(List<double> scores, int topIndex) {
    final sum = scores.fold(0.0, (a, b) => a + b);
    final allProbabilities = scores.every((s) => s >= 0.0 && s <= 1.0);
    if (allProbabilities && (sum - 1.0).abs() < 0.05) {
      return scores[topIndex].clamp(0.0, 1.0);
    }

    // Softmax manual (numerically stable)
    final maxVal = scores.reduce(math.max);
    final exps = scores.map((s) => math.exp(s - maxVal)).toList();
    final sumExp = exps.fold(0.0, (a, b) => a + b);
    if (sumExp == 0) return 0.0;
    return (exps[topIndex] / sumExp).clamp(0.0, 1.0);
  }
}
