import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Satu-satunya tempat yang tahu alamat backend.
/// Ganti ke URL Railway/Render/VPS saat production.
const String baseUrl = 'http://localhost:8000';
/// Key untuk menyimpan token JWT di SharedPreferences.
const String _tokenKey = 'auth_token';

// ─────────────────────────────────────────────────────────
// TOKEN HELPERS
// ─────────────────────────────────────────────────────────

/// Simpan token JWT setelah login berhasil.
Future<void> simpanToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
}

/// Ambil token JWT yang tersimpan. Null jika belum login.
Future<String?> ambilToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_tokenKey);
}

/// Hapus token saat logout.
Future<void> hapusToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_tokenKey);
}

/// Cek apakah pengguna sudah login.
Future<bool> sudahLogin() async {
  final token = await ambilToken();
  return token != null && token.isNotEmpty;
}

// ─────────────────────────────────────────────────────────
// HTTP HEADER HELPERS
// ─────────────────────────────────────────────────────────

/// Header JSON biasa (tanpa token, untuk register/login).
Map<String, String> headerJson() => {'Content-Type': 'application/json'};

/// Header JSON + Bearer token (untuk endpoint yang butuh auth).
Future<Map<String, String>> headerAuth() async {
  final token = await ambilToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

/// Header multipart + Bearer token (untuk upload file/gambar).
Future<Map<String, String>> headerAuthMultipart() async {
  final token = await ambilToken();
  return {
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

// ─────────────────────────────────────────────────────────
// RESPONSE PARSER
// ─────────────────────────────────────────────────────────

/// Parse response: jika sukses kembalikan body sebagai Map,
/// jika gagal lempar [ApiException] dengan pesan dari backend.
Map<String, dynamic> parseResponse(http.Response res) {
  final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  if (res.statusCode >= 200 && res.statusCode < 300) return body;
  final pesan = body['detail'] ?? 'Terjadi kesalahan (${res.statusCode})';
  throw ApiException(pesan.toString(), res.statusCode);
}

// ─────────────────────────────────────────────────────────
// EXCEPTION
// ─────────────────────────────────────────────────────────

/// Exception standar untuk semua error dari API Capsee.
class ApiException implements Exception {
  final String pesan;
  final int statusCode;
  ApiException(this.pesan, this.statusCode);

  @override
  String toString() => pesan;
}
