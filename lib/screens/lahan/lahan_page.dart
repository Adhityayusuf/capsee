import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../models/land_data.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';
import 'detail_lahan_screen.dart';
import 'tambah_lahan_page.dart';

// ───────────────────────── Warna & Tema ─────────────────────────
class LahanColors {
  static const bg = Color(0xFFF8F7FD);
  static const primary = Color(0xFF0B5D45);
  static const primaryLight = Color(0xFFBDF0D6);
  static const softBlue = Color(0xFFE6EBFB);
  static const danger = Color(0xFFB3261E);
  static const dangerBg = Color(0xFFFFE3E0);
  static const warning = Color(0xFFFFB74D);
  static const text = Color(0xFF1B1B1F);
  static const textMuted = Color(0xFF5F6368);
  static const card = Colors.white;
}

// ───────────────────────── Model Data ─────────────────────────
enum PlotStatus { warning, healthy }

class Plot {
  final String name;
  final String block;
  final String crop;
  final String location;
  final String area;
  final int ageMonths;
  final int hst;
  final int score;
  final PlotStatus status;
  final String phase;
  final IconData? phaseIcon;
  final String? alertTitle;
  final String? alertDesc;
  final String? schedule;
  final bool irrigationActive;
  final Color imageColor;
  final IconData imageIcon;

  const Plot({
    required this.name,
    required this.block,
    required this.crop,
    required this.location,
    required this.area,
    required this.ageMonths,
    required this.hst,
    required this.score,
    required this.status,
    required this.phase,
    required this.imageColor,
    required this.imageIcon,
    this.phaseIcon,
    this.alertTitle,
    this.alertDesc,
    this.schedule,
    this.irrigationActive = false,
  });
}

const plots = <Plot>[
  Plot(
    name: 'Petak Cabai Rawit Blok A',
    block: 'BLOK HORTIKULTURA',
    crop: 'Cabai Rawit',
    location: 'Lembang, KBB',
    area: '800 m²',
    ageMonths: 3,
    hst: 45,
    score: 68,
    status: PlotStatus.warning,
    phase: 'Fase Berbunga',
    phaseIcon: Icons.spa_outlined,
    alertTitle: 'Waspada: Bercak Daun Cercospora',
    alertDesc:
        'Terdeteksi lesi 1.4cm di kluster barat. Risiko transmisi sedang.',
    schedule: 'Interval pupuk tiap 1 minggu.',
    imageColor: Color(0xFF4C8C3F),
    imageIcon: Icons.eco,
  ),
  Plot(
    name: 'Petak Cabai Keriting Blok B',
    block: 'Blok Selatan',
    crop: 'Cabai Keriting',
    location: 'Cisarua, KBB',
    area: '1.2 Ha',
    ageMonths: 4,
    hst: 70,
    score: 94,
    status: PlotStatus.healthy,
    phase: 'Sehat & Prima',
    schedule: 'Jadwal pemupukan KCL tiap 2 minggu.',
    imageColor: Color(0xFFC0392B),
    imageIcon: Icons.local_fire_department,
  ),
  Plot(
    name: 'Petak Cabai Rawit Hibrida C',
    block: 'Blok Timur',
    crop: 'Cabai Rawit Hibrida',
    location: 'Parongpong, KBB',
    area: '400 m²',
    ageMonths: 1,
    hst: 15,
    score: 91,
    status: PlotStatus.healthy,
    phase: 'Vegetatif Awal',
    irrigationActive: true,
    schedule: 'Irigasi tetes & semprot nutrisi rutin.',
    imageColor: Color(0xFF8D6E4A),
    imageIcon: Icons.grass,
  ),
];

// ───────────────────────── Halaman Utama ─────────────────────────
class LahanPage extends StatefulWidget {
  const LahanPage({super.key});

  @override
  State<LahanPage> createState() => _LahanPageState();
}

class _LahanPageState extends State<LahanPage> {
  int _filter = 0; // 0 semua, 1 perlu tindakan, 2 sehat, 3 dst
  String _query = '';

