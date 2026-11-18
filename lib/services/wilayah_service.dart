import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// WILAYAH INDONESIA
// Sumber utama: emsifa API wilayah Indonesia (38 provinsi lengkap,
// sama dengan yang dipakai backend untuk lookup cuaca BMKG, jadi nama
// yang dipilih dijamin cocok saat cek cuaca).
// Bila perangkat offline / API tidak terjangkau, daftar di bawah dipakai
// sebagai cadangan agar form tambah lahan tetap bisa diisi.
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

// ─────────────────────────────────────────────────────────
// CADANGAN OFFLINE
// ─────────────────────────────────────────────────────────

const List<Wilayah> _provinsiOffline = [
  Wilayah(id: '32', name: 'Jawa Barat'),
  Wilayah(id: '33', name: 'Jawa Tengah'),
  Wilayah(id: '34', name: 'DI Yogyakarta'),
  Wilayah(id: '35', name: 'Jawa Timur'),
  Wilayah(id: '36', name: 'Banten'),
  Wilayah(id: '31', name: 'DKI Jakarta'),
  Wilayah(id: '51', name: 'Bali'),
  Wilayah(id: '12', name: 'Sumatera Utara'),
  Wilayah(id: '16', name: 'Sumatera Selatan'),
  Wilayah(id: '73', name: 'Sulawesi Selatan'),
];

const Map<String, List<Wilayah>> _kotaOffline = {
  '32': [
    Wilayah(id: '32.17', name: 'Bandung Barat'),
    Wilayah(id: '32.04', name: 'Bandung'),
    Wilayah(id: '32.73', name: 'Kota Bandung'),
    Wilayah(id: '32.16', name: 'Bekasi'),
  ],
  '33': [
    Wilayah(id: '33.08', name: 'Magelang'),
    Wilayah(id: '33.74', name: 'Kota Magelang'),
    Wilayah(id: '33.22', name: 'Semarang'),
    Wilayah(id: '33.72', name: 'Kota Surakarta'),
  ],
  '34': [
    Wilayah(id: '34.71', name: 'Kota Yogyakarta'),
    Wilayah(id: '34.04', name: 'Sleman'),
    Wilayah(id: '34.02', name: 'Bantul'),
  ],
  '35': [
    Wilayah(id: '35.78', name: 'Kota Surabaya'),
    Wilayah(id: '35.07', name: 'Malang'),
    Wilayah(id: '35.73', name: 'Kota Malang'),
  ],
  '36': [
    Wilayah(id: '36.03', name: 'Tangerang'),
    Wilayah(id: '36.71', name: 'Kota Tangerang'),
    Wilayah(id: '36.04', name: 'Serang'),
  ],
  '31': [
    Wilayah(id: '31.71', name: 'Jakarta Pusat'),
    Wilayah(id: '31.72', name: 'Jakarta Timur'),
    Wilayah(id: '31.73', name: 'Jakarta Selatan'),
  ],
  '51': [
    Wilayah(id: '51.03', name: 'Badung'),
    Wilayah(id: '51.71', name: 'Kota Denpasar'),
    Wilayah(id: '51.04', name: 'Gianyar'),
  ],
  '12': [
    Wilayah(id: '12.71', name: 'Kota Medan'),
    Wilayah(id: '12.05', name: 'Langkat'),
    Wilayah(id: '12.07', name: 'Deli Serdang'),
  ],
  '16': [
    Wilayah(id: '16.71', name: 'Kota Palembang'),
    Wilayah(id: '16.05', name: 'Muara Enim'),
    Wilayah(id: '16.10', name: 'Ogan Ilir'),
  ],
  '73': [
    Wilayah(id: '73.71', name: 'Kota Makassar'),
    Wilayah(id: '73.06', name: 'Gowa'),
    Wilayah(id: '73.05', name: 'Takalar'),
  ],
};

