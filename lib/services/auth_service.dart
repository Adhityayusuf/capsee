import 'dart:convert';
import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// MODEL RESPONSE
// ─────────────────────────────────────────────────────────

class HasilLogin {
  final String token;
  final Map<String, dynamic> pengguna;
  final bool sudahPunyaLahan;
  final bool profilLengkap;

  HasilLogin({
    required this.token,
    required this.pengguna,
    required this.sudahPunyaLahan,
    required this.profilLengkap,
  });

  factory HasilLogin.fromJson(Map<String, dynamic> json) {
    final pengguna = Map<String, dynamic>.from(
      (json['pengguna'] as Map?) ?? {},
    );
    final flag = json['profil_lengkap'] as bool?;
    // Fallback untuk backend lama: hitung dari field profil.
    bool lengkap = flag ?? true;
    if (flag == null) {
      lengkap = true;
      for (final key in ['nama', 'nomor_hp', 'provinsi', 'kota', 'kecamatan']) {
        if ((pengguna[key] ?? '').toString().trim().isEmpty) {
          lengkap = false;
          break;
        }
      }
    }
    return HasilLogin(
      token: json['token'] as String,
      pengguna: pengguna,
      sudahPunyaLahan: json['sudah_punya_lahan'] as bool? ?? false,
      profilLengkap: lengkap,
    );
  }
}

// ─────────────────────────────────────────────────────────
// AUTH SERVICE
// ─────────────────────────────────────────────────────────

/// Kirim permintaan registrasi akun baru.
/// Backend langsung mengembalikan token, jadi pendaftar otomatis masuk
/// tanpa perlu login ulang. Token JWT otomatis disimpan.
Future<HasilLogin> register({
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
  final hasil = HasilLogin.fromJson(body);
  await simpanToken(hasil.token);
  return hasil;
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
