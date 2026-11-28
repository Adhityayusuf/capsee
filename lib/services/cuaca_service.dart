import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// CUACA SERVICE
// Proxy ke API cuaca luar (Open-Meteo) via backend Capsee.
// Sumber data: Open-Meteo (open-meteo.com) — lisensi CC BY 4.0.
// ─────────────────────────────────────────────────────────

/// Ambil prakiraan cuaca untuk satu lahan (maksimal 14 hari ke depan).
///
/// Mengembalikan Map berisi:
/// - 'lokasi': info wilayah (provinsi, kota, kecamatan, lat, lon)
/// - 'prakiraan': list ringkasan cuaca per hari (suhu, kelembapan, cuaca, dll)
/// - 'sumber': "Open-Meteo"
Future<Map<String, dynamic>> getCuacaLahan(String idLahan) async {
  // Cuaca manggil beberapa API luar berurutan di backend, jadi butuh timeout panjang.
  final res = await apiGet(
    '/api/cuaca/$idLahan',
    headers: await headerAuth(),
    timeout: cuacaTimeout,
  );
  return parseResponse(res);
}

/// Ambil prakiraan cuaca umum mengikuti identitas diri pengguna
/// (provinsi + kota + kecamatan di profil). Dipakai kartu cuaca dashboard.
///
/// Backend mengembalikan 400 kalau identitas belum lengkap.
Future<Map<String, dynamic>> getCuacaProfil() async {
  final res = await apiGet(
    '/api/cuaca/profil',
    headers: await headerAuth(),
    timeout: cuacaTimeout,
  );
  return parseResponse(res);
}
