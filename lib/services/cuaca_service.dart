import 'api_client.dart';

// ─────────────────────────────────────────────────────────
// CUACA SERVICE
// Proxy ke API publik BMKG melalui backend Capsee.
// Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika)
// ─────────────────────────────────────────────────────────

/// Ambil prakiraan cuaca BMKG untuk satu lahan (3 hari ke depan).
///
/// Mengembalikan Map berisi:
/// - 'lokasi': info wilayah (provinsi, kota, kecamatan, lat, lon)
/// - 'prakiraan': list ringkasan cuaca per periode (suhu, kelembapan, cuaca, dll)
/// - 'sumber': "BMKG"
Future<Map<String, dynamic>> getCuacaLahan(String idLahan) async {
  // Cuaca manggil 4 API luar berurutan di backend, jadi butuh timeout panjang.
  final res = await apiGet(
    '/api/cuaca/$idLahan',
    headers: await headerAuth(),
    timeout: cuacaTimeout,
  );
  return parseResponse(res);
}

/// Ambil prakiraan cuaca BMKG umum mengikuti identitas diri pengguna
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