const Map<String, List<Wilayah>> _kecamatanOffline = {
  '32.17': [
    Wilayah(id: '32.17.01', name: 'Lembang'),
    Wilayah(id: '32.17.02', name: 'Parongpong'),
    Wilayah(id: '32.17.03', name: 'Cisarua'),
    Wilayah(id: '32.17.04', name: 'Ngamprah'),
  ],
  '32.04': [
    Wilayah(id: '32.04.01', name: 'Ciwidey'),
    Wilayah(id: '32.04.02', name: 'Pangalengan'),
    Wilayah(id: '32.04.03', name: 'Soreang'),
  ],
  '32.73': [
    Wilayah(id: '32.73.01', name: 'Coblong'),
    Wilayah(id: '32.73.02', name: 'Sukajadi'),
    Wilayah(id: '32.73.03', name: 'Bandung Wetan'),
  ],
  '32.16': [
    Wilayah(id: '32.16.01', name: 'Cikarang'),
    Wilayah(id: '32.16.02', name: 'Tambun'),
    Wilayah(id: '32.16.03', name: 'Cibitung'),
  ],
  '33.08': [
    Wilayah(id: '33.08.01', name: 'Muntilan'),
    Wilayah(id: '33.08.02', name: 'Mertoyudan'),
    Wilayah(id: '33.08.03', name: 'Sawangan'),
  ],
  '33.74': [
    Wilayah(id: '33.74.01', name: 'Magelang Tengah'),
    Wilayah(id: '33.74.02', name: 'Magelang Utara'),
  ],
  '33.22': [
    Wilayah(id: '33.22.01', name: 'Ungaran'),
    Wilayah(id: '33.22.02', name: 'Bawen'),
  ],
  '33.72': [
    Wilayah(id: '33.72.01', name: 'Laweyan'),
    Wilayah(id: '33.72.02', name: 'Serengan'),
  ],
  '34.71': [
    Wilayah(id: '34.71.01', name: 'Danurejan'),
    Wilayah(id: '34.71.02', name: 'Gondokusuman'),
  ],
  '34.04': [
    Wilayah(id: '34.04.01', name: 'Depok'),
    Wilayah(id: '34.04.02', name: 'Kalasan'),
  ],
  '34.02': [
    Wilayah(id: '34.02.01', name: 'Sewon'),
    Wilayah(id: '34.02.02', name: 'Kasihan'),
  ],
  '35.78': [
    Wilayah(id: '35.78.01', name: 'Gubeng'),
    Wilayah(id: '35.78.02', name: 'Rungkut'),
  ],
  '35.07': [
    Wilayah(id: '35.07.01', name: 'Kepanjen'),
    Wilayah(id: '35.07.02', name: 'Singosari'),
  ],
  '35.73': [
    Wilayah(id: '35.73.01', name: 'Klojen'),
    Wilayah(id: '35.73.02', name: 'Lowokwaru'),
  ],
  '36.03': [
    Wilayah(id: '36.03.01', name: 'Cikupa'),
    Wilayah(id: '36.03.02', name: 'Balaraja'),
  ],
  '36.71': [
    Wilayah(id: '36.71.01', name: 'Ciledug'),
    Wilayah(id: '36.71.02', name: 'Tangerang'),
  ],
  '36.04': [
    Wilayah(id: '36.04.01', name: 'Serang'),
    Wilayah(id: '36.04.02', name: 'Ciruas'),
  ],
  '31.71': [
    Wilayah(id: '31.71.01', name: 'Gambir'),
    Wilayah(id: '31.71.02', name: 'Menteng'),
  ],
  '31.72': [
    Wilayah(id: '31.72.01', name: 'Matraman'),
    Wilayah(id: '31.72.02', name: 'Pulo Gadung'),
  ],
  '31.73': [
    Wilayah(id: '31.73.01', name: 'Kebayoran Baru'),
    Wilayah(id: '31.73.02', name: 'Tebet'),
  ],
  '51.03': [
    Wilayah(id: '51.03.01', name: 'Kuta'),
    Wilayah(id: '51.03.02', name: 'Mengwi'),
  ],
  '51.71': [
    Wilayah(id: '51.71.01', name: 'Denpasar Barat'),
    Wilayah(id: '51.71.02', name: 'Denpasar Timur'),
  ],
  '51.04': [
    Wilayah(id: '51.04.01', name: 'Ubud'),
    Wilayah(id: '51.04.02', name: 'Gianyar'),
  ],
  '12.71': [
    Wilayah(id: '12.71.01', name: 'Medan Baru'),
    Wilayah(id: '12.71.02', name: 'Medan Kota'),
  ],
  '12.05': [
    Wilayah(id: '12.05.01', name: 'Stabat'),
    Wilayah(id: '12.05.02', name: 'Binjai'),
  ],
  '12.07': [
    Wilayah(id: '12.07.01', name: 'Lubuk Pakam'),
    Wilayah(id: '12.07.02', name: 'Tanjung Morawa'),
  ],
  '16.71': [
    Wilayah(id: '16.71.01', name: 'Ilir Barat'),
    Wilayah(id: '16.71.02', name: 'Bukit Kecil'),
  ],
  '16.05': [
    Wilayah(id: '16.05.01', name: 'Muara Enim'),
    Wilayah(id: '16.05.02', name: 'Tanjung Agung'),
  ],
  '16.10': [
    Wilayah(id: '16.10.01', name: 'Indralaya'),
    Wilayah(id: '16.10.02', name: 'Pemulutan'),
  ],
  '73.71': [
    Wilayah(id: '73.71.01', name: 'Rappocini'),
    Wilayah(id: '73.71.02', name: 'Panakkukang'),
  ],
  '73.06': [
    Wilayah(id: '73.06.01', name: 'Sungguminasa'),
    Wilayah(id: '73.06.02', name: 'Pallangga'),
  ],
  '73.05': [
    Wilayah(id: '73.05.01', name: 'Takalar'),
    Wilayah(id: '73.05.02', name: 'Pattallassang'),
  ],
};


