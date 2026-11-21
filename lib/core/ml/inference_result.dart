import 'dart:typed_data';

/// Data class hasil inferensi model klasifikasi daun (MobileNetV2).
class LeafInferenceResult {
  /// Label kelas prediksi teratas.
  final String className;

  /// Indeks kelas prediksi teratas.
  final int classIndex;

  /// Confidence prediksi (0.0 – 1.0).
  final double confidence;

  /// Confidence dalam persen (0–100).
  double get confidencePercent => confidence * 100;

  /// True jika daun terdeteksi sehat.
  bool get isHealthy => className.toLowerCase().contains('healthy');

  /// True jika confidence memenuhi threshold yang dikonfigurasi.
  final bool isHighConfidence;

  const LeafInferenceResult({
    required this.className,
    required this.classIndex,
    required this.confidence,
    required this.isHighConfidence,
  });

  @override
  String toString() =>
      'LeafResult(class=$className, conf=${(confidence * 100).toStringAsFixed(1)}%, highConf=$isHighConfidence)';
}

/// Data class satu deteksi buah (YOLOv5n).
class FruitDetection {
  /// Label kelas terdeteksi.
  final String className;

  /// Indeks kelas.
  final int classIndex;

  /// Confidence total (objectness * class confidence).
  final double confidence;

  /// Confidence dalam persen (0–100).
  double get confidencePercent => confidence * 100;

  /// Bounding box dalam koordinat piksel gambar asli: [left, top, right, bottom].
  final Rect boundingBox;

  /// True jika buah sehat.
  bool get isHealthy => className.toLowerCase().contains('healthy');

  /// True jika confidence memenuhi threshold.
  final bool isHighConfidence;

  const FruitDetection({
    required this.className,
    required this.classIndex,
    required this.confidence,
    required this.boundingBox,
    required this.isHighConfidence,
  });

  @override
  String toString() =>
      'FruitDetection(class=$className, conf=${(confidence * 100).toStringAsFixed(1)}%, box=$boundingBox)';
}

/// Bounding box sederhana dalam koordinat piksel.
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Rect(this.left, this.top, this.right, this.bottom);

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  @override
  String toString() =>
      'Rect(l=${left.toStringAsFixed(1)}, t=${top.toStringAsFixed(1)}, r=${right.toStringAsFixed(1)}, b=${bottom.toStringAsFixed(1)})';
}

/// Hasil inferensi model deteksi buah (YOLOv5n).
class FruitInferenceResult {
  /// Daftar deteksi setelah NMS.
  final List<FruitDetection> detections;

  /// True jika tidak ada deteksi sama sekali setelah NMS.
  bool get isEmpty => detections.isEmpty;

  /// True jika semua deteksi berkeyakinan tinggi.
  bool get allHighConfidence =>
      detections.isNotEmpty && detections.every((d) => d.isHighConfidence);

  /// True jika ada deteksi berkeyakinan rendah.
  bool get hasLowConfidence =>
      detections.any((d) => !d.isHighConfidence);

  /// Jumlah deteksi per kelas.
  Map<String, int> get countByClass {
    final map = <String, int>{};
    for (final d in detections) {
      map[d.className] = (map[d.className] ?? 0) + 1;
    }
    return map;
  }

  const FruitInferenceResult({required this.detections});

  @override
  String toString() => 'FruitResult(${detections.length} detections)';
}

/// Enum status validasi dan inference untuk UI.
enum ScanStatus {
  /// Belum ada gambar.
  idle,

  /// Sedang memvalidasi kualitas gambar.
  validatingImage,

  /// Gambar tidak memenuhi kualitas teknis.
  imageTechnicallyInvalid,

  /// Sedang memvalidasi apakah objek cabai.
  validatingObject,

  /// Objek bukan cabai (atau validasi gagal/tidak tersedia).
  invalidObject,

  /// Sedang menjalankan inference model utama.
  inferring,

  /// Inference berhasil dengan confidence tinggi.
  resultHighConfidence,

  /// Inference berhasil tetapi confidence rendah.
  resultLowConfidence,

  /// Inference selesai tetapi tidak ada deteksi (hanya untuk buah).
  noDetection,

  /// Error tidak terduga saat inference.
  error,
}

/// Status validasi kualitas gambar.
class ImageValidationResult {
  final bool isValid;
  final String? reason;

  const ImageValidationResult.valid() : isValid = true, reason = null;
  const ImageValidationResult.invalid(String this.reason) : isValid = false;
}
