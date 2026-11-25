import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/app_colors.dart';
import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_style.dart';
import '../../core/theme_mode_scope.dart';
import '../../models/land_data.dart';
import '../../widgets/popup_notifikasi.dart';
import '../akun/akun_screen.dart';
import '../auth/lengkapi_identitas_screen.dart';
import '../lahan/detail_lahan_screen.dart';
import '../lahan/lahan_page.dart';
import '../lahan/tambah_lahan_page.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../scan/riwayat_scan_screen.dart';
import '../../services/services.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/feature_tour.dart';

const _dashboardLightPalette = AppPalette(
  background: dashboardLightBackground,
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEAF5EF),
  border: Color(0xFFE3EEE8),
  title: Color(0xFF1A2B23),
  subtitle: Color(0xFF61766B),
  hint: Color(0xFF8DA096),
  icon: Color(0xFF667C70),
  primary: Color(0xFF216D50),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFF19845F),
  accentSoft: Color(0xFFDDF5E9),
  onAccentSoft: Color(0xFF176447),
  error: Color(0xFFDC2626),
  shadow: Color(0x0A000000),
);

const _dashboardDarkPalette = AppPalette(
  background: dashboardDarkBackground,
  surface: Color(0xFF111F19),
  surfaceAlt: Color(0xFF1A2B23),
  border: Color(0xFF263B31),
  title: Color(0xFFEAF4EE),
  subtitle: Color(0xFFA8BDB2),
  hint: Color(0xFF789084),
  icon: Color(0xFF9BB2A6),
  primary: Color(0xFF28C98B),
  onPrimary: Color(0xFF062016),
  accent: Color(0xFF43D6A0),
  accentSoft: Color(0xFF153B2D),
  onAccentSoft: Color(0xFF8AE6C2),
  error: Color(0xFFF87171),
  shadow: Color(0x66000000),
);

