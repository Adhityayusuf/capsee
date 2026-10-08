import 'package:http/http.dart' as http;
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
  final res = await http.get(
    Uri.parse('$baseUrl/api/cuaca/$idLahan'),
    headers: await headerAuth(),
  );
  return parseResponse(res);
}
