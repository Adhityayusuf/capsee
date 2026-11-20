import 'dart:typed_data';

/// Stub validasi objek cabai.
///
/// ## Status saat ini
/// Belum ada model TFLite terpisah yang khusus membedakan objek cabai
/// dari bukan cabai. Validasi objek yang sesungguhnya membutuhkan
/// salah satu dari:
///   - Model klasifikasi biner cabai/bukan-cabai (ringan, MobileNetV2 atau EfficientNet-lite).
///   - Model deteksi yang sudah mencakup kelas "cabai" sebagai objek target.
///   - Threshold-based heuristic dari output model utama (misalnya, tolak gambar
///     jika confidence tertinggi model daun < 0.3 untuk semua kelas).
///
/// ## Perilaku saat ini (Fallback)
/// Validasi selalu mengembalikan `ChiliValidationResult.passed()` agar alur
/// scan dapat berjalan dengan model utama (daun/buah).
/// Jika model validasi tersedia di masa mendatang, ganti implementasi
/// [validate] di sini tanpa mengubah antarmuka pemanggil.
///
/// ## Cara mengintegrasikan model validasi di masa mendatang
/// 1. Tambahkan file `chili_validator.tflite` ke `assets/models/`.
/// 2. Tambahkan path ke [ModelConfig].
/// 3. Implementasikan logika inference di `validate()` berikut.
/// 4. Update [ModelConfig] dan [ModelLoader] untuk mengelola lifecycle-nya.
class ChiliObjectValidator {
  const ChiliObjectValidator();

  /// Validasi apakah [imageBytes] mengandung objek yang sesuai ([scanType]).
  ///
  /// [scanType]: `'daun'` atau `'buah'`.
  ///
  /// Saat ini selalu lolos (stub). Model validasi belum tersedia.
  Future<ChiliValidationResult> validate(
    Uint8List imageBytes,
    String scanType,
  ) async {
    // TODO: Implementasikan dengan model TFLite khusus validasi objek cabai.
    // Untuk saat ini, semua gambar dianggap lolos validasi objek.
    // Validasi kualitas teknis gambar sudah dilakukan oleh [ImageQualityValidator].
    return ChiliValidationResult.passed();
  }
}

/// Hasil validasi objek cabai.
class ChiliValidationResult {
  /// True jika gambar valid mengandung objek cabai yang sesuai.
  final bool isValid;

  /// Alasan penolakan (null jika valid).
  final String? reason;

  /// True jika validasi dilewati karena model belum tersedia (stub).
  final bool isStubResult;

  const ChiliValidationResult._({
    required this.isValid,
    this.reason,
    this.isStubResult = false,
  });

  /// Gambar lolos validasi objek.
  factory ChiliValidationResult.passed() => const ChiliValidationResult._(
        isValid: true,
        isStubResult: true, // Tandai sebagai stub hingga model nyata tersedia
      );

  /// Gambar tidak mengandung objek cabai.
  factory ChiliValidationResult.rejected(String reason) =>
      ChiliValidationResult._(
        isValid: false,
        reason: reason,
        isStubResult: false,
      );
}
