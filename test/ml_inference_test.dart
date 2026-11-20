import 'package:capsee/core/ml/inference_result.dart';
import 'package:capsee/core/ml/image_preprocessor.dart';
import 'package:capsee/core/ml/model_config.dart';
import 'package:capsee/core/ml/non_max_suppression.dart';
import 'package:flutter_test/flutter_test.dart';

FruitDetection det({
  required double left,
  required double top,
  required double right,
  required double bottom,
  double confidence = 0.9,
  int classIndex = 0,
}) {
  return FruitDetection(
    className: ModelConfig.fruitLabels[classIndex],
    classIndex: classIndex,
    confidence: confidence,
    boundingBox: BoxRect(left, top, right, bottom),
    isHighConfidence:
        confidence >= ModelConfig.fruitConfidenceThreshold,
  );
}

void main() {
  group('NonMaximumSuppression', () {
    const nms = NonMaxSuppression();

    test('menghapus bounding box duplikat kelas yang sama', () {
      final detections = [
        det(left: 10, top: 10, right: 110, bottom: 110, confidence: 0.9),
        det(left: 12, top: 12, right: 112, bottom: 112, confidence: 0.8),
        det(left: 200, top: 200, right: 260, bottom: 260, confidence: 0.7),
      ];

      final result = nms.run(detections, iouThreshold: 0.45);

      expect(result.length, 2);
      expect(result.first.confidence, 0.9);
      expect(result.any((d) => d.confidence == 0.8), isFalse);
    });

    test('mempertahankan box yang tumpang tindih tetapi beda kelas', () {
      final detections = [
        det(left: 10, top: 10, right: 110, bottom: 110, confidence: 0.9),
        det(
          left: 10,
          top: 10,
          right: 110,
          bottom: 110,
          confidence: 0.8,
          classIndex: 1,
        ),
      ];

      final result = nms.run(detections, iouThreshold: 0.45);

      expect(result.length, 2);
    });

    test('tidak error untuk input kosong', () {
      expect(nms.run(const []), isEmpty);
    });
  });

  group('LetterboxInfo', () {
    test('mengembalikan koordinat ke ruang gambar asli', () {
      // Gambar asli 640x480, diskalakan ke 320x240 lalu padding vertikal 40.
      final info = LetterboxInfo()
        ..scale = 0.5
        ..padX = 0
        ..padY = 40
        ..origWidth = 640
        ..origHeight = 480;

      // Box di ruang 320x320: pusat (160,160), ukuran 100x100.
      final coords = info.toOriginalCoords(0.5, 0.5, 100 / 320, 100 / 320);

      expect(coords[0], closeTo(220, 0.01));
      expect(coords[1], closeTo(140, 0.01));
      expect(coords[2], closeTo(420, 0.01));
      expect(coords[3], closeTo(340, 0.01));
    });

    test('clamp koordinat ke batas gambar', () {
      final info = LetterboxInfo()
        ..scale = 1.0
        ..padX = 0
        ..padY = 0
        ..origWidth = 100
        ..origHeight = 100;

      final coords = info.toOriginalCoords(0.9, 0.9, 0.5, 0.5);

      expect(coords[2], lessThanOrEqualTo(100));
      expect(coords[3], lessThanOrEqualTo(100));
    });
  });

  group('Konfigurasi model', () {
    test('urutan & jumlah label daun sesuai training (alfabetis)', () {
      expect(ModelConfig.leafLabels, [
        'Bacterial Spot',
        'Cercospora',
        'Healthy Leaf',
        'Leaf Curl',
        'Nutrition Deficiency',
        'White Spot',
      ]);
      expect(ModelConfig.leafLabels.length, ModelConfig.leafNumClasses);
    });

    test('urutan & jumlah label buah sesuai spesifikasi', () {
      expect(ModelConfig.fruitLabels, [
        'Anthracnose',
        'Fruit Fly',
        'Fruit Rot',
        'Healthy Fruit',
      ]);
      expect(ModelConfig.fruitLabels.length, ModelConfig.fruitNumClasses);
    });
  });
}
