import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// NOTIFIKASI SERVICE
// ─────────────────────────────────────────────────────────

/// Ambil semua notifikasi milik pengguna yang login,
/// diurutkan dari yang terbaru.
Future<List<Map<String, dynamic>>> getDaftarNotifikasi() async {
  final res = await apiGet(
    '/api/notifikasi',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return List<Map<String, dynamic>>.from(body['notifikasi']);
}

/// Tandai satu notifikasi sebagai sudah dibaca.
Future<Map<String, dynamic>> tandaiDibaca(String idNotifikasi) async {
  final res = await apiPatch(
    '/api/notifikasi/$idNotifikasi/baca',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['notifikasi'] as Map<String, dynamic>;
}

/// Hitung jumlah notifikasi yang belum dibaca (untuk badge lonceng).
Future<int> getJumlahNotifikasiBelumDibaca() async {
  final daftar = await getDaftarNotifikasi();
  return daftar.where((n) => n['sudah_dibaca'] != true).length;
}
