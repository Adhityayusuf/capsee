import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// WILAYAH INDONESIA (lengkap: 38 provinsi → kota → kecamatan)
// Sumber: emsifa API wilayah Indonesia (sama dengan yang dipakai
// backend untuk lookup cuaca BMKG, jadi nama yang dipilih di sini
// dijamin cocok saat cek cuaca).
// ─────────────────────────────────────────────────────────

const String _provUrl =
    'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json';
String _kotaUrl(String provId) =>
    'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provId.json';
String _kecUrl(String kotaId) =>
    'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$kotaId.json';

const Duration _wilayahTimeout = Duration(seconds: 20);

class Wilayah {
  final String id;
  final String name;

  const Wilayah({required this.id, required this.name});

  factory Wilayah.fromJson(Map<String, dynamic> json) => Wilayah(
        id: json['id'].toString(),
        name: (json['name'] ?? '').toString(),
      );
}

List<Wilayah>? _provCache;
final Map<String, List<Wilayah>> _kotaCache = {};
final Map<String, List<Wilayah>> _kecCache = {};

Future<List<Wilayah>> _fetchList(String url) async {
  try {
    final res =
        await http.get(Uri.parse(url)).timeout(_wilayahTimeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Gagal memuat data wilayah (${res.statusCode}). Coba lagi.',
        res.statusCode,
      );
    }
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    final out = list
        .map((e) => Wilayah.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((w) => w.name.isNotEmpty)
        .toList();
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  } on TimeoutException {
    throw ApiException(
      'Memuat daftar wilayah timeout. Cek internet lalu coba lagi.',
      408,
    );
  } on SocketException {
    throw ApiException(
      'Tidak ada internet. Nyalakan data/WiFi atau isi manual.',
      0,
    );
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException('Gagal memuat data wilayah: $e', 0);
  }
}

/// Semua provinsi (di-cache setelah load pertama).
Future<List<Wilayah>> getProvinsi() async {
  return _provCache ??= await _fetchList(_provUrl);
}

/// Kota/kabupaten dalam satu provinsi.
Future<List<Wilayah>> getKota(String provId) async {
  if (_kotaCache.containsKey(provId)) return _kotaCache[provId]!;
  final list = await _fetchList(_kotaUrl(provId));
  _kotaCache[provId] = list;
  return list;
}

/// Kecamatan dalam satu kota/kabupaten.
Future<List<Wilayah>> getKecamatan(String kotaId) async {
  if (_kecCache.containsKey(kotaId)) return _kecCache[kotaId]!;
  final list = await _fetchList(_kecUrl(kotaId));
  _kecCache[kotaId] = list;
  return list;
}
