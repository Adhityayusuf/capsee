import 'dart:convert';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// MODEL RESPONSE
// ─────────────────────────────────────────────────────────

class HasilLogin {
  final String token;
  final Map<String, dynamic> pengguna;
  final bool sudahPunyaLahan;

  HasilLogin({
    required this.token,
    required this.pengguna,
    required this.sudahPunyaLahan,
  });

  factory HasilLogin.fromJson(Map<String, dynamic> json) => HasilLogin(
        token: json['token'] as String,
        pengguna: json['pengguna'] as Map<String, dynamic>,
        sudahPunyaLahan: json['sudah_punya_lahan'] as bool? ?? false,
      );
}

// ─────────────────────────────────────────────────────────
// AUTH SERVICE
// ─────────────────────────────────────────────────────────

/// Kirim permintaan registrasi akun baru.
Future<Map<String, dynamic>> register({
  required String nama,
  required String email,
  required String password,
  String? nomorHp,
}) async {
  final res = await apiPost(
    '/api/auth/register',
    headers: headerJson(),
    body: jsonEncode({
      'nama': nama,
      'email': email,
      'password': password,
      if (nomorHp != null) 'nomor_hp': nomorHp,
    }),
  );
  final body = parseResponse(res);
  return body['pengguna'] as Map<String, dynamic>;
}

/// Login dengan email + password.
/// Token JWT otomatis disimpan ke SharedPreferences.
Future<HasilLogin> login({
  required String email,
  required String password,
}) async {
  final res = await apiPost(
    '/api/auth/login',
    headers: headerJson(),
    body: jsonEncode({'email': email, 'password': password}),
  );
  final body = parseResponse(res);
  final hasil = HasilLogin.fromJson(body);
  await simpanToken(hasil.token);
  return hasil;
}

/// Logout — hapus token dari penyimpanan lokal.
Future<void> logout() => hapusToken();
