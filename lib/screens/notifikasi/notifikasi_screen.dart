// notifikasi_screen.dart
//
// Layar daftar notifikasi Capsee.
// Dependensi: google_fonts.

import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/ui_kit.dart';

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

  final String id;
  NotifItem({
    required this.id,
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

  bool _isLoading = true;
  List<NotifItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNotif();
  }

  Future<void> _loadNotif() async {
    setState(() => _isLoading = true);
    final p = context.palette;
    try {
      final data = await getDaftarNotifikasi();
      final List<NotifItem> mapped = data.map((n) {
        // Mapping sederhana dari backend ke NotifItem visual
        return NotifItem(
          id: n['id'],
          type: NotifType.reminder, // fallback
          group: NotifGroup.today, // fallback
          icon: Icons.notifications,
          iconBg: p.accentSoft,
          iconColor: p.primary,
          badge: n['kategori'] ?? 'Info',
          badgeBg: p.accentSoft.withValues(alpha: 0.3),
          badgeFg: p.onAccentSoft,
          time: 'Baru saja', // Ideally parse n['dibuat_pada']
          dotColor: p.primary,
          title: n['judul'] ?? '',
          body: n['pesan'] ?? '',
          actionLabel: 'Lihat Detail',
          actionColor: p.primary,
          unread: !(n['sudah_dibaca'] ?? false),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _items = mapped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _unreadCount => _items.where((e) => e.unread).length;

  Future<void> _markAllRead() async {
    for (final e in _items) {
      if (e.unread) {
        await tandaiDibaca(e.id);
      }
    }
    _loadNotif();
  }

  List<NotifItem> _visible(NotifGroup g) => _items
      .where((e) => e.group == g && (_selected == null || e.type == _selected))
      .toList();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final today = _visible(NotifGroup.today);
    final earlier = _visible(NotifGroup.earlier);

    return Scaffold(
      backgroundColor: p.background,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpace.gapXl),
        children: [
          _buildStatusBar(),
          _buildChips(),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpace.page),
              child: EmptyState(
                icon: Icons.notifications_outlined,
                title: 'Belum Ada Notifikasi',
                message:
                    'Sensor lapangan dan pengingat tani akan muncul di sini.',
              ),
            )
          else
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpace.page),
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
    final p = context.palette;
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
                color: p.shadow, blurRadius: 8, offset: const Offset(0, 1)),
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
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back_rounded,
                          size: 22, color: p.title),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: p.accentSoft,
                      borderRadius:
                          BorderRadius.circular(AppSpace.radiusTile),
                    ),
                    child: Icon(Icons.notifications_outlined,
                        size: 22, color: p.accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAPSEE',
                            style:
                                AppText.overline(context, color: p.accent)),
                        Text('Notifikasi',
                            style: AppText.headline(context)),
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
    final p = context.palette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: p.icon),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        shape: const CircleBorder(),
      ),
    );
  }

  // ───────── Bar status atas ─────────
  Widget _buildStatusBar() {
    final p = context.palette;
    final allRead = _unreadCount == 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.page, 8, AppSpace.page, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                StatusBadge(
                  label: allRead
                      ? 'Semua Sudah Dibaca'
                      : '$_unreadCount Belum Dibaca',
                  kind: allRead ? BadgeKind.info : BadgeKind.success,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('Pembaruan Lapangan',
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySm(context, color: p.icon)),
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
              style: AppText.bodySm(
                      context, color: allRead ? p.icon : p.primary)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── Filter kategori ─────────
  Widget _buildChips() {
    final p = context.palette;
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                color: active ? p.primary : p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: p.shadow,
                            blurRadius: 2,
                            offset: const Offset(0, 1))
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: AppText.bodySm(
                        context, color: active ? p.onPrimary : p.subtitle)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────── Section ─────────
  Widget _buildSection(String title, String trailing, List<NotifItem> items) {
    final isToday = title.toLowerCase().contains('hari');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          icon: isToday ? Icons.today_outlined : Icons.history_outlined,
          title: title,
          subtitle: trailing,
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
      child: CapseeCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.iconBg,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
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
                        child: StatusBadge(
                          label: n.badge,
                          kind: BadgeKind.info,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(n.time, style: AppText.bodySm(context)),
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
                    style: n.unread
                        ? AppText.headline(context)
                        : AppText.headline(context)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySm(context),
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
    final p = context.palette;
    if (n.actionFilled) {
      final done = n.confirmed;
      return Material(
        color: done ? p.icon.withValues(alpha: 0.75) : p.primary,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          onTap: done ? null : () => setState(() => n.confirmed = true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              done ? 'Terselesaikan ✓' : n.actionLabel,
              style: AppText.bodySm(context, color: p.onPrimary)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(n.actionLabel,
                style: AppText.bodySm(context, color: n.actionColor)
                    .copyWith(fontWeight: FontWeight.w700)),
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
    final p = context.palette;
    return CapseeCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: p.surface, shape: BoxShape.circle),
            child: Icon(Icons.sensors, size: 20, color: p.accent),
          ),
          const SizedBox(width: AppSpace.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Lapangan Aktif',
                    style: AppText.bodySm(context, color: p.title)
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('3 stasiun IoT memantau petak 24/7',
                    style: AppText.bodySm(context)),
              ],
            ),
          ),
          const StatusBadge(label: 'Sinkron', kind: BadgeKind.success),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final p = context.palette;
    return Column(
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.tune, size: 18, color: p.icon),
          label: Text('Kelola Preferensi Notifikasi Lapangan',
              style: AppText.bodySm(context, color: p.icon)
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
        Text('Capsee Intelligence Telemetry v2.4',
            style: AppText.micro(context,
                color: p.icon.withValues(alpha: 0.7))),
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
