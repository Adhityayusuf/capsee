import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'inference_result.dart';
import 'model_config.dart';

/// Memvalidasi kualitas teknis gambar sebelum diteruskan ke model.
///
/// Pemeriksaan:
/// 1. Gambar berhasil didekode.
/// 2. Resolusi mencukupi.
/// 3. Gambar tidak terlalu gelap.
/// 4. Gambar tidak terlalu terang (overexposed).
/// 5. Gambar tidak terlalu blur (Laplacian variance).
class ImageQualityValidator {
  const ImageQualityValidator();

  /// Validasi gambar dari [bytes] (JPEG / PNG).
  /// Mengembalikan [ImageValidationResult] dengan alasan jika tidak valid.
  Future<ImageValidationResult> validate(Uint8List bytes) async {
    // 1. Dekode gambar
    final image = img.decodeImage(bytes);
    if (image == null) {
      return const ImageValidationResult.invalid(
        'Gambar tidak dapat dibaca. Pastikan format gambar didukung (JPEG/PNG).',
      );
    }

    // 2. Resolusi minimum
    final minDim = image.width < image.height ? image.width : image.height;
    if (minDim < ModelConfig.minImageDimension) {
      return ImageValidationResult.invalid(
        'Resolusi gambar terlalu kecil (${image.width}×${image.height} piksel). '
        'Gunakan gambar dengan resolusi lebih tinggi.',
      );
    }

    // 3 & 4. Kecerahan rata-rata (berbasis channel grayscale)
    final brightness = _meanBrightness(image);
    if (brightness < ModelConfig.minBrightness) {
      return const ImageValidationResult.invalid(
        'Gambar terlalu gelap. Pastikan pencahayaan cukup saat mengambil foto.',
      );
    }
    if (brightness > ModelConfig.maxBrightness) {
      return const ImageValidationResult.invalid(
        'Gambar terlalu terang atau overexposed. '
        'Hindari sinar langsung ke kamera saat mengambil foto.',
      );
    }

    // 5. Deteksi blur (Laplacian variance sederhana pada thumbnail)
    final blurScore = _laplacianVariance(image);
    if (blurScore < ModelConfig.minBlurVariance) {
      return const ImageValidationResult.invalid(
        'Gambar tampak buram. '
        'Pastikan kamera fokus dengan baik sebelum mengambil foto.',
      );
    }

    return const ImageValidationResult.valid();
  }

  /// Hitung kecerahan rata-rata piksel (0–255).
  double _meanBrightness(img.Image image) {
    // Sample tiap 4 piksel untuk efisiensi
    double total = 0;
    int count = 0;
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final p = image.getPixel(x, y);
        // Luminance sederhana
        final gray = (p.r * 0.299 + p.g * 0.587 + p.b * 0.114);
        total += gray;
        count++;
      }
    }
    return count == 0 ? 128.0 : total / count;
  }

  /// Hitung Laplacian variance sebagai ukuran ketajaman gambar.
  /// Nilai tinggi = tajam, nilai rendah = blur.
  double _laplacianVariance(img.Image image) {
    // Resize ke thumbnail 100×100 untuk efisiensi
    final thumb = img.copyResize(image, width: 100, height: 100);
    final int w = thumb.width;
    final int h = thumb.height;

    // Laplacian kernel: [0,1,0,1,-4,1,0,1,0]
    double sumSq = 0;
    double sum = 0;
    int count = 0;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final c = _gray(thumb, x, y);
        final t = _gray(thumb, x, y - 1);
        final b = _gray(thumb, x, y + 1);
        final l = _gray(thumb, x - 1, y);
        final r = _gray(thumb, x + 1, y);
        final lap = t + b + l + r - 4 * c;
        sumSq += lap * lap;
        sum += lap;
        count++;
      }
    }
    if (count == 0) return 0;
    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }

  double _gray(img.Image img, int x, int y) {
    final p = img.getPixel(x, y);
    return p.r * 0.299 + p.g * 0.587 + p.b * 0.114;
  }
}