ThemeData _dashboardTheme(ThemeData theme) {
  final palette = theme.brightness == Brightness.dark
      ? _dashboardDarkPalette
      : _dashboardLightPalette;
  return theme.copyWith(
    scaffoldBackgroundColor: palette.background,
    colorScheme: theme.colorScheme.copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      surface: palette.surface,
      onSurface: palette.title,
      surfaceContainerHighest: palette.surfaceAlt,
      outline: palette.border,
    ),
    iconTheme: IconThemeData(color: palette.icon),
    extensions: <ThemeExtension<dynamic>>[palette],
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  List<ScanHistoryItem> _scanHistory = [];
  LandData? _activeScanLand;
  int _scanReturnTab = 0;
  String? _tutorialPageRequest;
  int _tutorialRequest = 0;

  Map<String, dynamic>? _profil;
  List<Map<String, dynamic>>? _lahanList;
  bool _isLoading = true;

  Map<String, dynamic>? _cuaca;
  bool _loadingCuaca = true;
  String? _cuacaError;
  final GlobalKey _weatherTourKey = GlobalKey();
  final GlobalKey _addLandTourKey = GlobalKey();
  final GlobalKey _notificationTourKey = GlobalKey();
  final GlobalKey _accountTourKey = GlobalKey();
  final GlobalKey _bottomNavTourKey = GlobalKey();
  bool _dashboardTourScheduled = false;

  @override
  void initState() {
    super.initState();
    FeatureTour.register();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadingCuaca = true;
      _cuacaError = null;
    });
    try {
      final profil = await getProfil();
      // Guard wajib identitas: user lama yang belum lengkap dipaksa isi.
      if (!isProfilLengkap(profil)) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LengkapiIdentitasScreen()),
          );
        });
        return;
      }
      final lahanList = await getDaftarLahan();
      // Ambil riwayat scan dari SEMUA lahan (bukan list lokal kosong).
      // Satu lahan gagal tidak menggagalkan yang lain.
      final List<ScanHistoryItem> history = [];
      for (final lahan in lahanList) {
        final id = (lahan['id'] ?? '').toString();
        if (id.isEmpty) continue;
        try {
          final riwayat = await getRiwayatScan(id);
          for (final s in riwayat) {
            final waktu =
                DateTime.tryParse((s['dipindai_pada'] ?? '').toString()) ??
                DateTime.now();
            history.add(
              ScanHistoryItem(
                imagePath: '',
                scannedAt: waktu,
                idScan: (s['id'] ?? '').toString(),
                idLahan: id,
                urlGambar: (s['url_gambar'] ?? '').toString(),
                statusHasil: (s['status_hasil'] ?? '').toString(),
                labelHasil: (s['label_hasil'] ?? '').toString(),
              ),
            );
          }
        } catch (_) {
          // Lewati lahan yang gagal dimuat, lanjut ke lahan berikut.
        }
      }
      history.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      if (mounted) {
        setState(() {
          _profil = profil;
          _lahanList = lahanList;
          _scanHistory = history;
          _isLoading = false;
        });
        _scheduleDashboardTour();
      }
      // Cuaca umum ikut identitas diri (bukan per lahan).
      try {
        final cuaca = await getCuacaProfil();
        if (mounted) {
          setState(() {
            _cuaca = cuaca;
            _loadingCuaca = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        // Backend 400 = identitas belum lengkap → paksa ke form.
        if (e is ApiException && e.statusCode == 400) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LengkapiIdentitasScreen(),
              ),
            );
          });
          setState(() => _loadingCuaca = false);
          return;
        }
        setState(() {
          _loadingCuaca = false;
          _cuacaError = pesanError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingCuaca = false;
        });
        _scheduleDashboardTour();
        _message('Gagal memuat data: ${pesanError(e)}');
      }
    }
  }

  void _scheduleDashboardTour() {
    if (_dashboardTourScheduled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isLoading) return;
      _dashboardTourScheduled = true;
      await FeatureTour.start(
        pageKey: 'dashboard',
        keys: [
          _weatherTourKey,
          _addLandTourKey,
          _notificationTourKey,
          _accountTourKey,
          _bottomNavTourKey,
        ],
      );
    });
  }

  /// Refresh ringan daftar lahan + riwayat scan (tanpa sentuh profil/cuaca).
  /// Dipakai saat kembali ke tab dashboard atau setelah ubah data di tab lahan.
  Future<void> _muatUlangLahan() async {
    try {
      final lahanList = await getDaftarLahan();
      final List<ScanHistoryItem> history = [];
      for (final lahan in lahanList) {
        final id = (lahan['id'] ?? '').toString();
        if (id.isEmpty) continue;
        try {
          final riwayat = await getRiwayatScan(id);
          for (final s in riwayat) {
            final waktu =
                DateTime.tryParse((s['dipindai_pada'] ?? '').toString()) ??
                DateTime.now();
            history.add(
              ScanHistoryItem(
                imagePath: '',
                scannedAt: waktu,
                idScan: (s['id'] ?? '').toString(),
                idLahan: id,
                urlGambar: (s['url_gambar'] ?? '').toString(),
                statusHasil: (s['status_hasil'] ?? '').toString(),
                labelHasil: (s['label_hasil'] ?? '').toString(),
              ),
            );
          }
        } catch (_) {
          // Lewati lahan yang gagal dimuat, lanjut ke lahan berikut.
        }
      }
      history.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      if (mounted) {
        setState(() {
          _lahanList = lahanList;
          _scanHistory = history;
        });
      }
    } catch (_) {
      // Abaikan: dashboard tetap tampilkan data terakhir.
    }
  }

  Future<void> _muatUlangCuaca() async {
    setState(() {
      _loadingCuaca = true;
      _cuacaError = null;
    });
    try {
      final cuaca = await getCuacaProfil();
      if (mounted) {
        setState(() {
          _cuaca = cuaca;
          _loadingCuaca = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCuaca = false;
          _cuacaError = pesanError(e);
        });
      }
    }
  }

  Future<void> _replayDashboardTutorial() async {
    await FeatureTour.replay(
      pageKey: 'dashboard',
      keys: [
        _weatherTourKey,
        _addLandTourKey,
        _notificationTourKey,
        _accountTourKey,
        _bottomNavTourKey,
      ],
    );
  }

  void _requestTutorial(String pageKey) {
    final page = FeatureTourPageOption.fromKey(pageKey);
    if (page == null) return;

    if (page.tabIndex == 0) {
      setState(() {
        _activeScanLand = null;
        _tab = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _replayDashboardTutorial();
      });
      return;
    }

    setState(() {
      _activeScanLand = null;
      _tab = page.tabIndex;
      _tutorialPageRequest = page.pageKey;
      _tutorialRequest++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      RiwayatScanScreen(
        items: _scanHistory,
        isActive: _tab == 1,
        tutorialPageRequest: _tutorialPageRequest,
        tutorialRequest: _tutorialRequest,
        onScan: () => _openScan(),
      ),
      LahanPage(
        isActive: _tab == 2,
        tutorialPageRequest: _tutorialPageRequest,
        tutorialRequest: _tutorialRequest,
        onChanged: _muatUlangLahan,
      ),
      NotifikasiScreen(
        isActive: _tab == 3,
        tutorialPageRequest: _tutorialPageRequest,
        tutorialRequest: _tutorialRequest,
      ),
      AkunScreen(
        isActive: _tab == 4,
        tutorialPageRequest: _tutorialPageRequest,
        tutorialRequest: _tutorialRequest,
        onTutorialPageSelected: _requestTutorial,
      ),
      if (_activeScanLand != null)
        LandDetailScreen(
          key: ValueKey(_activeScanLand!.id),
          land: _activeScanLand!,
          initialTab: 0,
          onBack: _closeActiveScan,
          onScanSaved: _muatUlangLahan,
        ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      // Halaman scan dari menu cepat tampil sebagai halaman internal dashboard.
      // Bottom bar disembunyikan agar tidak ikut tampil saat kamera digunakan.
      bottomNavigationBar: _activeScanLand == null
          ? Showcase(
              key: _bottomNavTourKey,
              title: 'Navigasi utama',
              description:
                  'Gunakan menu ini untuk berpindah antara Home, Riwayat, Lahan, Notifikasi, dan Akun.',
              child: _BottomNav(
                selectedIndex: _tab == 4 ? 3 : (_tab < 3 ? _tab : -1),
                onSelected: (index) {
                  final target = index == 3 ? 4 : index;
                  setState(() {
                    _activeScanLand = null;
                    _tab = target;
                  });
                  // Kembali ke dashboard → segarkan daftar agar tidak basi
                  // (mis. habis hapus lahan di tab lahan).
                  if (target == 0) _muatUlangLahan();
                },
                onScan: () => _openScan(),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return Theme(
      data: _dashboardTheme(Theme.of(context)),
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.palette.background,
          child: SafeArea(
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Showcase(
                          key: _weatherTourKey,
                          title: 'Cuaca hari ini',
                          description:
                              'Lihat kondisi cuaca dan rekomendasi perawatan berdasarkan lokasi kebun.',
                          child: _climateCard(),
                        ),
                        const SizedBox(height: 12),
                        Showcase(
                          key: _addLandTourKey,
                          title: 'Tambah lahan',
                          description:
                              'Gunakan tombol ini untuk menambahkan data lahan pertama atau lahan baru.',
                          child: _addLandPrompt(),
                        ),
                        const SizedBox(height: 20),
                        _summaryCard(),
                        const SizedBox(height: 20),
                        _sectionHeading(
                          'Lahan Terbaru',
                          trailing: '${_lahanList?.length ?? 0} lahan',
                          onAction: () => setState(() => _tab = 2),
                        ),
                        const SizedBox(height: 10),
                        if (_lahanList == null || _lahanList!.isEmpty)
                          _emptyLandCard()
                        else ...[
                          for (final landMap in _lahanList!.take(3)) ...[
                            _landCard(landMap),
                            const SizedBox(height: 10),
                          ],
                          if (_lahanList!.length > 3)
                            Center(
                              child: TextButton(
                                onPressed: () => setState(() => _tab = 2),
                                child: Text(
                                  'Lihat semua ${_lahanList!.length} lahan',
                                ),
                              ),
                            ),
                        ],
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final p = context.palette;
    return DashboardHeader(
      title: 'Kebun cabai',
      actions: [
        Showcase(
          key: _notificationTourKey,
          title: 'Notifikasi',
          description:
              'Buka notifikasi untuk melihat pengingat cuaca dan kondisi tanaman.',
          child: DashboardHeaderAction(
            tooltip: 'Buka notifikasi',
            icon: Icons.notifications_rounded,
            onPressed: () => setState(() => _tab = 3),
            backgroundColor: p.surfaceAlt,
            foregroundColor: p.accent,
          ),
        ),
        _themeToggle(),
        Showcase(
          key: _accountTourKey,
          title: 'Akun dan pengaturan',
          description:
              'Buka halaman ini untuk mengelola profil, bantuan, dan pengaturan aplikasi.',
          child: DashboardHeaderAction(
            tooltip: 'Buka akun dan pengaturan',
            icon: Icons.settings_rounded,
            onPressed: () => setState(() => _tab = 4),
            backgroundColor: p.surfaceAlt,
            foregroundColor: p.accent,
          ),
        ),
      ],
    );
  }

  Widget _themeToggle() {
    final themeMode = ThemeModeScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DashboardHeaderAction(
      tooltip: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      onPressed: () {
        if (themeMode != null) {
          themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
        }
      },
      backgroundColor: context.palette.surfaceAlt,
      foregroundColor: context.palette.accent,
    );
  }

  Widget _sectionHeading(
    String title, {
    String? trailing,
    VoidCallback? onAction,
  }) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppText.subtitle(
              context,
              color: p.title,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null)
          onAction == null
              ? Text(trailing, style: AppText.micro(context, color: p.subtitle))
              : TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(trailing),
                ),
      ],
    );
  }

  Widget _addLandPrompt() {
    final p = context.palette;
    final hasLand = _lahanList?.isNotEmpty ?? false;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: .75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasLand ? 'Kebun cabai Anda' : 'Mulai pantau kebun cabai',
            style: AppText.subtitle(
              context,
              color: p.title,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            hasLand
                ? 'Kelola data lahan dan pantau kesehatan tanaman dalam satu tempat.'
                : 'Tambahkan lahan pertama untuk mencatat perawatan dan memantau tanaman.',
            style: AppText.caption(context, color: p.subtitle),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addLand,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(hasLand ? 'Tambah Lahan' : 'Tambah Lahan Pertama'),
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: .75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Ringkasan Kebun'),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryMetric(
                icon: Icons.grass_rounded,
                label: 'Lahan terdaftar',
                value: '${_lahanList?.length ?? 0}',
                color: p.accent,
              ),
              const SizedBox(width: 10),
              _summaryMetric(
                icon: Icons.document_scanner_rounded,
                label: 'Riwayat scan',
                value: '${_scanHistory.length}',
                color: const Color(0xFF55A8FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final p = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.micro(context, color: p.subtitle)),
                  Text(
                    value,
                    style: AppText.subtitle(
                      context,
                      color: p.title,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyLandCard() {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border.withValues(alpha: .75)),
      ),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, color: p.accent, size: 32),
          const SizedBox(height: 8),
          Text(
            'Belum ada data lahan',
            style: AppText.subtitle(context, color: p.title),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan lahan untuk mulai memantau tanaman cabai.',
            textAlign: TextAlign.center,
            style: AppText.caption(context, color: p.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _climateCard() {
    final p = context.palette;

    // Lokasi domisili dari identitas diri (fallback kalau cuaca gagal).
    final profilKec = (_profil?['kecamatan'] ?? '').toString();
    final profilKota = (_profil?['kota'] ?? '').toString();
    final lokasiFallback = [
      profilKec,
      profilKota,
    ].where((s) => s.isNotEmpty).join(', ');

    if (_loadingCuaca) {
      return _weatherMessageCard(
        title: lokasiFallback.isEmpty ? 'Memuat lokasi...' : lokasiFallback,
        message: 'Mengambil prakiraan cuaca BMKG...',
        trailing: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_cuacaError != null || _cuaca == null) {
      return _weatherMessageCard(
        title: lokasiFallback.isEmpty ? 'Cuaca belum tersedia' : lokasiFallback,
        message: 'Cuaca gagal dimuat: ${_cuacaError ?? 'data kosong'}',
        trailing: IconButton(
          tooltip: 'Muat ulang cuaca',
          onPressed: _muatUlangCuaca,
          icon: const Icon(Icons.refresh_rounded, size: 20),
        ),
      );
    }

    final lokasi = Map<String, dynamic>.from((_cuaca!['lokasi'] as Map?) ?? {});
    final prakiraan = (_cuaca!['prakiraan'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final hariIni = prakiraan.isNotEmpty
        ? prakiraan.first
        : <String, dynamic>{};

    final labelLokasi = [
      (lokasi['kecamatan'] ?? profilKec).toString(),
      (lokasi['kota_kabupaten'] ?? lokasi['kota'] ?? profilKota).toString(),
    ].where((s) => s.isNotEmpty).join(', ');
    final suhu = hariIni['suhu'];
    final cuacaDesc = (hariIni['cuaca'] ?? '-').toString();
    final lembap = hariIni['kelembapan'];
    final angin = hariIni['kecepatan_angin'];
    final hujan = hariIni['kemungkinan_hujan'] == true;
    final weatherIcon = _weatherIcon(cuacaDesc);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF173B2D), Color(0xFF10251D), Color(0xFF111F19)]
              : const [Color(0xFFE9FFF4), Color(0xFFD8F6E8), Color(0xFFF4FCF7)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.accent.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: p.accent, size: 17),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  labelLokasi.isEmpty ? 'Lokasi Anda' : labelLokasi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(
                    context,
                    color: p.subtitle,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang cuaca',
                onPressed: _muatUlangCuaca,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.refresh_rounded, color: p.subtitle, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: Icon(weatherIcon, color: p.accent, size: 31),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suhu == null ? '--°C' : '$suhu°C',
                      style: AppText.display(context, color: p.title).copyWith(
                        fontSize: 33,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cuacaDesc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption(
                        context,
                        color: p.subtitle,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Cuaca hari ini',
                    style: AppText.micro(context, color: p.subtitle),
                  ),
                  Text(
                    hariIni['kemungkinan_hujan'] == true
                        ? 'Berpotensi hujan'
                        : 'Pantauan BMKG',
                    textAlign: TextAlign.end,
                    style: AppText.micro(
                      context,
                      color: p.accent,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _weatherStat(
                Icons.water_drop_rounded,
                'Lembap',
                lembap == null ? '-' : '$lembap%',
              ),
              const SizedBox(width: 8),
              _weatherStat(
                Icons.air_rounded,
                'Angin',
                angin == null ? '-' : '$angin km/j',
              ),
            ],
          ),
          if (prakiraan.length > 1) ...[
            const SizedBox(height: 14),
            Divider(color: p.border, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final ramalan in prakiraan.take(4))
                  Expanded(child: _forecastDay(ramalan)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: .78),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hujan ? Icons.umbrella_rounded : Icons.lightbulb_rounded,
                  color: p.accent,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    hujan
                        ? 'Berpotensi hujan hari ini di $labelLokasi. Tunda penyemprotan dan pastikan drainase petak lancar.'
                        : 'Kondisi ideal untuk penyemprotan nutrisi pagi ini sebelum pukul 10:00 WIB di $labelLokasi.',
                    style: AppText.micro(context, color: p.subtitle),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherMessageCard({
    required String title,
    required String message,
    required Widget trailing,
  }) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: p.accent, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle(context, color: p.title),
                ),
              ),
              trailing,
            ],
          ),
          Text(message, style: AppText.caption(context, color: p.subtitle)),
          const SizedBox(height: 3),
          Text('Sumber: BMKG', style: AppText.micro(context, color: p.hint)),
        ],
      ),
    );
  }

  Widget _weatherStat(IconData icon, String label, String value) {
    final p = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: p.accent),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.micro(context, color: p.subtitle)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(
                      context,
                      color: p.title,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _forecastDay(Map<String, dynamic> forecast) {
    final p = context.palette;
    final date = DateTime.tryParse((forecast['waktu_lokal'] ?? '').toString());
    final day = date == null
        ? '-'
        : const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][date.weekday -
              1];
    final description = (forecast['cuaca'] ?? '').toString();
    return Column(
      children: [
        Text(day, style: AppText.micro(context, color: p.subtitle)),
        const SizedBox(height: 4),
        Icon(_weatherIcon(description), color: p.accent, size: 18),
        const SizedBox(height: 3),
        Text(
          forecast['suhu'] == null ? '--°' : '${forecast['suhu']}°',
          style: AppText.micro(
            context,
            color: p.title,
          ).copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  IconData _weatherIcon(String description) {
    final text = description.toLowerCase();
    if (text.contains('hujan') || text.contains('petir')) {
      return Icons.thunderstorm_rounded;
    }
    if (text.contains('awan') || text.contains('mendung')) {
      return Icons.cloud_rounded;
    }
    return Icons.wb_sunny_rounded;
  }

  Widget _landCard(Map<String, dynamic> land) {
    final p = context.palette;
    final title = (land['nama'] ?? 'Petak Lahan').toString();
    final location = [
      (land['kecamatan'] ?? '').toString(),
      (land['kota'] ?? '').toString(),
    ].where((s) => s.isNotEmpty).join(', ');
    final age = (land['umur_tanaman_bulan'] ?? 0).toString();
    final notice =
        'Siram tiap ${land['interval_siram_minggu'] ?? 1} minggu • Pupuk tiap ${land['interval_pupuk_minggu'] ?? 1} minggu';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border.withValues(alpha: .75)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.eco_rounded, color: p.accent, size: 25),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.subtitle(
                        context,
                        color: p.title,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption(context, color: p.subtitle),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Lihat detail lahan',
                onPressed: () => _openLandDetail(land),
                icon: Icon(Icons.chevron_right_rounded, color: p.subtitle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available_rounded, color: p.accent, size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Tanam $age bulan • $notice',
                    style: AppText.micro(context, color: p.subtitle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _openLandDetail(land),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Detail'),
                ),
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openScan(lahanTetap: land),
                  icon: const Icon(Icons.document_scanner_rounded, size: 16),
                  label: const Text('Scan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// WAJIB pilih lahan dulu SEBELUM buka kamera.
  /// Kalau user batal pilih → return null, tidak ada foto diambil,
  /// tidak ada upload ke Cloudinary.
  Future<Map<String, dynamic>?> _pilihLahanUntukScan() async {
    final list = _lahanList ?? [];
    if (list.isEmpty) return null;
    if (list.length == 1) return list.first;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pilih Lahan untuk Scan', style: AppText.title(ctx)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final land = list[i];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.eco_rounded),
                title: Text(
                  (land['nama'] ?? 'Lahan').toString(),
                  style: AppText.subtitle(ctx),
                ),
                subtitle: Text(
                  '${land['kecamatan'] ?? ''}, ${land['kota'] ?? ''}',
                  style: AppText.bodySm(ctx),
                ),
                onTap: () => Navigator.of(ctx).pop(land),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _closeActiveScan() {
    if (!mounted) return;
    setState(() {
      _activeScanLand = null;
      _tab = _scanReturnTab;
    });
    if (_scanReturnTab == 0) _muatUlangLahan();
  }

  Future<void> _openScan({Map<String, dynamic>? lahanTetap}) async {
    if (_lahanList == null || _lahanList!.isEmpty) {
      if (mounted) {
        showInfoPopup(
          context,
          'Buat lahan terlebih dahulu sebelum melakukan scan.',
        );
      }
      return;
    }

    // Kalau dipanggil dari kartu lahan tertentu, pakai lahan itu langsung
    // tanpa dialog pilih (tetap wajib ada id).
    Map<String, dynamic>? target = lahanTetap;
    // 1. Pilih lahan dulu. Batal = berhenti, jangan buka kamera/upload.
    target ??= await _pilihLahanUntukScan();
    if (target == null || !mounted) return;
    if ((target['id'] ?? '').toString().isEmpty) {
      showErrorPopup(context, 'Lahan belum tersinkron. Pilih lahan lain.');
      return;
    }

    setState(() {
      _scanReturnTab = _tab;
      _activeScanLand = _landDataFromMap(target!);
      _tab = 5;
    });
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
            builder: (_) => LandDetailScreen(land: _landDataFromMap(land)),
          ),
        )
        .then((_) => _loadData()); // Muat ulang setelah kembali dari detail
  }

  LandData _landDataFromMap(Map<String, dynamic> land) {
    final now = DateTime.now();
    DateTime dateValue(dynamic value) =>
        DateTime.tryParse((value ?? '').toString()) ?? now;

    return LandData(
      id: land['id']?.toString(),
      name: (land['nama'] ?? 'Lahan').toString(),
      province: (land['provinsi'] ?? '').toString(),
      city: (land['kota'] ?? '').toString(),
      district: (land['kecamatan'] ?? '').toString(),
      plantAgeMonths: (land['umur_tanaman_bulan'] as num?)?.toInt() ?? 1,
      lastWatered: dateValue(land['tanggal_terakhir_siram']),
      lastFertilized: dateValue(land['tanggal_terakhir_pupuk']),
      fertilizeIntervalWeeks:
          (land['interval_pupuk_minggu'] as num?)?.toInt() ?? 1,
      wateringIntervalWeeks:
          (land['interval_siram_minggu'] as num?)?.toInt() ?? 1,
    );
  }

  void _message(String message) {
    if (!mounted) return;
    showInfoPopup(context, message);
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
    return Theme(
      data: _dashboardTheme(Theme.of(context)),
      child: Builder(
        builder: (context) {
          final p = context.palette;
          return Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border(top: BorderSide(color: p.border)),
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
                                context,
                                p,
                                0,
                                Icons.home_outlined,
                                Icons.home_rounded,
                                'Home',
                              ),
                              _tab(
                                context,
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
                                context,
                                p,
                                2,
                                Icons.eco_outlined,
                                Icons.eco_rounded,
                                'Lahan',
                              ),
                              _tab(
                                context,
                                p,
                                3,
                                Icons.person_outline_rounded,
                                Icons.person_rounded,
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
                      child: Center(child: _scanButton(context, p)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tab(
    BuildContext context,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? p.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(selected ? activeIcon : icon, color: color, size: 21),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: AppText.micro(context, color: color).copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton(BuildContext context, AppPalette p) => Semantics(
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
          Text(
            'Scan',
            style: AppText.micro(
              context,
              color: p.accent,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}