  List<Map<String, dynamic>>? _lahanList;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final list = await getDaftarLahan();
      if (!mounted) return;
      setState(() {
        _lahanList = list;
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddLand() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TambahLahanPage()));
    // TambahLahanPage mengembalikan true jika simpan sukses.
    if (result == true && mounted) _load();
  }

  void _openDetail(Map<String, dynamic> land) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => LandDetailScreen(
              land: LandData(
                id: land['id'] as String?,
                name: (land['nama'] ?? 'Lahan').toString(),
                province: (land['provinsi'] ?? '').toString(),
                city: (land['kota'] ?? '').toString(),
                district: (land['kecamatan'] ?? '').toString(),
                plantAgeMonths:
                    (land['umur_tanaman_bulan'] as num?)?.toInt() ?? 1,
                lastWatered:
                    DateTime.tryParse(
                      (land['tanggal_terakhir_siram'] ?? '').toString(),
                    ) ??
                    DateTime.now(),
                lastFertilized:
                    DateTime.tryParse(
                      (land['tanggal_terakhir_pupuk'] ?? '').toString(),
                    ) ??
                    DateTime.now(),
                fertilizeIntervalWeeks:
                    (land['interval_pupuk_minggu'] as num?)?.toInt() ?? 1,
                wateringIntervalWeeks:
                    (land['interval_siram_minggu'] as num?)?.toInt() ?? 1,
              ),
            ),
          ),
        )
        .then((_) => _load());
  }

  Future<void> _openEdit(Map<String, dynamic> land) async {
    final id = (land['id'] ?? '').toString();
    if (id.isEmpty) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TambahLahanPage(
          idLahan: id,
          initial: LandData(
            id: id,
            name: (land['nama'] ?? '').toString(),
            province: (land['provinsi'] ?? '').toString(),
            city: (land['kota'] ?? '').toString(),
            district: (land['kecamatan'] ?? '').toString(),
            plantAgeMonths: (land['umur_tanaman_bulan'] as num?)?.toInt() ?? 1,
            lastWatered:
                DateTime.tryParse(
                  (land['tanggal_terakhir_siram'] ?? '').toString(),
                ) ??
                DateTime.now(),
            lastFertilized:
                DateTime.tryParse(
                  (land['tanggal_terakhir_pupuk'] ?? '').toString(),
                ) ??
                DateTime.now(),
            fertilizeIntervalWeeks:
                (land['interval_pupuk_minggu'] as num?)?.toInt() ?? 1,
            wateringIntervalWeeks:
                (land['interval_siram_minggu'] as num?)?.toInt() ?? 1,
          ),
        ),
      ),
    );
    if (result == true && mounted) _load();
  }

  Future<void> _hapus(Map<String, dynamic> land) async {
    final id = (land['id'] ?? '').toString();
    if (id.isEmpty) return;
    final p = context.palette;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Lahan?', style: AppText.title(ctx)),
        content: Text(
          'Lahan "${land['nama']}" beserta jadwal dan riwayatnya akan dihapus permanen.',
          style: AppText.body(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await hapusLahan(id);
      if (!mounted) return;
      showSuccessPopup(context, 'Lahan dihapus.');
      _load();
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menghapus: ${pesanError(e)}');
    }
  }

  List<Map<String, dynamic>> get _filteredReal {
    final list = _lahanList ?? [];
    final q = _query.toLowerCase();
    return list.where((e) {
      final matchFilter = switch (_filter) {
        1 => (e['status_kesehatan'] ?? '') == 'tidak_sehat',
        2 => (e['status_kesehatan'] ?? '') == 'sehat',
        _ => true,
      };
      if (!matchFilter) return false;
      if (q.isEmpty) return true;
      final nama = ((e['nama'] ?? '') as Object).toString().toLowerCase();
      final kec = ((e['kecamatan'] ?? '') as Object).toString().toLowerCase();
      final kota = ((e['kota'] ?? '') as Object).toString().toLowerCase();
      return nama.contains(q) || kec.contains(q) || kota.contains(q);
    }).toList();
  }

  List<Plot> get _filtered {
    return plots.where((p) {
      final matchFilter = switch (_filter) {
        1 => p.status == PlotStatus.warning,
        2 => p.status == PlotStatus.healthy,
        _ => true,
      };
      final q = _query.toLowerCase();
      final matchQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.block.toLowerCase().contains(q) ||
          p.crop.toLowerCase().contains(q);
      return matchFilter && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final real = _filteredReal;
    final dummy = _filtered;
    final useReal = _lahanList != null;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _LahanHeader(
              palette: p,
              onAdd: _openAddLand,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    _LahanCountRow(
                      palette: p,
                      countText: useReal
                          ? '${real.length} Petak Aktif'
                          : '${dummy.length} Petak (Contoh)',
                    ),
                    const SizedBox(height: 18),
                    _SearchField(
                      palette: p,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 14),
                    _FilterChips(
                      palette: p,
                      selected: _filter,
                      onSelected: (i) => setState(() => _filter = i),
                      totalLabel: useReal
                          ? 'Semua Petak (${_lahanList!.length})'
                          : 'Semua Petak (${dummy.length})',
                      warningLabel: useReal
                          ? 'Perlu Tindakan (${_lahanList!.where((e) => (e['status_kesehatan'] ?? '') == 'tidak_sehat').length})'
                          : 'Perlu Tindakan (1)',
                      healthyLabel: useReal
                          ? 'Sehat (${_lahanList!.where((e) => (e['status_kesehatan'] ?? '') == 'sehat').length})'
                          : 'Sehat (2)',
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null && (_lahanList == null || _lahanList!.isEmpty)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Gagal memuat lahan: $_error',
                          style: AppText.bodySm(context, color: p.error),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Muat ulang'),
                      ),
                      const SizedBox(height: 16),
                      for (final d in dummy) ...[
                        _PlotListCard(plot: d, palette: context.palette),
                        const SizedBox(height: 16),
                      ],
                    ] else if (useReal && real.isEmpty)
                      EmptyState(
                        icon: Icons.eco_outlined,
                        title: 'Belum ada lahan.',
                        message: 'Tambah lahan pertama Anda untuk mulai '
                            'memantau kebun.',
                        actionLabel: 'Tambah Lahan',
                        onAction: _openAddLand,
                      )
                    else if (useReal) ...[
                      for (final land in real) ...[
                        _RealLahanCard(
                          land: land,
                          palette: context.palette,
                          onDetail: () => _openDetail(land),
                          onEdit: () => _openEdit(land),
                          onDelete: () => _hapus(land),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ] else ...[
                      if (dummy.isEmpty)
                        EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Petak tidak ditemukan',
                          message: 'Coba kata kunci atau filter lain.',
                        ),
                      for (final d in dummy) ...[
                        _PlotListCard(plot: d, palette: context.palette),
                        const SizedBox(height: 16),
                      ],
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealLahanCard extends StatelessWidget {
  final Map<String, dynamic> land;
  final AppPalette palette;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RealLahanCard({
    required this.land,
    required this.palette,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nama = (land['nama'] ?? 'Lahan').toString();
    final lokasi =
        '${land['kecamatan'] ?? ''}, ${land['kota'] ?? ''}'.trim();
    final umur = (land['umur_tanaman_bulan'] ?? '-').toString();
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                ),
                child: Icon(
                  Icons.eco,
                  color: palette.accent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$lokasi\nUmur $umur Bulan',
                      style: AppText.bodySm(context).copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Tooltip(
                    message: 'Edit $nama',
                    child: Material(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                        onTap: onEdit,
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.edit_rounded,
                            color: palette.icon,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Tooltip(
                    message: 'Hapus $nama',
                    child: Material(
                      color: palette.error.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                        onTap: onDelete,
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: palette.error,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.title,
                    side: BorderSide(color: palette.border),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                    ),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 19),
                  label: const Text('Buka'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Header (1 baris, ikut gaya Dashboard) ─────────────────────────
class _LahanHeader extends StatelessWidget {
  final AppPalette p;
  final VoidCallback onAdd;

  const _LahanHeader({required AppPalette palette, required this.onAdd})
      : p = palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpace.page, 12, AppSpace.page, 12),
      decoration: BoxDecoration(
        color: p.surface,
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.eco_rounded, color: p.onPrimary, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAPSEE', style: AppText.overline(context, color: p.accent)),
                Text('Lahan', style: AppText.headline(context)),
              ],
            ),
          ),
          _CircleButton(
            icon: Icons.add,
            bg: p.primary,
            fg: p.onPrimary,
            tooltip: 'Tambah lahan',
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Baris jumlah petak ─────────────────────────
class _LahanCountRow extends StatelessWidget {
  final AppPalette palette;
  final String countText;

  const _LahanCountRow({required this.palette, required this.countText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: palette.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(countText, style: AppText.bodySm(context)),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final String? tooltip;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.size = 46,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: fg, size: 24),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Search & Filter ─────────────────────────
class _SearchField extends StatelessWidget {
  final AppPalette palette;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.palette, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppText.body(context, color: palette.title),
        decoration: InputDecoration(
          hintText: 'Cari nama petak atau lokasi...',
          hintStyle: AppText.bodySm(context, color: palette.hint),
          prefixIcon: Icon(Icons.search, color: palette.icon),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final AppPalette palette;
  final int selected;
  final ValueChanged<int> onSelected;
  final String totalLabel;
  final String warningLabel;
  final String healthyLabel;
  const _FilterChips({
    required this.palette,
    required this.selected,
    required this.onSelected,
    this.totalLabel = 'Semua Petak',
    this.warningLabel = 'Perlu Tindakan',
    this.healthyLabel = 'Sehat',
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData?, Color, Color)>[
      (totalLabel, null, palette.primary, palette.onPrimary),
      (
        warningLabel,
        Icons.warning_amber_rounded,
        palette.error.withValues(alpha: 0.12),
        palette.error,
      ),
      (healthyLabel, null, palette.surface, palette.title),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected == i
                      ? items[i].$3
                      : (i == 1 ? items[i].$3 : palette.surface),
                  borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                  border: Border.all(
                    color: selected == i ? Colors.transparent : palette.border,
                  ),
                ),
                child: Row(
                  children: [
                    if (items[i].$2 != null) ...[
                      Icon(items[i].$2, size: 16, color: items[i].$4),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      items[i].$1,
                      style: AppText.subtitle(
                        context,
                        color: selected == i || i == 1
                            ? items[i].$4
                            : palette.title,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Kartu Petak ─────────────────────────
class _PlotListCard extends StatelessWidget {
  final Plot plot;
  final AppPalette palette;

  const _PlotListCard({required this.plot, required this.palette});

  @override
  Widget build(BuildContext context) {
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                ),
                child: Icon(plot.imageIcon, color: palette.accent, size: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.block.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.overline(
                        context,
                        color: palette.accent,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plot.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title(context).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plot.location}\n${plot.ageMonths} Bulan (${plot.hst} HST)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySm(context).copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  _PlotActionButton(
                    icon: Icons.edit_rounded,
                    background: palette.surfaceAlt,
                    foreground: palette.icon,
                    tooltip: 'Edit ${plot.name}',
                  ),
                  const SizedBox(height: 6),
                  _PlotActionButton(
                    icon: Icons.delete_outline_rounded,
                    background: palette.error.withValues(alpha: 0.12),
                    foreground: palette.error,
                    tooltip: 'Hapus ${plot.name}',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sedang Dipantau',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      context,
                      color: palette.onAccentSoft,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data Tersinkronisasi',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(
                      context,
                      color: palette.onAccentSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (plot.schedule != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    color: palette.accent,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      plot.schedule!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySm(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.title,
                    side: BorderSide(color: palette.border),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                    ),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                    ),
                  ),
                  icon: const Icon(Icons.photo_camera_outlined, size: 19),
                  label: const Text('Scan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlotActionButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final String tooltip;

  const _PlotActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          onTap: () {},
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: foreground, size: 20),
          ),
        ),
      ),
    );
  }
}

class PlotCard extends StatelessWidget {
  final Plot plot;
  const PlotCard({super.key, required this.plot});

  @override
  Widget build(BuildContext context) {
    final isWarning = plot.status == PlotStatus.warning;
    final p = context.palette;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: gambar, nama, skor
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                child: Container(
                  width: 56,
                  height: 56,
                  color: plot.imageColor.withValues(alpha: 0.85),
                  child: Icon(plot.imageIcon, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(plot.name, style: AppText.display(context)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            plot.block,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.subtitle(context, color: p.subtitle),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(plot.crop, style: AppText.body(context)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${plot.score}%',
                    style: AppText.headline(
                      context,
                      color: isWarning
                          ? const Color(0xFF8A4B00)
                          : p.primary,
                    ),
                  ),
                  Text('Skor Vitalitas', style: AppText.bodySm(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Info baris: luas, HST, fase
          Wrap(
            spacing: 18,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoItem(icon: Icons.crop_free, text: plot.area),
              _InfoItem(
                icon: Icons.calendar_today_outlined,
                text: '${plot.hst} HST',
              ),
              if (isWarning)
                _InfoItem(icon: plot.phaseIcon!, text: plot.phase)
              else
                StatusBadge(label: plot.phase, kind: BadgeKind.success),
            ],
          ),
          const SizedBox(height: 14),

          // Konten khusus tiap status
          if (plot.alertTitle != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.error_outline,
                      size: 18,
                      color: p.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.alertTitle!,
                          style: AppText.subtitle(
                            context,
                            color: p.error,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plot.alertDesc!,
                          style: AppText.body(context, color: p.title),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    icon: Icons.medical_services_outlined,
                    label: 'Rekomendasi',
                    bg: p.error.withValues(alpha: 0.12),
                    fg: p.error,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    icon: Icons.visibility_outlined,
                    label: 'Detail Petak',
                    bg: p.surfaceAlt,
                    fg: p.title,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],

          if (plot.schedule != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Row(
                children: [
                  Icon(Icons.alarm, size: 20, color: p.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plot.schedule!,
                      style: AppText.body(context, color: p.title),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: p.subtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: p.surfaceAlt,
                  foregroundColor: p.title,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kelola Perawatan & Sensor',
                      style: AppText.subtitle(context),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],

          if (plot.irrigationActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water, size: 18, color: p.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Irigasi Tetes Aktif',
                      style: AppText.body(
                        context,
                        color: p.accent,
                      ).copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: p.surfaceAlt,
                    foregroundColor: p.title,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('Detail Petak', style: AppText.subtitle(context)),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: p.subtitle),
        const SizedBox(width: 6),
        Text(text, style: AppText.body(context, color: p.title)),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpace.radiusPill),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppText.subtitle(context, color: fg)),
      ),
    );
  }
}

// ───────────────────────── Card Dasar ─────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final AppPalette? palette;

  const _Card({required this.child, this.palette});

  @override
  Widget build(BuildContext context) {
    return CapseeCard(child: child);
  }
}
