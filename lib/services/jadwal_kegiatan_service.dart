import 'dart:convert';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// JADWAL KEGIATAN MANUAL (nama + tanggal + deskripsi)
// Backend: backend/app/routers/jadwal_kegiatan.py
// ─────────────────────────────────────────────────────────

/// Ambil semua jadwal kegiatan manual untuk satu lahan.
Future<List<Map<String, dynamic>>> getJadwalKegiatan(String idLahan) async {
  final res = await apiGet(
    '/api/lahan/$idLahan/jadwal-kegiatan',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['jadwal_kegiatan']);
}

/// Tambah jadwal kegiatan manual.
/// [tanggalJadwal] format 'YYYY-MM-DD'.
Future<Map<String, dynamic>> tambahJadwalKegiatan({
  required String idLahan,
  required String namaKegiatan,
  required String tanggalJadwal,
  String? deskripsi,
}) async {
  final res = await apiPost(
    '/api/lahan/$idLahan/jadwal-kegiatan',
    headers: await headerAuth(),
    body: jsonEncode({
      'nama_kegiatan': namaKegiatan,
      'tanggal_jadwal': tanggalJadwal,
      if (deskripsi != null && deskripsi.trim().isNotEmpty)
        'deskripsi': deskripsi.trim(),
    }),
  );
  final body = parseResponse(res);
  return body['jadwal_kegiatan'] as Map<String, dynamic>;
}

/// Tandai jadwal kegiatan sebagai selesai (dicatat ke log sebagai peringatan).
Future<Map<String, dynamic>> selesaiJadwalKegiatan(
  String idLahan,
  String idJadwal,
) async {
  final res = await apiPatch(
    '/api/lahan/$idLahan/jadwal-kegiatan/$idJadwal/selesai',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['jadwal_kegiatan'] as Map<String, dynamic>;
}

/// Hapus jadwal kegiatan manual.
Future<void> hapusJadwalKegiatan(String idLahan, String idJadwal) async {
  final res = await apiDelete(
    '/api/lahan/$idLahan/jadwal-kegiatan/$idJadwal',
    headers: await headerAuth(),
  );
  parseResponse(res);
}
