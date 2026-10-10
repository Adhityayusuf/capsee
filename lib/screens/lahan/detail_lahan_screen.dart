import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../models/activity_log.dart';
import '../../models/land_data.dart';
import '../../widgets/land_card.dart';
import '../scan/hasil_scan_tidak_sehat.dart';
import '../scan/treatment_recommendation_screen.dart';
import 'tab_jadwal.dart';
import 'tambah_lahan_page.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';

class LandDetailScreen extends StatefulWidget {
  final LandData land;
  const LandDetailScreen({super.key, required this.land});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  int _tabIndex = 2; // 0=Scan, 1=Jadwal, 2=Riwayat (sesuai desain)
  String _filter = 'Semua Aktivitas';

  // Data lahan yang bisa berubah setelah diedit.
  late LandData _land = widget.land;

  // State alur scan.
  String _selectedOrgan = 'leaf';
  int _imageSource = 0;
  bool _isAnalyzing = false;
  bool _isDone = false;
  final ImagePicker _picker = ImagePicker();

  // ── State cuaca BMKG ──
  Map<String, dynamic>? _cuaca; // prakiraan[0]
  bool _cuacaLoading = true;
  bool _cuacaError = false;
  String _cuacaErrorMsg = '';

  @override
  void initState() {
    super.initState();
    _loadCuaca();
  }

  Future<void> _loadCuaca() async {
    final idLahan = _land.id;
    if (idLahan == null || idLahan.isEmpty) {
      setState(() {
        _cuacaLoading = false;
        _cuacaError = true;
        _cuacaErrorMsg = 'Lahan belum tersinkron.';
      });
      return;
    }
    if (mounted) {
      setState(() {
        _cuacaLoading = true;
        _cuacaError = false;
        _cuacaErrorMsg = '';
      });
    }
    try {
      final data = await getCuacaLahan(idLahan);
      final prakiraan = data['prakiraan'] as List?;
      if (mounted) {
        setState(() {
          _cuaca = (prakiraan != null && prakiraan.isNotEmpty)
              ? prakiraan[0] as Map<String, dynamic>
              : null;
          _cuacaLoading = false;
          _cuacaError = _cuaca == null;
          if (_cuacaError) _cuacaErrorMsg = 'Data BMKG kosong.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cuacaLoading = false;
          _cuacaError = true;
          _cuacaErrorMsg = pesanError(e);
        });
      }
    }
  }

  Future<void> _openEditLahan() async {
    final id = _land.id;
    if (id == null || id.isEmpty) {
      _showError('Data lahan belum tersinkron, tidak bisa diedit.');
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TambahLahanPage(initial: _land, idLahan: id),
      ),
    );

