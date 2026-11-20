import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'model_config.dart';

/// Preprocessing gambar sebelum diteruskan ke model TFLite.
///
/// Daun (MobileNetV2) : resize bilinear ke 224×224 + normalisasi [-1,1]
///                      (setara `tf.keras.applications.mobilenet_v2.preprocess_input`)
/// Buah (YOLOv5n)     : letterbox ke 320×320 + normalisasi [0,1]
class ImagePreprocessor {
  const ImagePreprocessor();

  // ──────────────────────────────────────────────────────────────────────────
  // MobileNetV2 – Scan Daun
  // ──────────────────────────────────────────────────────────────────────────

  /// Memproses [bytes] untuk model daun MobileNetV2.
  ///
  /// Output: Float32List berbentuk [1 * 224 * 224 * 3] dengan nilai [-1.0, 1.0].
  ///
  /// Model dilatih memakai `mobilenet_v2.preprocess_input`, yaitu
  /// `pixel / 127.5 - 1.0` (bukan `pixel / 255`). Diverifikasi lewat
  /// `tool/eval_leaf_hypotheses.py`: normalisasi [-1,1] memberi akurasi
  /// 63,6% vs 54,5% untuk [0,1] pada 11 gambar uji berlabel.
  Float32List preprocessForLeaf(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw ArgumentError('Gambar tidak dapat didekode.');
    // Terapkan orientasi EXIF agar hasil sama dengan yang ditampilkan Flutter.
    final image = img.bakeOrientation(decoded);

    // Resize ke 224×224
    final resized = img.copyResize(
      image,
      width: ModelConfig.leafInputSize,
      height: ModelConfig.leafInputSize,
      interpolation: img.Interpolation.linear,
    );

    // Normalisasi piksel ke [-1, 1] (MobileNetV2 preprocess_input)
    final size = ModelConfig.leafInputSize;
    final input = Float32List(1 * size * size * 3);
    int index = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = pixel.r / 127.5 - 1.0;
        input[index++] = pixel.g / 127.5 - 1.0;
        input[index++] = pixel.b / 127.5 - 1.0;
      }
    }
    return input;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // YOLOv5n – Scan Buah
  // ──────────────────────────────────────────────────────────────────────────

  /// Memproses [bytes] untuk model buah YOLOv5n dengan letterboxing.
  ///
  /// Output: Float32List berbentuk [1 * 320 * 320 * 3] dengan nilai [0.0, 1.0].
  /// [letterboxInfo] diisi dengan informasi padding untuk konversi balik koordinat.
  Float32List preprocessForFruit(
    Uint8List bytes,
    LetterboxInfo letterboxInfo,
  ) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw ArgumentError('Gambar tidak dapat didekode.');
    // Terapkan orientasi EXIF agar koordinat bounding box cocok dengan
    // gambar yang ditampilkan di layar (Image.memory).
    final image = img.bakeOrientation(decoded);

    final targetSize = ModelConfig.fruitInputSize;
    final origW = image.width.toDouble();
    final origH = image.height.toDouble();

    // Hitung skala dan padding untuk letterbox (skala minimum, seperti YOLOv5)
    final scale = math.min(targetSize / origW, targetSize / origH);
    final newW = (origW * scale).round();
    final newH = (origH * scale).round();
    final padX = (targetSize - newW) ~/ 2;
    final padY = (targetSize - newH) ~/ 2;

    letterboxInfo.scale = scale;
    letterboxInfo.padX = padX;
    letterboxInfo.padY = padY;
    letterboxInfo.origWidth = origW;
    letterboxInfo.origHeight = origH;

    // Resize gambar asli
    final resized = img.copyResize(
      image,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );

    // Buat kanvas target dengan fill abu-abu (114, 114, 114 seperti YOLOv5 default)
    final canvas = img.Image(
      width: targetSize,
      height: targetSize,
      format: img.Format.uint8,
      numChannels: 3,
    );
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));

    // Tempel resized ke tengah canvas
    img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

    // Normalisasi piksel ke [0, 1]
    final input = Float32List(1 * targetSize * targetSize * 3);
    int index = 0;
    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final pixel = canvas.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }
    return input;
  }
}

/// Menyimpan informasi letterbox untuk konversi balik koordinat bounding box.
class LetterboxInfo {
  double scale = 1.0;
  int padX = 0;
  int padY = 0;
  double origWidth = 1.0;
  double origHeight = 1.0;

  /// Konversi koordinat tensor (dalam ruang 320×320 letterboxed) ke piksel gambar asli.
  ///
  /// [cx], [cy], [w], [h] dalam format YOLO (relatif terhadap input 320×320).
  List<double> toOriginalCoords(double cx, double cy, double bw, double bh) {
    final targetSize = ModelConfig.fruitInputSize.toDouble();
    // Konversi dari 0–1 ke piksel letterboxed
    final cx_px = cx * targetSize;
    final cy_px = cy * targetSize;
    final bw_px = bw * targetSize;
    final bh_px = bh * targetSize;

    // Kurangi padding dan bagi dengan skala
    final x1 = (cx_px - bw_px / 2 - padX) / scale;
    final y1 = (cy_px - bh_px / 2 - padY) / scale;
    final x2 = (cx_px + bw_px / 2 - padX) / scale;
    final y2 = (cy_px + bh_px / 2 - padY) / scale;

    // Clamp ke batas gambar asli
    return [
      x1.clamp(0.0, origWidth),
      y1.clamp(0.0, origHeight),
      x2.clamp(0.0, origWidth),
      y2.clamp(0.0, origHeight),
    ];
  }
}
