import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// PENGGUNA SERVICE
// ─────────────────────────────────────────────────────────

/// Ambil profil pengguna yang sedang login.
Future<Map<String, dynamic>> getProfil() async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/pengguna/me'),
    headers: await headerAuth(),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Edit nama dan/atau nomor HP. Field null = tidak berubah.
Future<Map<String, dynamic>> editProfil({
  String? nama,
  String? nomorHp,
}) async {
  final payload = <String, dynamic>{};
  if (nama != null) payload['nama'] = nama;
  if (nomorHp != null) payload['nomor_hp'] = nomorHp;

  final res = await http.put(
    Uri.parse('$baseUrl/api/pengguna/me'),
    headers: await headerAuth(),
    body: jsonEncode(payload),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Ganti kata sandi. Perlu sandi lama untuk verifikasi.
Future<void> gantiSandi({
  required String sandiLama,
  required String sandiBaru,
}) async {
  final res = await http.put(
    Uri.parse('$baseUrl/api/pengguna/me/ganti-sandi'),
    headers: await headerAuth(),
    body: jsonEncode({'sandi_lama': sandiLama, 'sandi_baru': sandiBaru}),
  );
  parseResponse(res);
}