    // TambahLahanPage mengembalikan true jika simpan sukses → muat ulang dari server.
    if (result == true && mounted) {
      try {
        final fresh = await getDetailLahan(id);
        if (!mounted) return;
        setState(() {
          _land = landDataFromMap(fresh);
        });
      } catch (_) {
        // Biarkan data lama tampil; user bisa refresh manual.
      }
      _loadCuaca();
    }
  }

  Future<void> _openHapusLahan() async {
    final id = _land.id;
    if (id == null || id.isEmpty) {
      _showError('Data lahan belum tersinkron, tidak bisa dihapus.');
      return;
    }

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Lahan?', style: AppText.title(dialogContext)),
        content: Text(
          'Lahan "${_land.name}" beserta seluruh jadwal dan riwayatnya akan '
          'dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
          style: AppText.body(dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    try {
      await hapusLahan(id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menghapus lahan: ${pesanError(e)}');
    }
  }

  static const _filters = [
    'Semua Aktivitas',
    'Diagnosa Scan',
    'Penyiraman',
    'Pemupukan',
    'Tindakan',
  ];

  List<ActivityLog> get _visibleLogs {
    if (_filter == 'Semua Aktivitas') return sampleActivityLogs;
    switch (_filter) {
      case 'Diagnosa Scan':
        return sampleActivityLogs
            .where((l) => l.category == ActivityCategory.scan)
            .toList();
      case 'Penyiraman':
        return sampleActivityLogs
            .where((l) => l.category == ActivityCategory.irrigation)
            .toList();
      case 'Pemupukan':
        return sampleActivityLogs
            .where((l) => l.category == ActivityCategory.fertilizer)
            .toList();
      case 'Tindakan':
        return sampleActivityLogs
            .where((l) => l.category == ActivityCategory.alert)
            .toList();
      default:
        return sampleActivityLogs;
    }
  }

  void _showTodo(String message) {
    if (!mounted) return;
    showInfoPopup(context, message);
  }

  void _showError(String message) {
    if (!mounted) return;
    showErrorPopup(context, message);
  }

  Future<void> _handleAnalyze() async {
    // WAJIB ada lahan dulu. Jangan buka kamera/upload kalau id kosong.
    final idLahan = (widget.land.id ?? '').trim();
    if (idLahan.isEmpty) {
      _showError('Pilih/buka lahan dulu sebelum scan agar foto tidak terbuang.');
      return;
    }
    final source = _imageSource == 0 ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _isDone = false;
    });

    try {
      await uploadScan(
        file: pickedFile,
        idLahan: idLahan,
        bagianTanaman: _selectedOrgan == 'leaf' ? 'daun' : 'buah',
      );

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _isDone = true;
      });

      // Arahkan ke hasil lengkap (bisa passing hasil dari API nanti)
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _isDone = false);
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HasilScanTidakSehatPage()),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _isDone = false;
      });
      _showError('Gagal analisis: ${pesanError(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabSelector(),
          Expanded(
            child: switch (_tabIndex) {
              0 => _buildScanTab(),
              1 => TabJadwal(idLahan: _land.id ?? ''),
              _ => _buildRiwayatTab(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _buildScanPlotCard(),
        const SizedBox(height: 14),
        _buildScanResultCard(),
        const SizedBox(height: 14),
        _buildScanTelemetryCard(),
        const SizedBox(height: 20),
        _buildScanSectionLabel(
          'Pindai Ulang',
          'Tentukan organ dan sumber citra sebelum menganalisis',
        ),
        const SizedBox(height: 10),
        _buildOrganSelector(),
        const SizedBox(height: 16),
        _buildScanSectionLabel('Sumber Citra', null),
        const SizedBox(height: 10),
        _buildSourceSelector(),
        const SizedBox(height: 16),
        _buildViewfinder(),
        const SizedBox(height: 14),
        _buildAiTip(),
        const SizedBox(height: 14),
        _buildAnalyzeButton(),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HasilScanTidakSehatPage()),
          ),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Lihat Hasil Diagnosis Lengkap'),
        ),
      ],
    );
  }

  Widget _buildScanSectionLabel(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.title(context)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: AppText.bodySm(context)),
        ],
      ],
    );
  }

  Widget _buildOrganSelector() {
    return Row(
      children: [
        Expanded(
          child: _organCard(
            type: 'leaf',
            title: 'Daun Tanaman',
            subtitle: 'Bercak, kutu & tungau',
            icon: Icons.eco_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _organCard(
            type: 'fruit',
            title: 'Buah Cabai',
            subtitle: 'Antraknosa & busuk buah',
            icon: Icons.restaurant_rounded,
          ),
        ),
      ],
    );
  }

  Widget _organCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedOrgan == type;
    final p = context.palette;
    return InkWell(
      onTap: () => setState(() => _selectedOrgan = type),
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? p.surface : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          border: Border.all(
            color: selected ? p.primary : p.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected ? p.accentSoft : p.surface,
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: selected ? p.primary : p.icon,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? p.primary : p.surfaceAlt,
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 14, color: p.onPrimary)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: AppText.subtitle(context)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Row(
      children: [
        Expanded(
          child: _sourceCard(
            index: 0,
            icon: Icons.photo_camera_rounded,
            label: 'Kamera Langsung',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _sourceCard(
            index: 1,
            icon: Icons.photo_library_rounded,
            label: 'Ambil Galeri',
          ),
        ),
      ],
    );
  }

  Widget _sourceCard({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _imageSource == index;
    final p = context.palette;
    return InkWell(
      onTap: () => setState(() => _imageSource = index),
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? p.surface : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          border: Border.all(
            color: selected ? p.primary : p.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? p.primary : p.icon,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.body(
                context,
                color: selected ? p.primary : p.subtitle,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpace.radiusCard),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.inverseSurface,
                child: const Center(
                  child: Icon(
                    Icons.local_florist_rounded,
                    size: 96,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _glassBadge(
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI SCANNER AKTIF',
                                style: AppText.micro(
                                  context,
                                  color: Colors.white,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        _glassBadge(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.center_focus_strong_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AF Cepat',
                                style: AppText.micro(
                                  context,
                                  color: Colors.white,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryFixed,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: AppColors.primaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedOrgan == 'leaf'
                                ? 'Fokus: Daun Utama (94%)'
                                : 'Fokus: Buah Cabai (91%)',
                            style: AppText.micro(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _glassBadge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: AppColors.secondaryContainer,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arahkan ke pusat gejala bercak',
                            style: AppText.caption(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Row(
                children: [
                  _circleIconButton(Icons.flash_on_rounded),
                  const SizedBox(width: 6),
                  _circleIconButton(Icons.replay_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBadge({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
      child: child,
    );
  }

  Widget _circleIconButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.inverseSurface.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildAiTip() {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.accentSoft,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(
              Icons.verified_rounded,
              color: p.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketepatan AI Capsee 95.2%',
                  style: AppText.bodySm(
                    context,
                    color: p.title,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Jaga jarak kamera sekitar 10-15 cm dari permukaan helai daun.',
                  style: AppText.caption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final p = context.palette;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _handleAnalyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          ),
        ),
        child: _isAnalyzing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: p.onPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Memproses Citra Daun...'),
                ],
              )
            : _isDone
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Analisis Selesai'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Analisis dengan AI'),
                ],
              ),
      ),
    );
  }

  Widget _buildScanPlotCard() {
    final p = context.palette;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: p.accentSoft,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(
              Icons.local_florist_rounded,
              color: p.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petak Cabai Rawit Blok A',
                  style: AppText.subtitle(context),
                ),
                const SizedBox(height: 3),
                Text(
                  'Umur 3 Bulan • Fase Berbuah Aktif',
                  style: AppText.bodySm(context),
                ),
              ],
            ),
          ),
          const StatusBadge(label: 'Optimal', kind: BadgeKind.success),
        ],
      ),
    );
  }

  Widget _buildScanResultCard() {
    final p = context.palette;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: p.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Hasil Scan Terakhir',
                style: AppText.subtitle(context),
              ),
              const Spacer(),
              Text('09:41 WIB', style: AppText.caption(context)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.accentSoft,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanaman Sehat & Bebas Hama',
                  style: AppText.subtitle(
                    context,
                    color: p.onAccentSoft,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akurasi AI 98,6% • SPAD klorofil 94%',
                  style: AppText.bodySm(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '4 parameter normal terdeteksi',
            style: AppText.bodySm(context),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Bebas penyakit')),
              Chip(label: Text('Bebas kutu')),
              Chip(label: Text('Daun optimal')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanTelemetryCard() {
    final p = context.palette;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Cuaca Lapangan', style: AppText.subtitle(context)),
              const Spacer(),
              // Atribusi wajib BMKG
              Text(
                'Sumber: BMKG',
                style: AppText.micro(context, color: p.subtitle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_cuacaLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_cuacaError || _cuaca == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cuacaErrorMsg.isEmpty
                      ? 'Data cuaca tidak tersedia'
                      : _cuacaErrorMsg,
                  style: AppText.bodySm(context),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _loadCuaca,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba lagi'),
                ),
              ],
            )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScanMetric(
                    icon: Icons.thermostat,
                    label: 'Suhu',
                    value: '${_cuaca!['suhu'] ?? '--'}°C',
                  ),
                  _ScanMetric(
                    icon: Icons.water_drop,
                    label: 'Kelembapan',
                    value: '${_cuaca!['kelembapan'] ?? '--'}% RH',
                  ),
                  _ScanMetric(
                    icon: Icons.air,
                    label: 'Angin',
                    value: '${_cuaca!['kecepatan_angin']?.toStringAsFixed(0) ?? '--'} km/j',
                  ),
                ],
              ),
            if (!_cuacaLoading && !_cuacaError && _cuaca != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.wb_cloudy_outlined,
                    size: 14,
                    color: p.subtitle,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_cuaca!['cuaca'] ?? ''}'
                      '${(_cuaca!['kemungkinan_hujan'] == true) ? " • ⚠ Kemungkinan Hujan" : ""}',
                      style: AppText.caption(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
    );
  }

  // ---------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    final p = context.palette;
    return AppBar(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: p.border)),
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: p.title),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Detail Lahan ${_land.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.subtitle(context),
      ),
      actions: [
        IconButton(
          tooltip: 'Edit informasi lahan',
          onPressed: _openEditLahan,
          icon: Icon(Icons.edit_outlined, color: p.title),
        ),
        IconButton(
          tooltip: 'Hapus lahan',
          onPressed: _openHapusLahan,
          icon: Icon(Icons.delete_outline, color: p.error),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {
              // TODO: buka profil pengguna
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: p.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: p.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Segmented tab: Scan | Jadwal | Riwayat
  // ---------------------------------------------------------------
  Widget _buildTabSelector() {
    final p = context.palette;
    const tabs = [
      (Icons.center_focus_strong_outlined, 'Scan'),
      (Icons.event_note_outlined, 'Jadwal'),
      (Icons.history_rounded, 'Riwayat'),
    ];

    return Container(
      color: p.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _tabIndex == i
                          ? p.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].$1,
                          size: 17,
                          color: _tabIndex == i ? p.onPrimary : p.icon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tabs[i].$2,
                          style: AppText.body(
                            context,
                            color: _tabIndex == i
                                ? p.onPrimary
                                : p.subtitle,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tab "Riwayat"
  // ---------------------------------------------------------------
  Widget _buildRiwayatTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildLandHeaderCard(),
                const SizedBox(height: 14),
                _buildFilterChips(),
                const SizedBox(height: 14),
                _buildStatsCard(),
                const SizedBox(height: 20),
                _buildSectionTitle(),
                const SizedBox(height: 12),
                for (final log in _visibleLogs) ...[
                  _ActivityCard(log: log),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 6),
                _buildBottomActions(),
                const SizedBox(height: 14),
                _buildFooterNote(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Kartu identitas lahan: ikon, nama, status, umur/fase
  Widget _buildLandHeaderCard() {
    final land = _land;
    final p = context.palette;
    return CapseeCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 24,
              color: p.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        land.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const StatusBadge(
                      label: 'Optimal',
                      kind: BadgeKind.success,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Umur ${land.plantAgeMonths} Bln • '
                  '${plantPhaseLabels[land.plantAgeMonths] ?? '-'}',
                  style: AppText.bodySm(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip filter horizontal
  Widget _buildFilterChips() {
    final p = context.palette;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _filters[i];
          final selected = _filter == label;
          return GestureDetector(
            onTap: () => setState(() => _filter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? p.primary : p.surface,
                borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                border: Border.all(
                  color: selected ? p.primary : p.border,
                ),
              ),
              child: Text(
                label,
                style: AppText.body(
                  context,
                  color: selected ? p.onPrimary : p.subtitle,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  // Kartu ringkasan statistik
  Widget _buildStatsCard() {
    final p = context.palette;
    final counts = {
      for (final cat in ActivityCategory.values)
        cat: sampleActivityLogs.where((l) => l.category == cat).length,
    };

    return CapseeCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 18,
                color: p.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${sampleActivityLogs.length + 24} Catatan Terverifikasi',
                  style: AppText.subtitle(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                ),
                child: Text(
                  '30 Hari Terakhir',
                  style: AppText.micro(
                    context,
                    color: p.subtitle,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatColumn('${counts[ActivityCategory.scan]}', 'Scan AI'),
              _buildStatDivider(),
              _buildStatColumn(
                '${(counts[ActivityCategory.irrigation] ?? 0) * 8}',
                'Irigasi',
              ),
              _buildStatDivider(),
              _buildStatColumn(
                '${counts[ActivityCategory.fertilizer]}',
                'Pupuk',
              ),
              _buildStatDivider(),
              _buildStatColumn('${counts[ActivityCategory.alert]}', 'Tindakan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppText.headline(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption(context)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: context.palette.border,
    );
  }

  Widget _buildSectionTitle() {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Kronologi Aktivitas',
            style: AppText.title(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sensor Realtime',
                style: AppText.micro(
                  context,
                  color: p.subtitle,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tombol aksi bawah: Tambah Catatan + Ekspor Log
  Widget _buildBottomActions() {
    final p = context.palette;
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: proses ekspor log ke PDF/Excel
          _showTodo('Ekspor Log belum dibuat');
        },
        icon: const Icon(Icons.ios_share_rounded, size: 18),
        label: Text('Ekspor Log', style: AppText.subtitle(context)),
        style: OutlinedButton.styleFrom(
          foregroundColor: p.title,
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.shield_outlined, size: 14, color: p.icon),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Seluruh riwayat tercatat dan terenkripsi otomatis dengan '
            'sensor IoT kebun.',
            style: AppText.caption(context).copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------
/// Satu kartu pada Kronologi Aktivitas
/// ---------------------------------------------------------------
class _ActivityCard extends StatelessWidget {
  final ActivityLog log;
  const _ActivityCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = log.category.color;
    final softColor = log.category.softColor;

    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
            child: Icon(log.icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        log.badge,
                        style: AppText.caption(
                          context,
                          color: color,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.time,
                      style: AppText.micro(
                        context,
                        color: p.subtitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  log.title,
                  style: AppText.subtitle(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(log.description, style: AppText.body(context)),
                if (log.stats != null) ...[
                  const SizedBox(height: 10),
                  _StatsRow(items: log.stats!),
                ],
                if (log.photo != null) ...[
                  const SizedBox(height: 10),
                  _PhotoRow(photo: log.photo!),
                ],
                if (log.action != null) ...[
                  const SizedBox(height: 10),
                  _ActionRow(
                    action: log.action!,
                    onTap: log.category == ActivityCategory.alert
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TreatmentRecommendationScreen(),
                              ),
                            )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris chip statistik kecil, mis: "23°C  Lengas 74%  Otomatis"
class _StatsRow extends StatelessWidget {
  final List<StatItem> items;
  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 13, color: p.icon),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: AppText.caption(
                      context,
                      color: p.title,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ScanMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScanMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Icon(icon, color: p.primary, size: 20),
        const SizedBox(height: 4),
        Text(label, style: AppText.micro(context, color: p.subtitle)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppText.caption(
            context,
            color: p.title,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Footer berupa foto sampel + keterangan + tautan.
class _PhotoRow extends StatelessWidget {
  final PhotoResult photo;
  const _PhotoRow({required this.photo});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 20,
              color: p.icon,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.caption,
                  style: AppText.bodySm(
                    context,
                    color: p.title,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(photo.subtitle, style: AppText.caption(context)),
              ],
            ),
          ),
          Text(
            '${photo.linkLabel} →',
            style: AppText.bodySm(
              context,
              color: p.primary,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Footer berupa kartu hijau "tindakan selesai" + tautan.
class _ActionRow extends StatelessWidget {
  final ActionResult action;
  final VoidCallback? onTap;
  const _ActionRow({required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.accentSoft,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: p.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: AppText.bodySm(
                      context,
                      color: p.title,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    action.subtitle,
                    style: AppText.caption(context),
                  ),
                ],
              ),
            ),
            Text(
              '${action.linkLabel} →',
              style: AppText.bodySm(
                context,
                color: p.primary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
