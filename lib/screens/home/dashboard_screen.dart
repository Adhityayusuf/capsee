import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../core/theme_mode_scope.dart';
import '../../models/land_data.dart';
import '../akun/akun_screen.dart';
import '../lahan/detail_lahan_screen.dart';
import '../lahan/tambah_lahan_page.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../scan/hasil_scan_tidak_sehat.dart';
import '../scan/riwayat_scan_screen.dart';
import '../../services/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  final ImagePicker _picker = ImagePicker();
  final List<ScanHistoryItem> _scanHistory = [];

  Map<String, dynamic>? _profil;
  List<Map<String, dynamic>>? _lahanList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profil = await getProfil();
      final lahanList = await getDaftarLahan();
      if (mounted) {
        setState(() {
          _profil = profil;
          _lahanList = lahanList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _message('Gagal memuat data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      RiwayatScanScreen(items: _scanHistory, onScan: _openScan),
      const NotifikasiScreen(),
      const AkunScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _tab == 3 ? 3 : (_tab < 2 ? _tab : -1),
        onSelected: (index) {
          if (index == 2) {
            _addLand();
          } else {
            setState(() => _tab = index == 3 ? 3 : index);
          }
        },
        onScan: _openScan,
      ),
    );
  }

  Widget _buildDashboard() {
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
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
                        style: _style(18, p.title, FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      _badge(
                        '${_lahanList?.length ?? 0} Petak',
                        p.surfaceAlt,
                        p.title,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addLand,
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text('Tambah'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_lahanList == null || _lahanList!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Belum ada data lahan.',
                          style: _style(13, p.subtitle, FontWeight.w400),
                        ),
                      ),
                    )
                  else
                    for (final landMap in _lahanList!) ...[
                      _landCard(landMap),
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

  Widget _header() {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.surface,
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.primary,
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
                  p.accent,
                  FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Dashboard',
                style: _style(18, p.title, FontWeight.w700, height: 1),
              ),
            ],
          ),
          const Spacer(),
          _headerAction(
            tooltip: 'Buka notifikasi',
            icon: Icons.notifications_rounded,
            onPressed: () => setState(() => _tab = 2),
            backgroundColor: p.primary,
            foregroundColor: Colors.white,
          ),
          const SizedBox(width: 8),
          _themeToggle(),
        ],
      ),
    );
  }

  Widget _headerAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) => Tooltip(
    message: tooltip,
    child: Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: foregroundColor, size: 20),
        ),
      ),
    ),
  );

  Widget _themeToggle() {
    final themeMode = ThemeModeScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _headerAction(
      tooltip: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      onPressed: () {
        if (themeMode != null) {
          themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _greeting() {
    final p = context.palette;

    return Column(
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
                    p.accentSoft,
                    p.onAccentSoft,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Selamat Pagi, ${_profil?['nama']?.split(' ')?.first ?? 'Pengguna'}',
                    style: _style(21, p.title, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Pantau kondisi ${_lahanList?.length ?? 0} petak lahan cabai Anda hari ini',
                    style: _style(12, p.subtitle, FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _climateCard() {
    final p = context.palette;

    return Card(
      elevation: 0,
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: p.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lembang, Bandung Barat',
                        style: _style(12, p.title, FontWeight.w700),
                      ),
                      Text(
                        'Elevasi 1.240 mdpl',
                        style: _style(11, p.subtitle, FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Text(
                  '24°C • Berawan',
                  style: _style(11, p.title, FontWeight.w700),
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
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: p.accent, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kondisi ideal untuk penyemprotan nutrisi pagi ini sebelum pukul 10:00 WIB. Daun kering sempurna dan angin tenang.',
                      style: _style(
                        11,
                        p.title,
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
  }

  Widget _landCard(Map<String, dynamic> land) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = land['nama'] ?? 'Petak Lahan';
    final location = '${land['kecamatan'] ?? ''}, ${land['kota'] ?? ''}'.trim();
    final phase = '${land['umur_tanaman_bulan'] ?? 0} Bulan';
    final category = 'BLOK HORTIKULTURA'; // Bisa dari API jika ada

    // Status dummy karena detail status dan jadwal didapat dari endpoint lain
    final status = 'Sedang Dipantau';
    final statusDetail = 'Data Tersinkronisasi';
    final notice =
        'Interval pupuk tiap ${land['interval_pupuk_minggu']} minggu.';
    final warning = false;

    final color = warning ? p.error : p.accent;
    final statusBg = warning
        ? p.error.withAlpha(40)
        : p.accentSoft.withAlpha(isDark ? 255 : 130);

    return Card(
      elevation: 1,
      color: p.surface,
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
                    color: warning ? p.error.withAlpha(25) : p.accentSoft,
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
                        category,
                        style: _style(
                          10,
                          color,
                          FontWeight.w700,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(13, p.title, FontWeight.w700),
                      ),
                      Text(
                        location,
                        style: _style(11, p.subtitle, FontWeight.w400),
                      ),
                      Text(
                        phase,
                        style: _style(11, p.title, FontWeight.w600),
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
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: color, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      status,
                      style: _style(12, color, FontWeight.w700),
                    ),
                  ),
                  Text(statusDetail, style: _style(10, color, FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning
                        ? Icons.notification_important_rounded
                        : Icons.event_available_rounded,
                    color: color,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      notice,
                      style: _style(
                        11,
                        p.title,
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
                    onPressed: _openScan,
                    icon: const Icon(Icons.photo_camera_rounded, size: 17),
                    label: Text(warning ? 'Scan' : 'Scan'),
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

  Future<void> _openScan() async {
    if (_lahanList == null || _lahanList!.isEmpty) {
      _message('Buat lahan terlebih dahulu sebelum melakukan scan.');
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null || !mounted) return;

      // Ambil ID lahan pertama sebagai target scan (untuk testing dari dashboard)
      final String idLahanTarget = _lahanList!.first['id'];

      // Tampilkan loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Panggil backend: ini akan otomatis kompres, upload ke Cloudinary, dan simpan ke DB!
      final res = await uploadScan(
        file: File(picked.path),
        idLahan: idLahanTarget,
        bagianTanaman: 'daun', // Default dari dashboard
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading

      _message('Upload berhasil! URL Cloudinary tersimpan di Neon.');

      // Buka halaman hasil statis (tampilannya masih statis, tapi datanya sudah masuk DB)
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HasilScanTidakSehatPage()),
      );

      // Muat ulang data untuk memperbarui riwayat lahan
      _loadData();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading
      _message('Gagal melakukan scan atau upload: $e');
    }
  }

  Future<void> _addLand() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TambahLahanPage()));
    if (result == true) {
      _loadData();
    }
  }

  void _openLandDetail(Map<String, dynamic> land) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => LandDetailScreen(
              land: LandData(
                id: land['id'] as String?,
                name: land['nama'] ?? 'Lahan',
                province: land['provinsi'] ?? '',
                city: land['kota'] ?? '',
                district: land['kecamatan'] ?? '',
                plantAgeMonths: land['umur_tanaman_bulan'] ?? 1,
                lastWatered: land['tanggal_terakhir_siram'] != null
                    ? (DateTime.tryParse(land['tanggal_terakhir_siram']) ??
                          DateTime.now())
                    : DateTime.now(),
                lastFertilized: land['tanggal_terakhir_pupuk'] != null
                    ? (DateTime.tryParse(land['tanggal_terakhir_pupuk']) ??
                          DateTime.now())
                    : DateTime.now(),
                fertilizeIntervalWeeks: land['interval_pupuk_minggu'] ?? 1,
              ),
            ),
          ),
        )
        .then((_) => _loadData()); // Muat ulang setelah kembali dari detail
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
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              // Biru lebih terang di mode gelap supaya tetap terbaca
              color: isDark ? const Color(0xFF60A5FA) : AppColors.tertiary,
              size: 18,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _style(9, p.subtitle, FontWeight.w400),
            ),
            const SizedBox(height: 2),
            Text(value, style: _style(11, p.title, FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onScan;

  const _BottomNav({
    required this.selectedIndex,
    required this.onSelected,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _tab(
                          p,
                          0,
                          Icons.local_florist_outlined,
                          Icons.local_florist,
                          'Dashboard',
                        ),
                        _tab(
                          p,
                          1,
                          Icons.history_outlined,
                          Icons.history_rounded,
                          'Riwayat',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 66),
                  Expanded(
                    child: Row(
                      children: [
                        _tab(
                          p,
                          2,
                          Icons.add_location_alt_outlined,
                          Icons.add_location_alt_rounded,
                          'Lahan',
                        ),
                        _tab(
                          p,
                          3,
                          Icons.manage_accounts_outlined,
                          Icons.manage_accounts_rounded,
                          'Akun',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Center(child: _scanButton(p)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    AppPalette p,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final selected = selectedIndex == index;
    final color = selected ? p.accent : p.icon;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: _style(
                8.5,
                color,
                selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton(AppPalette p) => Semantics(
    button: true,
    label: 'Scan daun dengan kamera',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onScan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: p.primary,
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: AppColors.primaryShadow,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onScan,
              child: const SizedBox(
                width: 58,
                height: 58,
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text('Scan', style: _style(10, p.accent, FontWeight.w700)),
        ],
      ),
    ),
  );
}