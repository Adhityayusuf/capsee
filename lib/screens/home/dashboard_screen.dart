import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../widgets/home_top_bar.dart';
import '../../widgets/land_card.dart';
import '../akun/akun_screen.dart';
import '../lahan/daftar_lahan_screen.dart';
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

  final PageController _lahanPageController = PageController();
  int _lahanPage = 0;

  Map<String, dynamic>? _profil;
  List<Map<String, dynamic>>? _lahanList;
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _lahanPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profil = await getProfil();
      final lahanList = await getDaftarLahan();
      var unread = 0;
      try {
        unread = await getJumlahNotifikasiBelumDibaca();
      } catch (_) {
        unread = 0;
      }
      if (mounted) {
        setState(() {
          _profil = profil;
          _lahanList = lahanList;
          _unreadCount = unread;
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
      DaftarLahanScreen(
        lahanList: _lahanList,
        isLoading: _isLoading,
        onRefresh: _loadData,
        onAdd: _addLand,
        onOpenDetail: _openLandDetail,
        onEditLand: _openEditLahan,
        onDeleteLand: _openDeleteLahan,
        onScan: _openScan,
        unreadCount: _unreadCount,
        onNotifikasi: _openNotifikasi,
        onAkun: _openAkun,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _tab,
        onSelected: (index) => setState(() => _tab = index),
        onScan: _openScan,
      ),
    );
  }

  Widget _buildDashboard() {
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
                        style: _style(18, AppColors.title, FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      _badge(
                        '${_lahanList?.length ?? 0} Petak',
                        AppColors.chipBg,
                        AppColors.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _lahanPreview(),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  /// Cuplikan lahan di Beranda: maksimal 2 kartu per halaman.
  /// Jika lebih dari 2, halaman bisa digeser (swipe) dengan indikator titik.
  Widget _lahanPreview() {
    final list = _lahanList ?? const <Map<String, dynamic>>[];

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 44,
              color: AppColors.primary.withAlpha(120),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada data lahan.',
              style: _style(14, AppColors.title, FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan petak lahan pertama Anda untuk mulai memantau.',
              textAlign: TextAlign.center,
              style: _style(
                12,
                AppColors.subtitle,
                FontWeight.w400,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addLand,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Tambah Lahan'),
              ),
            ),
          ],
        ),
      );
    }

    final pages = <List<Map<String, dynamic>>>[];
    for (var i = 0; i < list.length; i += 2) {
      pages.add(list.sublist(i, (i + 2).clamp(0, list.length)));
    }

    if (pages.length == 1) {
      return _lahanPageContent(pages.first);
    }

    return Column(
      children: [
        SizedBox(
          height: 540,
          child: PageView.builder(
            controller: _lahanPageController,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _lahanPage = i),
            itemBuilder: (_, i) => _lahanPageContent(pages[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _lahanPage == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _lahanPage == i
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _lahanPageContent(List<Map<String, dynamic>> page) {
    return Column(
      children: [
        for (final land in page) ...[
          LandCard(
            land: land,
            onDetail: () => _openLandDetail(land),
            onScan: _openScan,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _header() => HomeTopBar(
    title: 'Dashboard',
    unreadCount: _unreadCount,
    onNotifikasi: _openNotifikasi,
    onAkun: _openAkun,
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
                  'Selamat Pagi, ${_profil?['nama']?.split(' ')?.first ?? 'Pengguna'} 🌿',
                  style: _style(21, AppColors.title, FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pantau kondisi ${_lahanList?.length ?? 0} petak lahan cabai Anda hari ini',
                  style: _style(12, AppColors.subtitle, FontWeight.w400),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _openRiwayatScan,
            icon: const Icon(Icons.document_scanner_rounded),
            color: AppColors.primary,
            tooltip: 'Riwayat pindaian',
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
              onPressed: _openScan,
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
      _message('Buat lahan terlebih dahulu sebelum melakukan pemindaian.');
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
<<<<<<< HEAD
      final res = await uploadScan(
        file: picked,
=======
      await uploadScan(
        file: File(picked.path),
>>>>>>> 36cd82eef4001c67b35f49e0ae33d50dd2a6c051
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
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TambahLahanPage()),
    );
    if (result != null) {
      _loadData();
    }
  }

  Future<void> _openEditLahan(Map<String, dynamic> land) async {
    final id = land['id'] as String?;
    if (id == null || id.isEmpty) {
      _message('Data lahan belum tersinkron, tidak bisa diedit.');
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TambahLahanPage(initial: landDataFromMap(land), idLahan: id),
      ),
    );
    if (result != null) {
      _loadData();
    }
  }

  Future<void> _openDeleteLahan(Map<String, dynamic> land) async {
    final id = land['id'] as String?;
    if (id == null || id.isEmpty) {
      _message('Data lahan belum tersinkron, tidak bisa dihapus.');
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Lahan?'),
        content: Text(
          'Lahan "${land['nama'] ?? 'ini'}" beserta seluruh jadwal dan '
          'riwayatnya akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      await hapusLahan(id);
      if (!mounted) return;
      _message('Lahan berhasil dihapus.');
      _loadData();
    } catch (e) {
      if (!mounted) return;
      _message('Gagal menghapus lahan: $e');
    }
  }

  void _openLandDetail(Map<String, dynamic> land) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LandDetailScreen(land: landDataFromMap(land)),
      ),
    ).then((_) => _loadData()); // Muat ulang setelah kembali dari detail
  }

  Future<void> _openNotifikasi() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
    // Sinkronkan badge setelah pengguna mungkin menandai notifikasi dibaca.
    _loadData();
  }

  Future<void> _openAkun() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AkunScreen()),
    );
    _loadData();
  }

  Future<void> _openRiwayatScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RiwayatScanScreen(items: _scanHistory, onScan: _openScan),
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
          Icon(icon, color: AppColors.tertiary, size: 18),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, -2),
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
                  _tab(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
                  const SizedBox(width: 76),
                  _tab(1, Icons.grass_outlined, Icons.grass_rounded, 'Lahan'),
                ],
              ),
              Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Center(child: _scanButton()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, IconData activeIcon, String label) {
    final selected = selectedIndex == index;
    final color = selected ? AppColors.primary : AppColors.icon;
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
              style: _style(
                10,
                color,
                selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton() => Semantics(
    button: true,
    label: 'Scan daun dengan kamera',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onScan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppColors.primary,
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
          Text('Scan', style: _style(10, AppColors.primary, FontWeight.w700)),
        ],
      ),
    ),
  );
}
