import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class TabJadwal extends StatefulWidget {
  const TabJadwal({super.key});

  @override
  State<TabJadwal> createState() => _TabJadwalState();
}

class _TabJadwalState extends State<TabJadwal> {
  bool hematAir = true;
  bool showPupukOptions = false;
  bool activitySaved = false;
  bool syncing = false;
  String selectedPupuk = 'npk';

  final Map<String, Map<String, String>> pupukData = {
    'npk': {
      'name': 'NPK Mutiara 16-16-16 + Kalsium Nitrat (CNG)',
      'desc':
          'Sangat direkomendasikan pada petak fase pembuahan aktif untuk mempertebal dinding sel pericarp buah cabai, mencegah penyakit patek (antraknosa), dan menekan kerontokan bunga.',
      'dose': '5 gram / tanaman (250 ml larutan / lubang mulsa)',
    },
    'poc': {
      'name': 'Pupuk Organik Cair (POC) Urin Kelinci & Asam Humat',
      'desc':
          'Menggemburkan tanah mulsa, merangsang perakaran baru, dan menyediakan nitrogen organik.',
      'dose': '10 ml POC + 2 gr Asam Humat / Liter air (300 ml / lubang)',
    },
    'mkp': {
      'name': 'MKP (Mono Kalium Fosfat) + Gandasil B',
      'desc':
          'Diformulasikan untuk memaksimalkan akumulasi gula pada buah cabai, mempercepat rona merah panen, dan memperkokoh tangkai buah.',
      'dose': '3 gram / Liter air disemprotkan merata pada daun',
    },
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _plotInfo(),
          const SizedBox(height: 18),
          _wateringSection(),
          const SizedBox(height: 18),
          _fertilizerSection(),
          const SizedBox(height: 18),
          _sensorCard(),
          const SizedBox(height: 12),
          _actions(),
        ],
      ),
    );
  }

  Widget _plotInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Row(
        children: [
          _iconBox(Icons.local_florist, AppColors.primarySoft),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Petak Rawit Blok A • Umur 3 Bln',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Fase Berbuah Aktif (Generatif II)',
                    style: TextStyle(fontSize: 12, color: AppColors.hint)),
              ],
            ),
          ),
          _status('Optimal'),
        ],
      ),
    );
  }

  Widget _wateringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.water_drop,
          'Jadwal Penyiraman Mingguan',
          'Prediksi debit irigasi presisi integrasi BMKG',
          color: AppColors.tertiaryContainer,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryFixed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud, color: AppColors.tertiary),
              SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'SINKRONISASI BMKG AKTIF\n',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary),
                      ),
                      TextSpan(
                        text: 'Hujan lebat diprediksi terjadi ',
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: 'Rabu & Sabtu',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            '. Lengas tanah tercukupi (86%), penyiraman otomatis dilewati guna mencegah infeksi busuk akar.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _box(),
          child: Column(
            children: [
              _scheduleRow('SEN', '28', '06:30 WIB • 1.2 L/m²',
                  'Lengas tanah: 68% (Stabil)', 'Selesai'),
              _scheduleRow('SEL', '29', 'Hari Ini: 2x Penyiraman',
                  '06:30 & 16:30 WIB (Total 1.5 L/m²)', 'Aktif',
                  active: true),
              _scheduleRow('RAB', '30', '06:30 WIB • 1.2 L/m²',
                  'Presipitasi Lebat 85%', 'Dilewati', skipped: true),
              _scheduleRow('KAM', '31', '06:30 WIB • 1.2 L/m²',
                  'Sensor lengas tanah otomatis', 'Terjadwal'),
              _scheduleRow('JUM', '01', '06:30 WIB • 1.2 L/m²',
                  'Irigasi mikro tetes', 'Terjadwal'),
              _scheduleRow('SAB', '02', '06:30 WIB • 1.2 L/m²',
                  'Hujan Ringan BMKG 70%', 'Dilewati', skipped: true),
              _scheduleRow('MIN', '03', '06:30 WIB • 1.2 L/m²',
                  'Evaluasi kelembapan tanah', 'Terjadwal'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Mode Hemat Air (Adaptif Cuaca)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: hematAir,
                onChanged: (v) => setState(() => hematAir = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleRow(
    String day,
    String date,
    String title,
    String subtitle,
    String status, {
    bool active = false,
    bool skipped = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primarySoft
            : skipped
                ? AppColors.chipBg
                : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : AppColors.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.hint)),
                Text(date,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : AppColors.title)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: skipped ? AppColors.hint : AppColors.title,
                      decoration:
                          skipped ? TextDecoration.lineThrough : null,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: skipped
                            ? AppColors.tertiaryContainer
                            : AppColors.hint)),
              ],
            ),
          ),
          _status(status, active: active),
        ],
      ),
    );
  }

  Widget _fertilizerSection() {
    final data = pupukData[selectedPupuk]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.science,
          'Jadwal Nutrisi & Pemupukan',
          'Interval 1 minggu fase pematangan buah',
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('APLIKASI BERIKUTNYA',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Kamis, 31 Okt 2024',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('3 hari lagi • Pukul 07:00 - 09:00 WIB',
                  style: TextStyle(fontSize: 12, color: AppColors.hint)),
              Divider(height: 22),
              Text('Terakhir dipupuk: 24 Okt 2024 (Selesai)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.recommend,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Rekomendasi Formula AI',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(
                        () => showPupukOptions = !showPupukOptions),
                    icon: Icon(showPupukOptions
                        ? Icons.expand_less
                        : Icons.expand_more),
                    label: const Text('Ganti Jenis'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name']!,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(data['desc']!,
                        style: const TextStyle(fontSize: 12, color: AppColors.hint)),
                    const SizedBox(height: 8),
                    Text('Dosis: ${data['dose']}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (showPupukOptions) ...[
                const SizedBox(height: 10),
                RadioGroup<String>(
                  groupValue: selectedPupuk,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPupuk = value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final entry in pupukData.entries)
                        RadioListTile<String>(
                          value: entry.key,
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.value['name']!,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          subtitle: Text('Dosis: ${entry.value['dose']}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => showPupukOptions = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terapkan Jenis Pupuk Terpilih'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sensorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: const Row(
        children: [
          Icon(Icons.sensors, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Lengas Tanah IoT #C4',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Kapasitas Lapang: 74% • Suhu Media: 27.8°C',
                    style: TextStyle(fontSize: 11, color: AppColors.hint)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 9, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Sinkron',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => activitySaved = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tersimpan di Jurnal Petani!')),
              );
            },
            icon: Icon(activitySaved
                ? Icons.done_all
                : Icons.assignment_turned_in),
            label: Text(activitySaved
                ? 'Tersimpan di Jurnal Petani!'
                : 'Catat Realisasi Pupuk / Siram'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: syncing
                    ? null
                    : () async {
                        setState(() => syncing = true);
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (mounted) setState(() => syncing = false);
                      },
                icon: syncing
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync),
                label: const Text('Sinkronkan Ulang BMKG'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Jadwal siap untuk dibagikan.')),
              ),
              icon: const Icon(Icons.ios_share),
              label: const Text('Ekspor'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Data sensor lengas tanah & prediksi presipitasi BMKG diperbarui otomatis tiap 3 jam.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AppColors.hint),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title, String subtitle,
      {Color color = AppColors.primary}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconBox(icon, color.withValues(alpha: .12), iconColor: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.hint)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color background,
      {Color iconColor = AppColors.primary}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: iconColor, size: 21),
    );
  }

  Widget _status(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.primary)),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      );
}
