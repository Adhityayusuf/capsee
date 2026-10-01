// notifikasi_screen.dart
//
// Dependensi (pubspec.yaml):
//   dependencies:
//     flutter:
//       sdk: flutter
//     google_fonts: ^6.2.1
//
// Jalankan: taruh file ini di lib/ lalu panggil runApp(const CapseeApp()).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const CapseeApp());

// ─────────────────────────── Warna (Material 3 token) ───────────────────────────
class C {
  static const surface = Color(0xFFFAF8FF);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceHigh = Color(0xFFE2E7FF);
  static const surfaceHighest = Color(0xFFDAE2FD);
  static const onSurface = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF3F493F);
  static const outline = Color(0xFF6F7A6E);
  static const primary = Color(0xFF00652C);
  static const primaryContainer = Color(0xFF15803D);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFF95F8A7);
  static const primaryFixedDim = Color(0xFF79DB8D);
  static const onPrimaryFixed = Color(0xFF00210A);
  static const tertiary = Color(0xFF005B8C);
  static const tertiaryContainer = Color(0xFF0075B1);
  static const tertiaryFixed = Color(0xFFCCE5FF);
  static const onTertiaryFixedVariant = Color(0xFF004B73);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

// ─────────────────────────── Tipografi ───────────────────────────
TextStyle _t(double size, double height, FontWeight w, Color color,
        {double? letterSpacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
    );

class CapseeApp extends StatelessWidget {
  const CapseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capsee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: C.surface,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const NotifikasiScreen(),
    );
  }
}

// ─────────────────────────── Model ───────────────────────────
enum NotifType { reminder, weather, disease }

enum NotifGroup { today, earlier }

class NotifItem {
  final NotifType type;
  final NotifGroup group;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String badge;
  final Color badgeBg;
  final Color badgeFg;
  final String time;
  final Color dotColor;
  final String title;
  final String body;
  final String actionLabel;
  final IconData? actionIcon;
  final Color actionColor;
  final bool actionFilled;
  bool unread;
  bool confirmed;

  NotifItem({
    required this.type,
    required this.group,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badge,
    required this.badgeBg,
    required this.badgeFg,
    required this.time,
    required this.dotColor,
    required this.title,
    required this.body,
    required this.actionLabel,
    this.actionIcon,
    required this.actionColor,
    this.actionFilled = false,
    required this.unread,
    this.confirmed = false,
  });
}