List<Wilayah> _sorted(List<Wilayah> list) {
  final out = [...list]..sort((a, b) => a.name.compareTo(b.name));
  return out;
}

// ─────────────────────────────────────────────────────────
// FETCH ONLINE + CACHE
// ─────────────────────────────────────────────────────────

List<Wilayah>? _provCache;
final Map<String, List<Wilayah>> _kotaCache = {};
final Map<String, List<Wilayah>> _kecCache = {};

Future<List<Wilayah>> _fetchList(String url) async {
  try {
    final res = await http.get(Uri.parse(url)).timeout(_wilayahTimeout);
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
    return _sorted(out);
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

// ─────────────────────────────────────────────────────────
// API PUBLIK
// ─────────────────────────────────────────────────────────

/// Semua provinsi. Online dulu, lalu cadangan offline.
Future<List<Wilayah>> getProvinsi() async {
  final cache = _provCache;
  if (cache != null) return cache;
  try {
    return _provCache = await _fetchList(_provUrl);
  } catch (_) {
    return _provCache = _sorted(_provinsiOffline);
  }
}

/// Kota/kabupaten dalam satu provinsi. Online dulu, lalu cadangan offline.
Future<List<Wilayah>> getKota(String provId) async {
  final cache = _kotaCache[provId];
  if (cache != null) return cache;
  try {
    return _kotaCache[provId] = await _fetchList(_kotaUrl(provId));
  } catch (e) {
    final lokal = _kotaOffline[provId];
    if (lokal == null) rethrow;
    return _kotaCache[provId] = _sorted(lokal);
  }
}

/// Kecamatan dalam satu kota/kabupaten. Online dulu, lalu cadangan offline.
Future<List<Wilayah>> getKecamatan(String kotaId) async {
  final cache = _kecCache[kotaId];
  if (cache != null) return cache;
  try {
    return _kecCache[kotaId] = await _fetchList(_kecUrl(kotaId));
  } catch (e) {
    final lokal = _kecamatanOffline[kotaId];
    if (lokal == null) rethrow;
    return _kecCache[kotaId] = _sorted(lokal);
  }
}
