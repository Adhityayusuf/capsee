// akun_screen.dart
//
// Memakai class warna `C` dari notifikasi_screen.dart (satu folder di lib/).
// Dependensi: google_fonts (sama seperti layar Notifikasi).
//
// Pemakaian: home: const AkunScreen()

import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:google_fonts/google_fonts.dart';

import 'notifikasi_screen.dart' show C;
import 'edit_profil_screen.dart';
import 'login_screen.dart';
import 'bantuan_faq_screen.dart';
import 'ubah_sandi.dart';

const String _kLogoUrl =
    'https://lh3.googleusercontent.com/aida/AEtjO1Xr_77lDlwa3ZADA-1HeBJZ-Tn0VWtE6n-7pOHm4d2azQUim5BjoLf575UzLtz0ODNUzEVcV30y0Qygv7t04JxHmpUwopBEQ96lDQ7I0bpin4-N1IS1l-FoVePayedbE5_okishN0kcXmjse5fCF-NG5aQpKrjWoygNzg2Vb2Qvga9t5r_iZu7cGKe9q8GulMspHO6C3lCzeGHgRcSPog9XdXtsBfBZsWTWU4MeoT564Ej-_JzkDExBIpo';

const String _kAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD9yzTTPbdLCm8UF7S10zskIXze-Iztg7iXPtN_yLtbjMgVJFf622RK8iDPg3zs34Zgmvzr-3eP0M69khUrRTVIl0PLCMmM1y1hVGB97EpVLHtlnm82aGyadJeOmtF02lZKnvK7D8cMX_Sn0t7eztxJ_iNnt56NrCCmKmtRo6I9dCrBdhvfcfKio97cfmdKq9alKshbFGQ7_2HuXJzF7laagR4yJ4pcrcc-tUfgWobAUXnQP6OqSeusdg';

TextStyle _ts(double size, double height, FontWeight w, Color color,
        {double? letterSpacing}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: w,
      color: color,
      letterSpacing: letterSpacing,
    );

// ─────────────────────────── Model menu ───────────────────────────
class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.onTap,
  });
}

