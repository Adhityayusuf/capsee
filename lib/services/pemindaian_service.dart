import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// PEMINDAIAN SERVICE
// ─────────────────────────────────────────────────────────

/// Upload gambar scan ke backend (multipart/form-data).
/// Backend akan kompres, upload ke Cloudinary, panggil model ML,
/// lalu simpan semua hasil ke database.
///
/// [file] — file gambar dari kamera/galeri (gunakan image_picker)
/// [idLahan] — UUID lahan yang sedang di-scan
/// [bagianTanaman] — 'daun' atau 'buah'
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
}) async {
  final headers = await headerAuthMultipart();
  final uri = Uri.parse('$baseUrl/api/pemindaian');

  final request = http.MultipartRequest('POST', uri)
    ..headers.addAll(headers)
    ..fields['id_lahan'] = idLahan
    ..fields['bagian_tanaman'] = bagianTanaman;

  // Membaca bytes secara langsung memungkinkan upload dari Flutter Web (browser)
  // karena MultipartFile.fromPath tidak didukung di web (memerlukan dart:io).
  final bytes = await file.readAsBytes();
  request.files.add(http.MultipartFile.fromBytes(
    'gambar',
    bytes,
    filename: file.name,
  ));

  final streamed = await request.send();
  final res = await http.Response.fromStream(streamed);
  return parseResponse(res);
}

/// Ambil semua riwayat scan untuk satu lahan.
Future<List<Map<String, dynamic>>> getRiwayatScan(String idLahan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/pemindaian/lahan/$idLahan'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['pemindaian']);
}

/// Ambil detail satu hasil scan beserta penyakit, penanganan,
/// langkah tindakan, dan pencegahan.
Future<Map<String, dynamic>> getDetailScan(String idScan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/pemindaian/$idScan'),
    headers: await headerAuth(),
  );
  return parseResponse(res);
}
