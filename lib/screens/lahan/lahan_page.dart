import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
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

  Future<void> _openAddLand() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TambahLahanPage()));
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
    final list = _filtered;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(p: p),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _HeaderSection(
                    palette: p,
                    onAdd: _openAddLand,
                    onFilter: () => setState(() => _filter = (_filter + 1) % 3),
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
                  ),
                  const SizedBox(height: 18),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Petak tidak ditemukan',
                          style: TextStyle(color: p.subtitle),
                        ),
                      ),
                    ),
                  for (final p in list) ...[
                    _PlotListCard(plot: p, palette: context.palette),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Top Bar ─────────────────────────
class _TopBar extends StatelessWidget {
  final AppPalette p;

  const _TopBar({required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_florist_outlined, color: p.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOTANIKA AGRONOMI',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: p.subtitle,
                  ),
                ),
                Text(
                  'Lahan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: p.title,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Header Section ─────────────────────────
class _HeaderSection extends StatelessWidget {
  final AppPalette palette;
  final VoidCallback onAdd;
  final VoidCallback onFilter;

  const _HeaderSection({
    required this.palette,
    required this.onAdd,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 3.5,
                    backgroundColor: LahanColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AGRONOMI LAPANGAN',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      color: palette.subtitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Lahan Pertanian',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: palette.title,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '3 Petak Aktif  •  Total 2.4 Ha',
                style: TextStyle(fontSize: 12, color: palette.subtitle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _CircleButton(
          icon: Icons.add,
          bg: palette.primary,
          fg: palette.onPrimary,
          tooltip: 'Tambah lahan',
          onTap: onAdd,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: palette.title),
        decoration: InputDecoration(
          hintText: 'Cari nama petak atau lokasi...',
          hintStyle: TextStyle(color: palette.hint),
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
  const _FilterChips({
    required this.palette,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = <(String, IconData?, Color, Color)>[
      ('Semua Petak (3)', null, palette.primary, palette.onPrimary),
      (
        'Perlu Tindakan (1)',
        Icons.warning_amber_rounded,
        isDark ? const Color(0xFF492621) : LahanColors.dangerBg,
        palette.error,
      ),
      ('Sehat (2)', null, palette.surface, palette.title),
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
                  borderRadius: BorderRadius.circular(22),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected == i || i == 1
                            ? items[i].$4
                            : palette.title,
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _Card(
      palette: palette,
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
                  borderRadius: BorderRadius.circular(14),
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
                      style: TextStyle(
                        color: palette.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      plot.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.title,
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plot.location}\n${plot.ageMonths} Bulan (${plot.hst} HST)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.subtitle,
                        fontSize: 12,
                        height: 1.35,
                      ),
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
                    background: isDark
                        ? const Color(0xFF492621)
                        : const Color(0xFFFFE9E7),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sedang Dipantau',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.onAccentSoft,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data Tersinkronisasi',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.onAccentSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
                borderRadius: BorderRadius.circular(10),
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
                      style: TextStyle(color: palette.subtitle, fontSize: 12),
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
                      borderRadius: BorderRadius.circular(14),
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
                      borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
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

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: gambar, nama, skor
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                        Text(
                          plot.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            plot.block,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: LahanColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plot.crop,
                      style: const TextStyle(
                        fontSize: 14,
                        color: LahanColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${plot.score}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isWarning
                          ? const Color(0xFF8A4B00)
                          : LahanColors.primary,
                    ),
                  ),
                  const Text(
                    'Skor Vitalitas',
                    style: TextStyle(
                      fontSize: 12,
                      color: LahanColors.textMuted,
                    ),
                  ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: LahanColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plot.phase,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LahanColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Konten khusus tiap status
          if (plot.alertTitle != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LahanColors.dangerBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.error_outline,
                      size: 18,
                      color: LahanColors.danger,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.alertTitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: LahanColors.danger,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plot.alertDesc!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5C3B38),
                          ),
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
                    bg: const Color(0xFFFFCFCB),
                    fg: LahanColors.danger,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    icon: Icons.visibility_outlined,
                    label: 'Detail Petak',
                    bg: LahanColors.softBlue,
                    fg: LahanColors.text,
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
                color: LahanColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 20, color: LahanColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plot.schedule!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: LahanColors.textMuted,
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
                  backgroundColor: LahanColors.softBlue,
                  foregroundColor: LahanColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Kelola Perawatan & Sensor',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
                  children: const [
                    Icon(Icons.water, size: 18, color: LahanColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Irigasi Tetes Aktif',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: LahanColors.primary,
                      ),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: LahanColors.softBlue,
                    foregroundColor: LahanColors.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Detail Petak',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: LahanColors.textMuted),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
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
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    final p = palette ?? context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