// ─────────────────────────── Layar ───────────────────────────
class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  List<_MenuItem> _getAccountItems(BuildContext context) => [
    _MenuItem(
      icon: Icons.badge_outlined,
      iconColor: C.primary,
      title: 'Edit Profil',
      subtitle: 'Ubah identitas, foto profil, dan kontak lahan',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
    ),
    _MenuItem(
      icon: Icons.lock_reset,
      iconColor: C.primary,
      title: 'Ubah Kata Sandi',
      subtitle: 'Kelola keamanan dan pembaruan sandi akun',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UbahKataSandiScreen()),
        );
      },
    ),
    const _MenuItem(
      icon: Icons.tune,
      iconColor: C.primary,
      title: 'Notifikasi & Sensor Lapangan',
      subtitle: 'Preferensi peringatan cuaca BMKG dan irigasi',
    ),
  ];

  List<_MenuItem> _getHelpItems(BuildContext context) {
    return [
      _MenuItem(
        icon: Icons.menu_book,
        iconColor: C.tertiary,
        title: 'Panduan & FAQ Petani',
        subtitle: 'Solusi penyakit cabai, dosis pupuk, & tutorial',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BantuanFaqScreen()),
          );
        },
      ),
      const _MenuItem(
        icon: Icons.support_agent,
        iconColor: C.primary,
        title: 'Konsultasi Tim Ahli PPL',
        subtitle: 'Hubungi penyuluh pertanian lapangan resmi',
        badge: 'Tersedia',
      ),
      const _MenuItem(
        icon: Icons.verified_user_outlined,
        iconColor: C.onSurfaceVariant,
        title: 'Syarat dan Ketentuan',
        subtitle: 'Ketentuan layanan & privasi data agrikultur',
      ),
      const _MenuItem(
        icon: Icons.info_outline,
        iconColor: C.onSurfaceVariant,
        title: 'Tentang Aplikasi',
        subtitle: 'Capsee v2.4.0 • AI-Powered Precision Agriculture',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.surface,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildGreeting(),
          const SizedBox(height: 16),
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSensorBanner(),
          const SizedBox(height: 24),
          _buildSection('Pengaturan Akun', 'Preferensi', C.onSurfaceVariant,
              _getAccountItems(context)),
          const SizedBox(height: 24),
          _buildSection(
              'Bantuan & Informasi', 'Dukungan Lapangan', C.primary, _getHelpItems(context)),
          const SizedBox(height: 24),
          _buildLogout(context),
          const SizedBox(height: 24),
          _buildBuildInfo(),
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
                  Image.network(
                    _kLogoUrl,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: C.primaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco,
                          size: 20, color: C.primaryContainer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAPSEE AGRI',
                            style: _ts(10, 14, FontWeight.w700, C.primary,
                                letterSpacing: 1.0)),
                        Text('Akun',
                            overflow: TextOverflow.ellipsis,
                            style: _ts(18, 24, FontWeight.w600, C.onSurface)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Notifikasi',
                    icon: const Icon(Icons.notifications_outlined,
                        size: 22, color: C.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: C.primary, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.person, size: 18, color: C.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── Sapaan + badge terverifikasi ─────────
  Widget _buildGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROFIL & PENGATURAN',
                style: _ts(10, 14, FontWeight.w700, C.primary,
                    letterSpacing: 1.0)),
            Text('Akun Saya', style: _ts(22, 28, FontWeight.w700, C.onSurface)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6BFF8F).withOpacity(0.3),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 16, color: C.primary),
              const SizedBox(width: 6),
              Text('Terverifikasi',
                  style: _ts(10, 14, FontWeight.w700, C.primary)),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Kartu profil ─────────
  Widget _buildProfileCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: C.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F0F172A),
              blurRadius: 20,
              spreadRadius: -4,
              offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Aksen hijau samar di pojok kanan atas
          Positioned(
            top: -48,
            right: -48,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    color: C.primaryFixed.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budi Santoso',
                              overflow: TextOverflow.ellipsis,
                              style: _ts(18, 24, FontWeight.w600, C.onSurface)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.eco, size: 15, color: C.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Mitra Tani Cabai Rawit • Jawa Timur',
                                  overflow: TextOverflow.ellipsis,
                                  style: _ts(12, 16, FontWeight.w600,
                                      C.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: C.surfaceContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF006E2F),
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text('Petani Komersial',
                                    style: _ts(10, 14, FontWeight.w600,
                                        C.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildContactPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: Container(
                color: C.surfaceContainer,
                child: Image.network(
                  _kAvatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person,
                      size: 32, color: C.onSurfaceVariant),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Semantics(
              label: 'Ubah foto profil',
              button: true,
              child: Material(
                color: C.primary,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(Icons.photo_camera,
                        size: 13, color: C.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: C.surfaceLow.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: C.primary),
                    const SizedBox(width: 8),
                    Text('Lahan Aktif',
                        style:
                            _ts(12, 16, FontWeight.w600, C.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('2 Petak Terdaftar',
                  style: _ts(12, 16, FontWeight.w600, C.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline, size: 18, color: C.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('budi.santoso@agrimail.id',
                          overflow: TextOverflow.ellipsis,
                          style: _ts(
                              12, 16, FontWeight.w400, C.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, size: 16, color: C.primary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 18, color: C.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('+62 812-3456-7890',
                          overflow: TextOverflow.ellipsis,
                          style: _ts(
                              12, 16, FontWeight.w400, C.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              Text('Aktif WA', style: _ts(10, 14, FontWeight.w600, C.primary)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── Banner sensor ─────────
  Widget _buildSensorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: C.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 3,
                    offset: Offset(0, 1)),
              ],
            ),
            child: const Icon(Icons.sensors, size: 22, color: C.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Lapangan Aktif',
                    style: _ts(12, 16, FontWeight.w600, C.onSurface)),
                Text('Blok A (98%) • Blok B (100%)',
                    style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant)),
              ],
            ),
          ),
          const _PulseDot(color: Color(0xFF6BFF8F), size: 10),
        ],
      ),
    );
  }

  // ───────── Section menu ─────────
  Widget _buildSection(String title, String trailing, Color trailingColor,
      List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(),
                  style: _ts(10, 14, FontWeight.w700, C.outline,
                      letterSpacing: 1.0)),
              Text(trailing, style: _ts(10, 14, FontWeight.w600, trailingColor)),
            ],
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: C.surfaceLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _MenuTile(item: items[i]),
                if (i != items.length - 1)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: C.surfaceContainer.withOpacity(0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ───────── Tombol keluar ─────────
  Widget _buildLogout(BuildContext context) {
    return Material(
      color: C.errorContainer.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _confirmLogout(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20, color: C.error),
                const SizedBox(width: 8),
                Text('Keluar dari Akun',
                    style: _ts(14, 20, FontWeight.w700, C.error)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surfaceLowest,
        title: Text('Keluar dari akun?',
            style: _ts(18, 24, FontWeight.w600, C.onSurface)),
        content: Text('Anda perlu masuk lagi untuk memantau lahan.',
            style: _ts(14, 20, FontWeight.w400, C.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: _ts(14, 20, FontWeight.w600, C.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Keluar', style: _ts(14, 20, FontWeight.w700, C.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, size: 16, color: C.outline),
            const SizedBox(width: 6),
            Text('CAPSEE PRECISION AGRI',
                style: _ts(10, 14, FontWeight.w600, C.outline,
                    letterSpacing: 1.0)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Versi 2.4.0 (Build 2024.11) • Sistem Terenkripsi',
          textAlign: TextAlign.center,
          style: _ts(12, 16, FontWeight.w400,
              C.onSurfaceVariant.withOpacity(0.8)),
        ),
      ],
    );
  }

}

// ─────────────────────────── Item menu ───────────────────────────
class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: C.surfaceLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(item.title,
                            overflow: TextOverflow.ellipsis,
                            style: _ts(14, 20, FontWeight.w600, C.onSurface)),
                      ),
                      if (item.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(item.badge!,
                              style: _ts(10, 14, FontWeight.w700, C.primary)),
                        ),
                      ],
                    ],
                  ),
                  Text(item.subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(12, 16, FontWeight.w400, C.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: C.outline),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Titik berdenyut ───────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const _PulseDot({required this.color, this.size = 8});

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
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}