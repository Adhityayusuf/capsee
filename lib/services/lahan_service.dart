import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// LAHAN SERVICE
// ─────────────────────────────────────────────────────────

/// Tambah lahan baru. Backend otomatis generate jadwal siram & pupuk.
Future<Map<String, dynamic>> tambahLahan({
  required String nama,
  required String provinsi,
  required String kota,
  required String kecamatan,
  required int umurTanamanBulan,
  String? tanggalTerakhirSiram,  // format: 'YYYY-MM-DD'
  String? tanggalTerakhirPupuk,  // format: 'YYYY-MM-DD'
  required int intervalPupukMinggu,
}) async {
  final payload = {
    'nama': nama,
    'provinsi': provinsi,
    'kota': kota,
    'kecamatan': kecamatan,
    'umur_tanaman_bulan': umurTanamanBulan,
    'interval_pupuk_minggu': intervalPupukMinggu,
    if (tanggalTerakhirSiram != null) 'tanggal_terakhir_siram': tanggalTerakhirSiram,
    if (tanggalTerakhirPupuk != null) 'tanggal_terakhir_pupuk': tanggalTerakhirPupuk,
  };

  final res = await http.post(
    Uri.parse('$baseUrl/api/lahan'),
    headers: await headerAuth(),
    body: jsonEncode(payload),
  );
  final body = parseResponse(res);
  return body['lahan'] as Map<String, dynamic>;
}

/// Ambil semua lahan milik pengguna yang login.
Future<List<Map<String, dynamic>>> getDaftarLahan() async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/lahan'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['lahan']);
}

/// Ambil detail satu lahan.
Future<Map<String, dynamic>> getDetailLahan(String idLahan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/lahan/$idLahan'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['lahan'] as Map<String, dynamic>;
}

/// Edit sebagian data lahan. Field null tidak akan dikirim.
Future<Map<String, dynamic>> editLahan(
  String idLahan, {
  String? nama,
  String? provinsi,
  String? kota,
  String? kecamatan,
  int? umurTanamanBulan,
  String? tanggalTerakhirSiram,
  String? tanggalTerakhirPupuk,
  int? intervalPupukMinggu,
}) async {
  final payload = <String, dynamic>{};
  if (nama != null) payload['nama'] = nama;
  if (provinsi != null) payload['provinsi'] = provinsi;
  if (kota != null) payload['kota'] = kota;
  if (kecamatan != null) payload['kecamatan'] = kecamatan;
  if (umurTanamanBulan != null) payload['umur_tanaman_bulan'] = umurTanamanBulan;
  if (tanggalTerakhirSiram != null) payload['tanggal_terakhir_siram'] = tanggalTerakhirSiram;
  if (tanggalTerakhirPupuk != null) payload['tanggal_terakhir_pupuk'] = tanggalTerakhirPupuk;
  if (intervalPupukMinggu != null) payload['interval_pupuk_minggu'] = intervalPupukMinggu;

  final res = await http.put(
    Uri.parse('$baseUrl/api/lahan/$idLahan'),
    headers: await headerAuth(),
    body: jsonEncode(payload),
  );
  final body = parseResponse(res);
  return body['lahan'] as Map<String, dynamic>;
}

/// Hapus lahan (CASCADE — semua data turunan ikut terhapus).
Future<void> hapusLahan(String idLahan) async {
  final res = await http.delete(
    Uri.parse('$baseUrl/api/lahan/$idLahan'),
    headers: await headerAuth(),
  );
  parseResponse(res);
}

// ─────────────────────────────────────────────────────────
// JADWAL PENYIRAMAN
// ─────────────────────────────────────────────────────────

/// Ambil semua jadwal penyiraman untuk satu lahan.
Future<List<Map<String, dynamic>>> getJadwalPenyiraman(String idLahan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/lahan/$idLahan/jadwal-penyiraman'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['jadwal_penyiraman']);
}

/// Tandai jadwal penyiraman sebagai selesai.
/// Otomatis update tanggal_terakhir_siram di lahan + catat ke log.
Future<Map<String, dynamic>> selesaiPenyiraman(
  String idLahan,
  String idJadwal,
) async {
  final res = await http.patch(
    Uri.parse('$baseUrl/api/lahan/$idLahan/jadwal-penyiraman/$idJadwal/selesai'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['jadwal_penyiraman'] as Map<String, dynamic>;
}

// ─────────────────────────────────────────────────────────
// JADWAL PEMUPUKAN
// ─────────────────────────────────────────────────────────

/// Ambil semua jadwal pemupukan untuk satu lahan.
Future<List<Map<String, dynamic>>> getJadwalPemupukan(String idLahan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/lahan/$idLahan/jadwal-pemupukan'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['jadwal_pemupukan']);
}

/// Tandai jadwal pemupukan sebagai selesai.
/// Otomatis update tanggal_terakhir_pupuk di lahan + generate jadwal berikutnya + catat ke log.
Future<Map<String, dynamic>> selesaiPemupukan(
  String idLahan,
  String idJadwal,
) async {
  final res = await http.patch(
    Uri.parse('$baseUrl/api/lahan/$idLahan/jadwal-pemupukan/$idJadwal/selesai'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['jadwal_pemupukan'] as Map<String, dynamic>;
}

// ─────────────────────────────────────────────────────────
// RIWAYAT AKTIVITAS
// ─────────────────────────────────────────────────────────

/// Ambil log aktivitas lahan (scan, siram, pupuk, peringatan).
Future<List<Map<String, dynamic>>> getRiwayat(String idLahan) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/lahan/$idLahan/riwayat'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['riwayat']);
}
