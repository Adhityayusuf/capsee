import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../models/activity_log.dart';
import '../../models/land_data.dart';
import '../scan/hasil_scan_tidak_sehat.dart';
import '../scan/treatment_recommendation_screen.dart';
import 'tab_jadwal.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/services.dart';

class LandDetailScreen extends StatefulWidget {
  final LandData land;
  const LandDetailScreen({super.key, required this.land});

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  int _tabIndex = 2; // 0=Scan, 1=Jadwal, 2=Riwayat (sesuai desain)
  String _filter = 'Semua Aktivitas';

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

  @override
  void initState() {
    super.initState();
    _loadCuaca();
  }

  Future<void> _loadCuaca() async {
    final idLahan = widget.land.id;
    if (idLahan == null || idLahan.isEmpty) {
      setState(() { _cuacaLoading = false; _cuacaError = true; });
      return;
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
        });
      }
    } catch (_) {
      if (mounted) setState(() { _cuacaLoading = false; _cuacaError = true; });
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAnalyze() async {
    final source = _imageSource == 0 ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _isDone = false;
    });

    try {
      final res = await uploadScan(
        file: File(pickedFile.path),
        idLahan: widget.land.id ?? '', 
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
      _showTodo('Gagal analisis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabSelector(),
          Expanded(
            child: switch (_tabIndex) {
              0 => _buildScanTab(),
              1 => const TabJadwal(),
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
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.subtitle,
            ),
          ),
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
    return InkWell(
      onTap: () => setState(() => _selectedOrgan = type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
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
                    color: selected ? AppColors.primarySoft : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: selected ? AppColors.primary : AppColors.icon,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : AppColors.chipBg,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.subtitle,
              ),
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
    return InkWell(
      onTap: () => setState(() => _imageSource = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.chipBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.icon,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primaryDark : AppColors.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
                              const Text(
                                'AI SCANNER AKTIF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _glassBadge(
                          child: const Row(
                            children: [
                              Icon(
                                Icons.center_focus_strong_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AF Cepat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _glassBadge(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_sunny_rounded,
                            color: AppColors.secondaryContainer,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Arahkan ke pusat gejala bercak',
                            style: TextStyle(color: Colors.white, fontSize: 11),
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
        borderRadius: BorderRadius.circular(20),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                Text(
                  'Jaga jarak kamera sekitar 10-15 cm dari permukaan helai daun.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _handleAnalyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isAnalyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
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
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Petak Cabai Rawit Blok A',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Umur 3 Bulan • Fase Berbuah Aktif',
                    style: TextStyle(color: AppColors.subtitle, fontSize: 12),
                  ),
                ],
              ),
            ),
            _statusPill('Optimal'),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hasil Scan Terakhir',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const Spacer(),
                Text(
                  '09:41 WIB',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanaman Sehat & Bebas Hama',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Akurasi AI 98,6% • SPAD klorofil 94%',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '4 parameter normal terdeteksi',
              style: TextStyle(fontSize: 12, color: AppColors.subtitle),
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
      ),
    );
  }

  Widget _buildScanTelemetryCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Cuaca Lapangan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                // Atribusi wajib BMKG
                const Text(
                  'Sumber: BMKG',
                  style: TextStyle(fontSize: 10, color: AppColors.subtitle),
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
              const Text(
                'Data cuaca tidak tersedia',
                style: TextStyle(fontSize: 12, color: AppColors.subtitle),
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
                  const Icon(Icons.wb_cloudy_outlined, size: 14, color: AppColors.subtitle),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_cuaca!['cuaca'] ?? ''}'  
                      '${(_cuaca!['kemungkinan_hujan'] == true) ? " • ⚠ Kemungkinan Hujan" : ""}',
                      style: const TextStyle(fontSize: 11, color: AppColors.subtitle),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // ---------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Detail Lahan ${widget.land.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.title,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {
              // TODO: buka profil pengguna
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: Colors.white,
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
    const tabs = [
      (Icons.center_focus_strong_outlined, 'Scan'),
      (Icons.event_note_outlined, 'Jadwal'),
      (Icons.history_rounded, 'Riwayat'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(12),
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
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].$1,
                          size: 17,
                          color: _tabIndex == i ? Colors.white : AppColors.icon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tabs[i].$2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _tabIndex == i
                                ? Colors.white
                                : AppColors.subtitle,
                          ),
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
    final land = widget.land;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 24,
              color: AppColors.primary,
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.title,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Optimal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Umur ${land.plantAgeMonths} Bln • '
                  '${plantPhaseLabels[land.plantAgeMonths] ?? '-'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.subtitle,
                  ),
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
                color: selected ? AppColors.primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primaryDark : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.subtitle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Kartu ringkasan statistik
  Widget _buildStatsCard() {
    final counts = {
      for (final cat in ActivityCategory.values)
        cat: sampleActivityLogs.where((l) => l.category == cat).length,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${sampleActivityLogs.length + 24} Catatan Terverifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '30 Hari Terakhir',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32, color: AppColors.border);
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Kronologi Aktivitas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sensor Realtime',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tombol aksi bawah: Tambah Catatan + Ekspor Log
  Widget _buildBottomActions() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: proses ekspor log ke PDF/Excel
          _showTodo('Ekspor Log belum dibuat');
        },
        icon: const Icon(Icons.ios_share_rounded, size: 18),
        label: Text(
          'Ekspor Log',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.title,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.shield_outlined, size: 14, color: AppColors.icon),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Seluruh riwayat tercatat dan terenkripsi otomatis dengan '
            'sensor IoT kebun.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.subtitle,
            ),
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
    final color = log.category.color;
    final softColor = log.category.softColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  log.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  log.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.subtitle,
                  ),
                ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 13, color: AppColors.icon),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.title,
                    ),
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
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.subtitle),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 20,
              color: AppColors.icon,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.caption,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
                Text(
                  photo.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${photo.linkLabel} →',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.title,
                    ),
                  ),
                  Text(
                    action.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${action.linkLabel} →',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
