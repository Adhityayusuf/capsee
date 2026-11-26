import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// PEMINDAIAN SERVICE
// ─────────────────────────────────────────────────────────

/// Upload gambar scan + hasil inferensi TFLite ke backend.
///
/// Backend akan:
/// 1. Validasi kepemilikan lahan.
/// 2. Kompres gambar dan upload ke Cloudinary.
/// 3. Simpan hasil ke database (menggunakan [namaKelas] dan [skorKeyakinan]
///    dari model on-device, bukan placeholder random).
/// 4. Update status_kesehatan lahan.
/// 5. Kembalikan data penyakit + penanganan (jika tidak sehat).
///
/// [file]            — file gambar dari kamera/galeri
/// [idLahan]         — UUID lahan yang sedang di-scan
/// [bagianTanaman]   — 'daun' atau 'buah'
/// [namaKelas]       — nama kelas hasil inferensi TFLite (mis. "Healthy Leaf", "Cercospora")
/// [skorKeyakinan]   — confidence dalam persen (0–100)
///
/// Mengembalikan Map berisi:
/// - 'pemindaian': hasil scan utama
/// - 'penyakit': data penyakit (null jika sehat)
/// - 'penanganan': list rekomendasi obat/penanganan
/// - 'langkah_tindakan': list langkah darurat
/// - 'pencegahan': list tips pencegahan
Future<Map<String, dynamic>> uploadScan({
  required XFile file,
  required String idLahan,
  required String bagianTanaman, // 'daun' atau 'buah'
  String? namaKelas,     // hasil inferensi TFLite
  String? statusHasil,
  String? labelHasil,
  double? skorKeyakinan, // confidence persen (0–100)
}) async {
  final headers = await headerAuthMultipart();
  final uri = Uri.parse('$baseUrl/api/pemindaian');

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['id_lahan'] = idLahan
    ..fields['bagian_tanaman'] = bagianTanaman;

  final finalNama = namaKelas ?? labelHasil;
  if (finalNama != null && finalNama.isNotEmpty) {
    request.fields['nama_kelas'] = finalNama;
    request.fields['label_hasil'] = finalNama;
  }
  if (statusHasil != null && statusHasil.isNotEmpty) {
    request.fields['status_hasil'] = statusHasil;
  }
  if (skorKeyakinan != null) {
    request.fields['skor_keyakinan'] = skorKeyakinan.toStringAsFixed(2);
  }

  // Membaca bytes secara langsung memungkinkan upload dari Flutter Web (browser)
  // karena MultipartFile.fromPath tidak didukung di web (memerlukan dart:io).
  final bytes = await file.readAsBytes();
  request.files.add(
    http.MultipartFile.fromBytes('gambar', bytes, filename: file.name),
  );

  final res = await apiSend(request);
  return parseResponse(res);
}

/// Ambil semua riwayat scan untuk satu lahan.
Future<List<Map<String, dynamic>>> getRiwayatScan(String idLahan) async {
  final res = await apiGet(
    '/api/pemindaian/lahan/$idLahan',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['pemindaian']);
}

/// Ambil detail satu hasil scan beserta penyakit, penanganan,
/// langkah tindakan, dan pencegahan.
Future<Map<String, dynamic>> getDetailScan(String idScan) async {
  final res = await apiGet(
    '/api/pemindaian/$idScan',
    headers: await headerAuth(),
  );
  return parseResponse(res);
}

/// Ambil data penyakit (deskripsi dan penanganan) langsung dari tabel penyakit database.
Future<Map<String, dynamic>?> getPenyakitInfo(String namaKelas) async {
  try {
    final encoded = Uri.encodeComponent(namaKelas.trim());
    final res = await apiGet('/api/pemindaian/penyakit/$encoded');
    return parseResponse(res);
  } catch (_) {
    return null;
  }
}

/// Ambil semua daftar penyakit langsung dari tabel penyakit database.
Future<List<Map<String, dynamic>>> getAllPenyakit() async {
  try {
    final res = await apiGet('/api/pemindaian/penyakit');
    final data = parseResponse(res);
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  } catch (_) {
    return [];
  }
}
