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
<<<<<<< HEAD
  required String namaKelas,     // hasil inferensi TFLite
  required double skorKeyakinan, // confidence persen (0–100)
=======
  String? statusHasil,
  String? labelHasil,
  double? skorKeyakinan,
>>>>>>> 08bcb321c7e9f8902757913b74af70a7a016865c
}) async {
  final headers = await headerAuthMultipart();
  final uri = Uri.parse('$baseUrl/api/pemindaian');

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['id_lahan'] = idLahan
    ..fields['bagian_tanaman'] = bagianTanaman
    ..fields['nama_kelas'] = namaKelas
    ..fields['skor_keyakinan'] = skorKeyakinan.toStringAsFixed(2);

  if (statusHasil != null) request.fields['status_hasil'] = statusHasil;
  if (labelHasil != null) request.fields['label_hasil'] = labelHasil;
  if (skorKeyakinan != null) {
    request.fields['skor_keyakinan'] = skorKeyakinan.toString();
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
