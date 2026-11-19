/// Konfigurasi model TFLite CAPSEE.
///
/// Semua path asset, dimensi input, label kelas, dan threshold dapat
/// disesuaikan di sini tanpa mengubah logika inference.
class ModelConfig {
  ModelConfig._();

  // ──────────────────────────────────────────────────────────────────────────
  // Model Klasifikasi Daun – MobileNetV2
  // ──────────────────────────────────────────────────────────────────────────

  /// Path asset model daun (MobileNetV2).
  static const String leafModelPath = 'assets/models/best.tflite';

  /// Ukuran input citra model daun [H, W].
  static const int leafInputSize = 224;

  /// Label kelas output model daun (urutan sesuai training).
  static const List<String> leafLabels = [
    'Leaf Curl',          // 0
    'Bacterial Spot',     // 1
    'Cercospora',         // 2
    'Nutrition Deficiency', // 3
    'White Spot',         // 4
    'Healthy Leaf',       // 5
  ];

  /// Jumlah kelas output model daun.
  static const int leafNumClasses = 6;

  /// Threshold confidence untuk model daun (0–1).
  /// Jika confidence di bawah ini, tampilkan peringatan.
  static double leafConfidenceThreshold = 0.60;

  // ──────────────────────────────────────────────────────────────────────────
  // Model Deteksi Buah – YOLOv5n
  // ──────────────────────────────────────────────────────────────────────────

  /// Path asset model buah (YOLOv5n).
  static const String fruitModelPath = 'assets/models/yolov5n.tflite';

  /// Ukuran input citra model buah [H, W].
  static const int fruitInputSize = 320;

  /// Label kelas output model buah (urutan sesuai training).
  static const List<String> fruitLabels = [
    'Anthracnose',  // 0
    'Fruit Fly',    // 1
    'Fruit Rot',    // 2
    'Healthy Fruit', // 3
  ];

  /// Jumlah kelas output model buah.
  static const int fruitNumClasses = 4;

  /// Output shape YOLOv5n: [1, 6300, 9].
  /// 9 = [cx, cy, w, h, obj_conf, class0, class1, class2, class3]
  static const int yoloAnchors = 6300;

  /// Threshold confidence deteksi (objectness * class conf).
  static double fruitConfidenceThreshold = 0.35;

  /// Threshold IoU untuk Non-Maximum Suppression.
  static double nmsIouThreshold = 0.45;

  /// Confidence minimal agar deteksi diproses (sebelum NMS).
  static double fruitMinObjectConfidence = 0.25;

  // ──────────────────────────────────────────────────────────────────────────
  // Validasi kualitas gambar
  // ──────────────────────────────────────────────────────────────────────────

  /// Resolusi minimum yang dapat diterima (piksel, sisi terpendek).
  static const int minImageDimension = 100;

  /// Threshold kegelapan (mean piksel 0–255). Di bawah ini = terlalu gelap.
  static const double minBrightness = 20.0;

  /// Threshold kecerahan berlebih. Di atas ini = terlalu terang / overexposed.
  static const double maxBrightness = 240.0;

  /// Threshold Laplacian variance untuk blur. Di bawah ini = gambar buram.
  static const double minBlurVariance = 50.0;
}
