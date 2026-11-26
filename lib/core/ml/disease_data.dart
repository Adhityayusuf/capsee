import 'package:flutter/foundation.dart';
import '../../services/pemindaian_service.dart';

/// Model representasi data penyakit cabai
/// yang diambil langsung dari database PostgreSQL (tabel `penyakit`).
class DiseaseInfo {
  final String id;
  final String key;
  final String name;
  final String? latinName;
  final String description;
  final String treatment;

  const DiseaseInfo({
    this.id = '',
    required this.key,
    required this.name,
    this.latinName,
    required this.description,
    required this.treatment,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    // Penanganan diambil dari kolom 'penanganan' tabel penyakit,
    // atau dari relasi 'daftar_penanganan' jika ada.
    String penangananText = json['penanganan']?.toString() ?? '';
    if (penangananText.isEmpty && json['daftar_penanganan'] is List) {
      final list = json['daftar_penanganan'] as List;
      final lines = <String>[];
      for (final item in list) {
        if (item is Map) {
          final prod = item['nama_produk']?.toString() ?? '';
          final dosis = item['dosis']?.toString() ?? '';
          final cara = item['cara_pakai']?.toString() ?? '';
          var line = '- $prod';
          if (dosis.isNotEmpty) line += ' ($dosis)';
          if (cara.isNotEmpty) line += ': $cara';
          lines.add(line);
        }
      }
      penangananText = lines.join('\n');
    }

    return DiseaseInfo(
      id: json['id']?.toString() ?? '',
      key: json['kelas']?.toString() ?? json['nama']?.toString() ?? '',
      name: json['nama']?.toString() ?? '',
      latinName: json['nama_latin']?.toString(),
      description: json['deskripsi']?.toString() ?? '',
      treatment: penangananText,
    );
  }
}

/// In-memory cache agar data penyakit dari database yang telah di-fetch
/// tidak perlu dipanggil berulang kali melalui jaringan.
final Map<String, DiseaseInfo> _diseaseCache = {};

String _normalizeKey(String label) {
  return label.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
}

/// Mengambil data penyakit langsung dari database PostgreSQL backend via API.
///
/// Hasilnya disimpan di memory cache agar pemanggilan selanjutnya instan.
Future<DiseaseInfo?> fetchDiseaseInfo(String? label) async {
  if (label == null || label.trim().isEmpty) return null;
  final raw = label.trim();
  final normKey = _normalizeKey(raw);

  if (_diseaseCache.containsKey(normKey)) {
    return _diseaseCache[normKey];
  }
  if (_diseaseCache.containsKey(raw.toLowerCase())) {
    return _diseaseCache[raw.toLowerCase()];
  }

  try {
    final data = await getPenyakitInfo(raw);
    if (data != null) {
      final info = DiseaseInfo.fromJson(data);
      _diseaseCache[normKey] = info;
      _diseaseCache[raw.toLowerCase()] = info;
      if (info.name.isNotEmpty) {
        _diseaseCache[info.name.toLowerCase()] = info;
        _diseaseCache[_normalizeKey(info.name)] = info;
      }
      return info;
    }
  } catch (e) {
    debugPrint('Gagal mengambil data penyakit dari server: $e');
  }

  return null;
}

/// Mengambil data penyakit dari cache memori jika sudah di-cache sebelumnya.
DiseaseInfo? getChiliDiseaseInfo(String? label) {
  if (label == null || label.trim().isEmpty) return null;
  final normKey = _normalizeKey(label);
  return _diseaseCache[normKey] ?? _diseaseCache[label.trim().toLowerCase()];
}

/// Membersihkan cache data penyakit jika ingin reload data terbaru dari server.
void clearDiseaseCache() {
  _diseaseCache.clear();
}
