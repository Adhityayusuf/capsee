import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Satu-satunya tempat yang tahu alamat backend.
/// Ganti ke URL Railway/Render/VPS saat production.
/// Bisa di-override saat build/run tanpa ubah kode:
///   flutter run --dart-define=BASE_URL=http://192.168.1.10:8000
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://192.168.100.41:8000',
);

/// Timeout standar untuk semua request HTTP.
const Duration _requestTimeout = Duration(seconds: 20);

/// Timeout khusus endpoint berat (cuaca: 4x API luar berurutan).
const Duration cuacaTimeout = Duration(seconds: 60);

/// Timeout khusus upload gambar (kompres + Cloudinary bisa lama di HP).
const Duration uploadTimeout = Duration(seconds: 60);

Uri _uri(String path) => Uri.parse('$baseUrl$path');

/// Ubah error jaringan mentah jadi pesan yang dimengerti petani.
String pesanError(Object e) {
  if (e is ApiException) return e.pesan;
  if (e is TimeoutException) {
    return 'Server tidak merespons dalam ${e.duration?.inSeconds ?? 20} detik.\n'
        'Pastikan backend jalan di $baseUrl dan HP satu WiFi dengan laptop.';
  }
  if (e is SocketException) {
    return 'Tidak bisa terhubung ke $baseUrl.\n'
        'Cek backend sudah jalan + HP satu WiFi dengan laptop + firewall port 8000 terbuka.';
  }
  if (e is HttpException || e is HandshakeException) {
    return 'Koneksi ke server gagal ($e).\nCoba lagi atau ganti BASE_URL.';
  }
  if (e is FormatException) {
    return 'Respons server rusak. Coba lagi.';
  }
  return e.toString().replaceFirst('Exception: ', '');
}

Future<T> _denganPesanRamah<T>(Future<T> Function() jalan) async {
  try {
    return await jalan();
  } on TimeoutException catch (e) {
    throw ApiException(pesanError(e), 408);
  } on SocketException catch (e) {
    throw ApiException(pesanError(e), 0);
  } on HttpException catch (e) {
    throw ApiException(pesanError(e), 0);
  } on HandshakeException catch (e) {
    throw ApiException(pesanError(e), 0);
  }
}

// ─────────────────────────────────────────────────────────
// HTTP METHOD WRAPPERS
// ─────────────────────────────────────────────────────────

/// GET ke `$baseUrl$path`.
Future<http.Response> apiGet(
  String path, {
  Map<String, String>? headers,
  Duration timeout = _requestTimeout,
}) {
  return _denganPesanRamah(
    () => http.get(_uri(path), headers: headers).timeout(timeout),
  );
}

/// POST JSON ke `$baseUrl$path`.
Future<http.Response> apiPost(
  String path, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = _requestTimeout,
}) {
  return _denganPesanRamah(
    () => http.post(_uri(path), headers: headers, body: body).timeout(timeout),
  );
}

/// PUT JSON ke `$baseUrl$path`.
Future<http.Response> apiPut(
  String path, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = _requestTimeout,
}) {
  return _denganPesanRamah(
    () => http.put(_uri(path), headers: headers, body: body).timeout(timeout),
  );
}

/// PATCH JSON ke `$baseUrl$path`.
Future<http.Response> apiPatch(
  String path, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = _requestTimeout,
}) {
  return _denganPesanRamah(
    () =>
        http.patch(_uri(path), headers: headers, body: body).timeout(timeout),
  );
}

/// DELETE ke `$baseUrl$path`.
Future<http.Response> apiDelete(
  String path, {
  Map<String, String>? headers,
  Object? body,
  Duration timeout = _requestTimeout,
}) {
  return _denganPesanRamah(
    () =>
        http.delete(_uri(path), headers: headers, body: body).timeout(timeout),
  );
}

/// Kirim [http.MultipartRequest] (untuk upload gambar).
/// Mengembalikan [http.Response] agar bisa dipakai [parseResponse].
Future<http.Response> apiSend(
  http.MultipartRequest request, {
  Duration timeout = uploadTimeout,
}) async {
  return _denganPesanRamah(() async {
    final streamed = await request.send().timeout(timeout);
    return http.Response.fromStream(streamed).timeout(timeout);
  });
}
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
  Map<String, dynamic> body;
  try {
    body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  } catch (_) {
    // Backend mengembalikan non-JSON (mis. 502 gateway HTML, timeout proxy).
    final snippet = utf8.decode(res.bodyBytes, allowMalformed: true).trim();
    final preview = snippet.length > 200 ? '${snippet.substring(0, 200)}…' : snippet;
    throw ApiException(
      'Respons server tidak valid (${res.statusCode})${preview.isEmpty ? '' : ': $preview'}',
      res.statusCode,
    );
  }
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