// ─────────────────────────── Layar ───────────────────────────
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  NotifType? _selected; // null = Semua

  late final List<NotifItem> _items = [
    NotifItem(
      type: NotifType.weather,
      group: NotifGroup.today,
      icon: Icons.thunderstorm,
      iconBg: C.tertiaryFixed,
      iconColor: C.tertiary,
      badge: 'Peringatan Cuaca BMKG',
      badgeBg: C.tertiaryFixed.withOpacity(0.6),
      badgeFg: C.onTertiaryFixedVariant,
      time: '10 mnt lalu',
      dotColor: C.tertiary,
      title: 'Prediksi Hujan Lebat di Karangploso',
      body:
          'BMKG memperkirakan hujan lebat pukul 14:00 WIB. Jadwal penyiraman otomatis Petak Blok A dilewati untuk mencegah kelembapan berlebih.',
      actionLabel: 'Lihat Jadwal Siram',
      actionIcon: Icons.arrow_forward,
      actionColor: C.tertiary,
      unread: true,
    ),
    NotifItem(
      type: NotifType.reminder,
      group: NotifGroup.today,
      icon: Icons.water_drop,
      iconBg: C.surfaceHigh,
      iconColor: C.tertiaryContainer,
      badge: 'Jadwal Irigasi',
      badgeBg: C.surfaceContainer,
      badgeFg: C.tertiaryContainer,
      time: '1 jam lalu',
      dotColor: C.primaryContainer,
      title: 'Waktunya Penyiraman Pagi (Petak Rawit Blok B)',
      body:
          'Volume irigasi 1.2 L/m² disarankan sebelum pukul 08:30 WIB. Lengas tanah terkini 62%.',
      actionLabel: 'Konfirmasi Selesai',
      actionColor: C.onPrimary,
      actionFilled: true,
      unread: true,
    ),
    NotifItem(
      type: NotifType.reminder,
      group: NotifGroup.today,
      icon: Icons.document_scanner,
      iconBg: C.primaryFixed,
      iconColor: C.primary,
      badge: 'Evaluasi Tanaman AI',
      badgeBg: C.primaryFixedDim.withOpacity(0.3),
      badgeFg: C.primary,
      time: '3 jam lalu',
      dotColor: C.primaryContainer,
      title: 'Waktu Pindai Ulang: Petak Rawit Blok A',
      body:
          'Sudah 7 hari sejak diagnosa sehat terakhir. Pindai kembali daun utama untuk deteksi dini penyakit dan thrips.',
      actionLabel: 'Buka Kamera Scan',
      actionIcon: Icons.photo_camera,
      actionColor: C.primaryContainer,
      unread: true,
    ),
    NotifItem(
      type: NotifType.reminder,
      group: NotifGroup.earlier,
      icon: Icons.science,
      iconBg: C.surfaceHighest,
      iconColor: C.onSurfaceVariant,
      badge: 'Jadwal Nutrisi',
      badgeBg: C.surfaceHighest,
      badgeFg: C.onSurfaceVariant,
      time: 'Kemarin, 16:45',
      dotColor: C.primaryContainer,
      title: 'Jadwal Pemupukan NPK + Kalsium Nitrat',
      body:
          'Aplikasi kocor rutin fase berbuah aktif untuk Petak Rawit Blok A (Dosis: 5 gr/tanaman). Terjadwal hari ini.',
      actionLabel: 'Lihat Panduan Dosis',
      actionIcon: Icons.menu_book,
      actionColor: C.onSurfaceVariant,
      unread: false,
    ),
    NotifItem(
      type: NotifType.disease,
      group: NotifGroup.earlier,
      icon: Icons.warning,
      iconBg: C.errorContainer,
      iconColor: C.error,
      badge: 'Kewaspadaan Penyakit',
      badgeBg: C.errorContainer,
      badgeFg: C.onErrorContainer,
      time: '2 hari lalu (25 Okt)',
      dotColor: C.primaryContainer,
      title: 'Kelembapan Kanopi Tinggi Semalam (82%)',
      body:
          'Kondisi mikroklimat ideal bagi spora Cercospora. Pastikan aerasi kanopi lancar dan lakukan inspeksi daun bawah.',
      actionLabel: 'Protokol Pencegahan',
      actionIcon: Icons.shield,
      actionColor: C.onSurfaceVariant,
      unread: false,
    ),
  ];

  int get _unreadCount => _items.where((e) => e.unread).length;

  void _markAllRead() {
    setState(() {
      for (final e in _items) {
        e.unread = false;
      }
    });
  }

  List<NotifItem> _visible(NotifGroup g) => _items
      .where((e) => e.group == g && (_selected == null || e.type == _selected))
      .toList();

  @override
  Widget build(BuildContext context) {
    final today = _visible(NotifGroup.today);
    final earlier = _visible(NotifGroup.earlier);

    return Scaffold(
      backgroundColor: C.surface,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildStatusBar(),
          _buildChips(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (today.isNotEmpty)
                  _buildSection('Hari Ini', '26 Okt 2024', today),
                if (today.isNotEmpty && earlier.isNotEmpty)
                  const SizedBox(height: 24),
                if (earlier.isNotEmpty)
                  _buildSection('Kemarin & Sebelumnya', 'Riwayat Log', earlier),
                const SizedBox(height: 24),
                _buildTelemetryCard(),
                const SizedBox(height: 8),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Header ─────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: C.surface.withOpacity(0.95),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 1)),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: C.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        size: 22, color: C.primaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAPSEE',
                            style: _t(10, 14, FontWeight.w700, C.primary,
                                letterSpacing: 1.0)),
                        Text('Notifikasi',
                            style: _t(18, 24, FontWeight.w600, C.onSurface)),
                      ],
                    ),
                  ),
                  _roundIconButton(Icons.tune, 'Filter notifikasi', () {}),
                  const SizedBox(width: 6),
                  _roundIconButton(
                      Icons.done_all, 'Tandai semua dibaca', _markAllRead),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: C.onSurfaceVariant),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        shape: const CircleBorder(),
      ),
    );
  }

  // ───────── Bar status atas ─────────
  Widget _buildStatusBar() {
    final allRead = _unreadCount == 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: allRead
                        ? C.surfaceContainer
                        : C.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!allRead) ...[
                        const _PulseDot(color: C.primaryContainer),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        allRead ? 'Semua Sudah Dibaca' : '$_unreadCount Belum Dibaca',
                        style: _t(12, 16, FontWeight.w700, C.primaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('Pembaruan Lapangan',
                      overflow: TextOverflow.ellipsis,
                      style: _t(12, 16, FontWeight.w400, C.outline)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: allRead ? null : _markAllRead,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              allRead ? 'Selesai' : 'Tandai Selesai',
              style: _t(12, 16, FontWeight.w700, allRead ? C.outline : C.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Filter kategori ─────────
  Widget _buildChips() {
    final chips = <(String, NotifType?)>[
      ('Semua', null),
      ('Pengingat Rutin', NotifType.reminder),
      ('Peringatan Cuaca', NotifType.weather),
      ('Kesehatan Tanaman', NotifType.disease),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (label, type) = chips[i];
          final active = _selected == type;
          return GestureDetector(
            onTap: () => setState(() => _selected = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? C.primaryContainer : C.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? const [
                        BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: _t(12, 16, FontWeight.w600,
                    active ? C.onPrimary : C.onSurfaceVariant),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────── Section ─────────
  Widget _buildSection(String title, String trailing, List<NotifItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(),
                  style: _t(10, 14, FontWeight.w700, C.outline,
                      letterSpacing: 1.0)),
              Text(trailing, style: _t(10, 14, FontWeight.w700, C.outline)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < items.length; i++) ...[
          _buildCard(items[i]),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ───────── Kartu notifikasi ─────────
  Widget _buildCard(NotifItem n) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: n.unread ? 1.0 : 0.9,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.unread ? C.surfaceLowest : C.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(n.icon, size: 24, color: n.iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: n.badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            n.badge,
                            overflow: TextOverflow.ellipsis,
                            style: _t(10, 14, FontWeight.w600, n.badgeFg),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(n.time,
                              style: _t(12, 16, FontWeight.w400, C.outline)),
                          if (n.unread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: n.dotColor, shape: BoxShape.circle),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(18, 24, n.unread ? FontWeight.w700 : FontWeight.w600,
                        C.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12, 16, FontWeight.w400, C.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildAction(n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(NotifItem n) {
    if (n.actionFilled) {
      final done = n.confirmed;
      return Material(
        color: done ? C.outline.withOpacity(0.75) : C.primaryContainer,
        borderRadius: BorderRadius.circular(4),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: done ? null : () => setState(() => n.confirmed = true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              done ? 'Terselesaikan ✓' : n.actionLabel,
              style: _t(12, 16, FontWeight.w700, C.onPrimary),
            ),
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(n.actionLabel, style: _t(12, 16, FontWeight.w700, n.actionColor)),
            if (n.actionIcon != null) ...[
              const SizedBox(width: 4),
              Icon(n.actionIcon, size: 16, color: n.actionColor),
            ],
          ],
        ),
      ),
    );
  }

  // ───────── Kartu telemetri ─────────
  Widget _buildTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: C.surfaceLowest, shape: BoxShape.circle),
            child: const Icon(Icons.sensors, size: 20, color: C.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Lapangan Aktif',
                    style: _t(12, 16, FontWeight.w700, C.onSurface)),
                Text('3 stasiun IoT memantau petak 24/7',
                    style: _t(12, 16, FontWeight.w400, C.outline)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: C.primaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Sinkron',
                style: _t(10, 14, FontWeight.w700, C.onPrimaryFixed)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune, size: 18, color: C.outline),
          label: Text('Kelola Preferensi Notifikasi Lapangan',
              style: _t(12, 16, FontWeight.w600, C.outline)),
        ),
        Text('Capsee Intelligence Telemetry v2.4',
            style: _t(10, 14, FontWeight.w700, C.outline.withOpacity(0.7))),
        const SizedBox(height: 16),
      ],
    );
  }

}

// ─────────────────────────── Titik berdenyut (animate-pulse) ───────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.4).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
