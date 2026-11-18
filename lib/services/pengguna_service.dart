import 'dart:convert';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// PENGGUNA SERVICE
// ─────────────────────────────────────────────────────────

/// Cek identitas lengkap: nama + no HP + provinsi/kota/kecamatan terisi.
bool isProfilLengkap(Map<String, dynamic>? profil) {
  if (profil == null) return false;
  for (final key in ['nama', 'nomor_hp', 'provinsi', 'kota', 'kecamatan']) {
    final v = (profil[key] ?? '').toString().trim();
    if (v.isEmpty) return false;
  }
  return true;
}

/// Ambil profil pengguna yang sedang login.
Future<Map<String, dynamic>> getProfil() async {
  final res = await apiGet(
    '/api/pengguna/me',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Ambil profil + flag lengkap dari backend (kalau backend lama tidak
/// kirim flag, hitung lokal via [isProfilLengkap]).
Future<({Map<String, dynamic> profil, bool lengkap})> getProfilLengkap() async {
  final res = await apiGet(
    '/api/pengguna/me',
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  final profil = body['pengguna'] as Map<String, dynamic>;
  final flag = body['profil_lengkap'] as bool?;
  return (profil: profil, lengkap: flag ?? isProfilLengkap(profil));
}

/// Edit nama dan/atau nomor HP. Field null = tidak berubah.
Future<Map<String, dynamic>> editProfil({
  String? nama,
  String? nomorHp,
  String? provinsi,
  String? kota,
  String? kecamatan,
}) async {
  final payload = <String, dynamic>{};
  if (nama != null) payload['nama'] = nama;
  if (nomorHp != null) payload['nomor_hp'] = nomorHp;
  if (provinsi != null) payload['provinsi'] = provinsi;
  if (kota != null) payload['kota'] = kota;
  if (kecamatan != null) payload['kecamatan'] = kecamatan;

  final res = await apiPut(
    '/api/pengguna/me',
    headers: await headerAuth(),
    body: jsonEncode(payload),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Simpan identitas diri wajib (nama + HP + lokasi domisili).
/// Semua field wajib terisi, dipakai layar Lengkapi Identitas.
Future<Map<String, dynamic>> lengkapiIdentitas({
  required String nama,
  required String nomorHp,
  required String provinsi,
  required String kota,
  required String kecamatan,
}) async {
  final res = await apiPut(
    '/api/pengguna/me',
    headers: await headerAuth(),
    body: jsonEncode({
      'nama': nama.trim(),
      'nomor_hp': nomorHp.trim(),
      'provinsi': provinsi.trim(),
      'kota': kota.trim(),
      'kecamatan': kecamatan.trim(),
    }),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Ganti kata sandi. Perlu sandi lama untuk verifikasi.
Future<void> gantiSandi({
  required String sandiLama,
  required String sandiBaru,
}) async {
  final res = await apiPut(
    '/api/pengguna/me/ganti-sandi',
    headers: await headerAuth(),
    body: jsonEncode({'sandi_lama': sandiLama, 'sandi_baru': sandiBaru}),
  );
  parseResponse(res);
}
