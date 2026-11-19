import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_preprocessor.dart';
import 'inference_result.dart';
import 'model_config.dart';
import 'model_loader.dart';
import 'non_max_suppression.dart';

/// Menjalankan inferensi model deteksi buah (YOLOv5n).
///
/// Output tensor YOLOv5n: [1, 6300, 9]
/// Format setiap baris: [cx, cy, w, h, obj_conf, cls0, cls1, cls2, cls3]
/// Semua nilai dalam rentang 0–1 (relatif terhadap input 320×320).
class FruitDetector {
  final _preprocessor = const ImagePreprocessor();
  final _nms = const NonMaxSuppression();

  /// Jalankan inferensi model buah.
  ///
  /// Throws [Exception] jika model gagal dimuat atau terjadi error.
  Future<FruitInferenceResult> detect(Uint8List imageBytes) async {
    // 1. Letterbox preprocessing
    final letterbox = LetterboxInfo();
    final input = _preprocessor.preprocessForFruit(imageBytes, letterbox);

    // 2. Siapkan tensor input [1, 320, 320, 3]
    final size = ModelConfig.fruitInputSize;
    final inputTensor = input.reshape([1, size, size, 3]);

    // 3. Siapkan tensor output [1, 6300, 9]
    final numAnchors = ModelConfig.yoloAnchors;
    final numOutputFields = 5 + ModelConfig.fruitNumClasses; // 9
    final outputTensor = List.generate(
      1,
      (_) => List.generate(
        numAnchors,
        (_) => List<double>.filled(numOutputFields, 0.0),
      ),
    );

    // 4. Load interpreter dan jalankan inference
    final interpreter = await ModelLoader.getFruitInterpreter();
    interpreter.run(inputTensor, outputTensor);

    // 5. Decode output
    final rawDetections = _decodeOutput(
      outputTensor[0] as List<List<double>>,
      letterbox,
    );

    // 6. Jalankan NMS
    final filtered = _nms.run(
      rawDetections,
      iouThreshold: ModelConfig.nmsIouThreshold,
    );

    return FruitInferenceResult(detections: filtered);
  }

  /// Decode output YOLO [6300, 9] menjadi list [FruitDetection].
  ///
  /// Format setiap baris: [cx, cy, w, h, obj_conf, cls0, cls1, cls2, cls3]
  List<FruitDetection> _decodeOutput(
    List<List<double>> rawOutput,
    LetterboxInfo letterbox,
  ) {
    final detections = <FruitDetection>[];
    final minObjConf = ModelConfig.fruitMinObjectConfidence;

    for (final row in rawOutput) {
      if (row.length < 9) continue;

      final cx = row[0];
      final cy = row[1];
      final bw = row[2];
      final bh = row[3];
      final objConf = row[4]; // objectness confidence

      // Filter awal berdasarkan objectness
      if (objConf < minObjConf) continue;

      // Ambil class scores [5..8]
      int topClassIdx = 0;
      double topClassConf = row[5];
      for (int c = 1; c < ModelConfig.fruitNumClasses; c++) {
        final cs = row[5 + c];
        if (cs > topClassConf) {
          topClassConf = cs;
          topClassIdx = c;
        }
      }

      // Total confidence = objectness × class confidence
      final totalConf = objConf * topClassConf;
      if (totalConf < minObjConf) continue;

      // Konversi ke koordinat piksel gambar asli
      final coords = letterbox.toOriginalCoords(cx, cy, bw, bh);
      final box = Rect(coords[0], coords[1], coords[2], coords[3]);

      // Filter box degeneratif
      if (box.width <= 0 || box.height <= 0) continue;

      final className = topClassIdx < ModelConfig.fruitLabels.length
          ? ModelConfig.fruitLabels[topClassIdx]
          : 'Unknown';

      final isHighConf = totalConf >= ModelConfig.fruitConfidenceThreshold;

      detections.add(FruitDetection(
        className: className,
        classIndex: topClassIdx,
        confidence: totalConf,
        boundingBox: box,
        isHighConfidence: isHighConf,
      ));
    }

    return detections;
  }
}
