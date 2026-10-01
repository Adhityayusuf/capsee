/// Label fase pertumbuhan berdasarkan umur tanaman (bulan).
/// Dipakai oleh form Tambah Data Lahan dan halaman Detail Lahan.
const Map<int, String> plantPhaseLabels = {
  1: 'Fase Vegetatif Awal',
  2: 'Fase Vegetatif Lanjut',
  3: 'Fase Berbunga & Berbuah',
  4: 'Fase Berbuah',
  5: 'Fase Panen',
};

/// Data lahan / petak kebun cabai yang diinput user.
class LandData {
  final String name;
  final String province;
  final String city;
  final String district;
  final int plantAgeMonths;
  final DateTime lastWatered;
  final DateTime lastFertilized;
  final int fertilizeIntervalWeeks;

  const LandData({
    required this.name,
    required this.province,
    required this.city,
    required this.district,
    required this.plantAgeMonths,
    required this.lastWatered,
    required this.lastFertilized,
    required this.fertilizeIntervalWeeks,
  });

  /// Dipakai nanti saat mengirim data ke API.
  Map<String, dynamic> toJson() => {
    'name': name,
    'province': province,
    'city': city,
    'district': district,
    'plant_age_months': plantAgeMonths,
    'last_watered': lastWatered.toIso8601String(),
    'last_fertilized': lastFertilized.toIso8601String(),
    'fertilize_interval_weeks': fertilizeIntervalWeeks,
  };
}
