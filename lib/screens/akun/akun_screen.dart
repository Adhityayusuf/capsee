// akun_screen.dart
//
// Versi yang mendukung mode terang & gelap: semua warna diambil dari
// `context.palette` (core/app_theme.dart), bukan konstanta `C` lagi.
//
// Pemakaian: home: const AkunScreen()

import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';
import '../auth/login_screen.dart';
import '../bantuan/bantuan_faq_screen.dart';
import '../legal/privasi_screen.dart';
import '../legal/syarat_screen.dart';
import 'edit_profil_screen.dart';
import 'ubah_sandi.dart';
import '../../services/services.dart';

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
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

// ─────────────────────────── Layar ───────────────────────────
class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final profil = await getProfil();
      if (mounted) {
        setState(() {
          _profil = profil;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_MenuItem> _getAccountItems(BuildContext context) {
    final p = context.palette;
    return [
      _MenuItem(
        icon: Icons.badge_outlined,
        iconColor: p.accent,
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
        iconColor: p.accent,
        title: 'Ubah Kata Sandi',
        subtitle: 'Kelola keamanan dan pembaruan sandi akun',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UbahKataSandiScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.tune,
        iconColor: p.accent,
        title: 'Notifikasi & Sensor Lapangan',
        subtitle: 'Preferensi peringatan cuaca BMKG dan irigasi',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengaturan notifikasi mengikuti data BMKG per lahan.'),
            ),
          );
        },
      ),
    ];
  }

  List<_MenuItem> _getHelpItems(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      _MenuItem(
        icon: Icons.menu_book,
        // Biru lebih terang di mode gelap supaya tetap terbaca
        iconColor: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF005B8C),
        title: 'Panduan & FAQ Petani',
        subtitle: 'Solusi penyakit cabai, dosis pupuk, & tutorial',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BantuanFaqScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.verified_user_outlined,
        iconColor: p.icon,
        title: 'Syarat dan Ketentuan',
        subtitle: 'Ketentuan layanan aplikasi',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SyaratScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        iconColor: p.icon,
        title: 'Kebijakan Privasi',
        subtitle: 'Privasi data agrikultur Anda',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivasiScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.info_outline,
        iconColor: p.icon,
        title: 'Tentang Aplikasi',
        subtitle: 'Capsee v2.4.0 • AI-Powered Precision Agriculture',
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'Capsee',
            applicationVersion: '2.4.0',
            applicationLegalese: 'AI-Powered Precision Agriculture',
          );
        },
      ),
    ];
  }

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

    return Scaffold(
      backgroundColor: p.background,
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
          _buildSection('Pengaturan Akun', 'Preferensi', p.subtitle,
              _getAccountItems(context)),
          const SizedBox(height: 24),
          _buildSection('Bantuan & Informasi', 'Dukungan Lapangan', p.accent,
              _getHelpItems(context)),
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
                  Image.network(
                    _kLogoUrl,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.eco, size: 20, color: p.accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROFIL & PENGATURAN',
                            style: _ts(10, 14, FontWeight.w700, p.accent,
                                letterSpacing: 1.0)),
                        Text('Akun Saya',
                            overflow: TextOverflow.ellipsis,
                            style: _ts(18, 24, FontWeight.w600, p.title)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
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
    final p = context.palette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      ],
    );
  }

  // ───────── Kartu profil ─────────
  Widget _buildProfileCard() {
    final p = context.palette;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: p.shadow,
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(0, 4)),
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
                    color: p.accentSoft,
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
                          Text(_profil?['nama'] ?? 'Pengguna',
                              overflow: TextOverflow.ellipsis,
                              style: _ts(18, 24, FontWeight.w600, p.title)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.eco, size: 15, color: p.accent),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Mitra Tani Cabai Rawit • Jawa Timur',
                                  overflow: TextOverflow.ellipsis,
                                  style: _ts(
                                      12, 16, FontWeight.w600, p.subtitle),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.surfaceAlt,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: p.accent,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text('Petani Komersial',
                                    style: _ts(10, 14, FontWeight.w600,
                                        p.subtitle)),
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
    final p = context.palette;

    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: Container(
                color: p.surfaceAlt,
                child: Image.network(
                  _kAvatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person, size: 32, color: p.icon),
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
                color: p.primary,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(Icons.photo_camera,
                        size: 13, color: p.onPrimary),
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
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
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
                    Icon(Icons.location_on, size: 18, color: p.accent),
                    const SizedBox(width: 8),
                    Text('Lahan Aktif',
                        style: _ts(12, 16, FontWeight.w600, p.subtitle)),
                  ],
                ),
              ),
              Text('2 Petak Terdaftar',
                  style: _ts(12, 16, FontWeight.w600, p.title)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.mail_outline, size: 18, color: p.icon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          _profil?['email'] ?? 'budi.santoso@agrimail.id',
                          overflow: TextOverflow.ellipsis,
                          style: _ts(12, 16, FontWeight.w400, p.subtitle)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, size: 16, color: p.accent),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 18, color: p.icon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_profil?['nomor_hp'] ?? '+62 812-3456-7890',
                          overflow: TextOverflow.ellipsis,
                          style: _ts(12, 16, FontWeight.w400, p.subtitle)),
                    ),
                  ],
                ),
              ),
              Text('Aktif WA', style: _ts(10, 14, FontWeight.w600, p.accent)),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── Banner sensor ─────────
  Widget _buildSensorBanner() {
    final p = context.palette;
    return Container(
    );
  }

  // ───────── Section menu ─────────
  Widget _buildSection(String title, String trailing, Color trailingColor,
      List<_MenuItem> items) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(),
                  style: _ts(10, 14, FontWeight.w700, p.icon,
                      letterSpacing: 1.0)),
              Text(trailing,
                  style: _ts(10, 14, FontWeight.w600, trailingColor)),
            ],
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: p.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 2)),
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
                    color: p.border,
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
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: p.error.withAlpha(isDark ? 40 : 26),
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
                Icon(Icons.logout, size: 20, color: p.error),
                const SizedBox(width: 8),
                Text('Keluar dari Akun',
                    style: _ts(14, 20, FontWeight.w700, p.error)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final p = context.palette;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('Keluar dari akun?',
            style: _ts(18, 24, FontWeight.w600, p.title)),
        content: Text('Anda perlu masuk lagi untuk memantau lahan.',
            style: _ts(14, 20, FontWeight.w400, p.subtitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: _ts(14, 20, FontWeight.w600, p.subtitle)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text('Keluar', style: _ts(14, 20, FontWeight.w700, p.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildInfo() {
    final p = context.palette;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_outlined, size: 16, color: p.icon),
            const SizedBox(width: 6),
            Text('CAPSEE PRECISION AGRI',
                style: _ts(10, 14, FontWeight.w600, p.icon,
                    letterSpacing: 1.0)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Versi 2.4.0 (Build 2024.11) • Sistem Terenkripsi',
          textAlign: TextAlign.center,
          style:
              _ts(12, 16, FontWeight.w400, p.subtitle.withValues(alpha: 0.8)),
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
    final p = context.palette;

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
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(14, 20, FontWeight.w600, p.title)),
                  Text(item.subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: _ts(12, 16, FontWeight.w400, p.subtitle)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: p.icon),
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