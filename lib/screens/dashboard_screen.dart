import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../models/land_data.dart';
import 'akun_screen.dart';
import 'detail_lahan_screen.dart';
import 'tambah_lahan_page.dart';
import 'notifikasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  static const _lands = [
    _Land(
      title: 'Petak Cabai Rawit Blok A',
      category: 'BLOK HORTIKULTURA',
      location: 'Lembang, Bandung Barat',
      phase: '3 Bulan • Fase Berbuah Lebat',
      status: 'Tanaman Sehat',
      statusDetail: '98% Bebas Hama',
      notice: 'Jadwal pemupukan interval 1 minggu jatuh tempo besok pagi.',
      icon: Icons.verified_rounded,
    ),
    _Land(
      title: 'Petak Cabai Merah Keriting B2',
      category: 'ATENSI MENDESAK',
      location: 'Parongpong, Bandung Barat',
      phase: '2.5 Bulan • Fase Pembungaan',
      status: 'Perlu Perhatian',
      statusDetail: 'Indikasi Antraknosa',
      notice:
          'Rekomendasi isolasi 4 tanaman di baris ke-3 untuk mencegah penyebaran patogen.',
      icon: Icons.warning_rounded,
      warning: true,
    ),
    _Land(
      title: 'Petak Pembibitan Greenhouse C',
      category: 'BIBIT BARU',
      location: 'Ciater, Subang',
      phase: '3 Minggu • Fase Vegetatif Awal',
      status: 'Belum Discan',
      statusDetail: 'Perlu Kalibrasi',
      notice:
          'Lakukan foto daun pertama hari ini untuk kalibrasi pertumbuhan bulan ke-2.',
      icon: Icons.pending_actions_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      const NotifikasiScreen(),
      const AkunScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Notifikasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _greeting(),
                const SizedBox(height: 16),
                _climateCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Lahan Anda',
                      style: _style(18, AppColors.title, FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    _badge('3 Petak', AppColors.chipBg, AppColors.title),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addLand,
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final land in _lands) ...[
                  _landCard(land),
                  const SizedBox(height: 14),
                ],
                OutlinedButton.icon(
                  onPressed: _addLand,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Tambah Lahan Baru'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: AppColors.background,
      boxShadow: [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 8,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAPSEE',
              style: _style(
                10,
                AppColors.primary,
                FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Dashboard',
              style: _style(18, AppColors.title, FontWeight.w700, height: 1),
            ),
          ],
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
        ),
      ],
    ),
  );

  Widget _greeting() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _badge(
                  'Sistem Diagnostik Aktif',
                  AppColors.primarySoft,
                  AppColors.primary,
                ),
                const SizedBox(height: 5),
                Text(
                  'Selamat Pagi, Pak Budi 🌿',
                  style: _style(21, AppColors.title, FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pantau kondisi 3 petak lahan cabai Anda hari ini',
                  style: _style(12, AppColors.subtitle, FontWeight.w400),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _message('Membuka riwayat pindaian...'),
            icon: const Icon(Icons.document_scanner_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.photo_camera_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deteksi Penyakit Instan',
                    style: _style(14, Colors.white, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Arahkan kamera ke daun bercak atau layu',
                    style: _style(11, Colors.white70, FontWeight.w400),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => _message('Fitur kamera siap dihubungkan'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Buka Lensa'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _climateCard() => Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lembang, Bandung Barat',
                      style: _style(12, AppColors.title, FontWeight.w700),
                    ),
                    Text(
                      'Elevasi 1.240 mdpl',
                      style: _style(11, AppColors.subtitle, FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Text(
                '24°C • Berawan',
                style: _style(11, AppColors.title, FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _Climate(
                icon: Icons.water_drop_rounded,
                title: 'Kelembapan',
                value: '78%',
              ),
              SizedBox(width: 7),
              _Climate(
                icon: Icons.air_rounded,
                title: 'Angin',
                value: '12 km/j',
              ),

            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kondisi ideal untuk penyemprotan nutrisi pagi ini sebelum pukul 10:00 WIB. Daun kering sempurna dan angin tenang.',
                    style: _style(
                      11,
                      AppColors.title,
                      FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _landCard(_Land land) {
    final color = land.warning ? AppColors.error : AppColors.primary;
    return Card(
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: land.warning
                        ? AppColors.error.withAlpha(25)
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.eco_rounded, color: color, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        land.category,
                        style: _style(
                          10,
                          color,
                          FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        land.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(13, AppColors.title, FontWeight.w700),
                      ),
                      Text(
                        land.location,
                        style: _style(11, AppColors.subtitle, FontWeight.w400),
                      ),
                      Text(
                        land.phase,
                        style: _style(11, AppColors.title, FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color:
                    (land.warning
                            ? const Color(0xFFFFDAD6)
                            : AppColors.primarySoft)
                        .withAlpha(130),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(land.icon, color: color, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      land.status,
                      style: _style(12, color, FontWeight.w700),
                    ),
                  ),
                  Text(
                    land.statusDetail,
                    style: _style(10, color, FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    land.warning
                        ? Icons.notification_important_rounded
                        : Icons.event_available_rounded,
                    color: color,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      land.notice,
                      style: _style(
                        11,
                        AppColors.title,
                        FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openLandDetail(land),
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _message('Fitur scan siap dihubungkan'),
                    icon: const Icon(Icons.photo_camera_rounded, size: 17),
                    label: Text(land.warning ? 'Pindai Ulang' : 'Pindai Daun'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: _style(10, foreground, FontWeight.w700)),
  );

  void _addLand() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TambahLahanPage()));
  }

  void _openLandDetail(_Land land) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LandDetailScreen(
          land: LandData(
            name: land.title,
            province: 'Jawa Barat',
            city: 'Bandung Barat',
            district: land.warning ? 'Parongpong' : 'Lembang',
            plantAgeMonths: land.warning ? 2 : 3,
            lastWatered: DateTime(2024, 10, 26),
            lastFertilized: DateTime(2024, 10, 24),
            fertilizeIntervalWeeks: 1,
          ),
        ),
      ),
    );
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

TextStyle _style(
  double size,
  Color color,
  FontWeight weight, {
  double? height,
  double? letterSpacing,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

class _Climate extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _Climate({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF005B8C), size: 18),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _style(9, AppColors.subtitle, FontWeight.w400),
          ),
          const SizedBox(height: 2),
          Text(value, style: _style(11, AppColors.title, FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _Land {
  final String title, category, location, phase, status, statusDetail, notice;
  final IconData icon;
  final bool warning;
  const _Land({
    required this.title,
    required this.category,
    required this.location,
    required this.phase,
    required this.status,
    required this.statusDetail,
    required this.notice,
    required this.icon,
    this.warning = false,
  });
}
