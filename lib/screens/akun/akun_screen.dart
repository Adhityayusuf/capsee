// akun_screen.dart
//
// Versi yang mendukung mode terang & gelap: semua warna diambil dari
// `context.palette` (core/app_theme.dart), bukan konstanta `C` lagi.
//
// Pemakaian: home: const AkunScreen()

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/dashboard_style.dart';
import '../../core/font_scale_scope.dart';
import '../../core/theme_mode_scope.dart';
import '../../services/services.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/ui_kit.dart';
import '../auth/login_screen.dart';
import '../bantuan/bantuan_faq_screen.dart';
import '../legal/privasi_screen.dart';
import '../legal/syarat_screen.dart';
import 'edit_profil_screen.dart';
import 'ubah_sandi.dart';

const String _kAvatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD9yzTTPbdLCm8UF7S10zskIXze-Iztg7iXPtN_yLtbjMgVJFf622RK8iDPg3zs34Zgmvzr-3eP0M69khUrRTVIl0PLCMmM1y1hVGB97EpVLHtlnm82aGyadJeOmtF02lZKnvK7D8cMX_Sn0t7eztxJ_iNnt56NrCCmKmtRo6I9dCrBdhvfcfKio97cfmdKq9alKshbFGQ7_2HuXJzF7laagR4yJ4pcrcc-tUfgWobAUXnQP6OqSeusdg';

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
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _lokasiSingkat() {
    final kec = (_profil?['kecamatan'] ?? '').toString().trim();
    final kota = (_profil?['kota'] ?? '').toString().trim();
    final prov = (_profil?['provinsi'] ?? '').toString().trim();
    final bagian = [kec, kota].where((s) => s.isNotEmpty).join(', ');
    if (bagian.isEmpty) return prov.isEmpty ? 'Lokasi belum diisi' : prov;
    return prov.isEmpty ? bagian : '$bagian • $prov';
  }

  void _showAppearanceSettings(BuildContext context) {
    final p = context.palette;
    final themeScope = ThemeModeScope.maybeOf(context);
    final fontScope = FontScaleScope.maybeOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentMode = themeScope?.value ?? ThemeMode.light;
            final currentFont = fontScope?.value ?? AppFontSize.normal;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: p.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Pengaturan Tampilan', style: AppText.headline(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Sesuaikan tema dan kenyamanan membaca teks aplikasi.',
                      style: AppText.bodySm(context),
                    ),
                    const SizedBox(height: 20),

                    // Selector Tema
                    Text('TEMA APLIKASI', style: AppText.overline(context, color: p.icon)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeOptionChip(
                            label: 'Terang',
                            icon: Icons.light_mode_rounded,
                            isSelected: currentMode == ThemeMode.light,
                            onTap: () {
                              themeScope?.value = ThemeMode.light;
                              setModalState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ThemeOptionChip(
                            label: 'Gelap',
                            icon: Icons.dark_mode_rounded,
                            isSelected: currentMode == ThemeMode.dark,
                            onTap: () {
                              themeScope?.value = ThemeMode.dark;
                              setModalState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ThemeOptionChip(
                            label: 'Sistem',
                            icon: Icons.settings_brightness_rounded,
                            isSelected: currentMode == ThemeMode.system,
                            onTap: () {
                              themeScope?.value = ThemeMode.system;
                              setModalState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Selector Ukuran Font
                    Text('UKURAN HURUF', style: AppText.overline(context, color: p.icon)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppFontSize.values.map((size) {
                        final isSelected = currentFont == size;
                        return ChoiceChip(
                          label: Text(
                            size.label,
                            style: AppText.bodySm(context).copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? p.onPrimary : p.title,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: p.primary,
                          backgroundColor: p.surfaceAlt,
                          side: BorderSide(color: isSelected ? p.primary : p.border),
                          onSelected: (selected) {
                            if (selected && fontScope != null) {
                              fontScope.value = size;
                              setModalState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Preview Kotak Teks
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pratinjau Teks', style: AppText.title(context)),
                          const SizedBox(height: 6),
                          Text(
                            'Teks ini memperlihatkan bagaimana judul, isi, dan tombol berubah secara responsif.',
                            style: AppText.body(context),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Simpan & Terapkan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_MenuItem> _getAccountItems(BuildContext context) {
    final p = context.palette;
    return [
      _MenuItem(
        icon: Icons.format_size_rounded,
        iconColor: p.accent,
        title: 'Ukuran Teks & Tema',
        subtitle: 'Atur skala ukuran huruf dan tema tampilan',
        onTap: () => _showAppearanceSettings(context),
      ),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: dashboardBackgroundColor(context),
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = context.palette;
    return Scaffold(
      backgroundColor: dashboardBackgroundColor(context),
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.page,
          8,
          AppSpace.page,
          AppSpace.gapXl,
        ),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSection(
            'Pengaturan Akun',
            'Preferensi',
            p.subtitle,
            _getAccountItems(context),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Bantuan & Informasi',
            'Dukungan Lapangan',
            p.accent,
            _getHelpItems(context),
          ),
          const SizedBox(height: 24),
          _buildLogout(context),
          const SizedBox(height: 24),
          _buildBuildInfo(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final canPop = Navigator.of(context).canPop();
    return PreferredSize(
      preferredSize: Size.fromHeight(AppText.scaledSize(context, 58)),
      child: SafeArea(
        bottom: false,
        child: DashboardHeader(
          title: 'Akun Saya',
          onBack: canPop ? () => Navigator.of(context).maybePop() : null,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final p = context.palette;
    return CapseeCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        child: Stack(
          children: [
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
              padding: const EdgeInsets.all(AppSpace.card),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: AppSpace.gapMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profil?['nama'] ?? 'Pengguna',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.headline(context),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.eco, size: 15, color: p.accent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _lokasiSingkat(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.bodySm(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const StatusBadge(
                              label: 'Petani Komersial',
                              kind: BadgeKind.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.gapMd),
                  _buildContactPanel(),
                ],
              ),
            ),
          ],
        ),
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
                  child: Icon(Icons.photo_camera, size: 13, color: p.onPrimary),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: p.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lahan Aktif',
                  style: AppText.bodySm(context).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '2 Petak Terdaftar',
                style: AppText.bodySm(context, color: p.title).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.mail_outline, size: 18, color: p.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (_profil?['email'] ?? '').toString().isEmpty
                      ? '-'
                      : (_profil?['email'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm(context),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.check_circle, size: 16, color: p.accent),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: p.icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (_profil?['nomor_hp'] ?? '').toString().isEmpty
                      ? 'Belum diisi'
                      : (_profil?['nomor_hp'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm(context),
                ),
              ),
              const SizedBox(width: 6),
              const StatusBadge(label: 'Aktif WA', kind: BadgeKind.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String trailing,
    Color trailingColor,
    List<_MenuItem> items,
  ) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppText.overline(context, color: p.icon),
                ),
              ),
              Text(trailing, style: AppText.micro(context, color: trailingColor)),
            ],
          ),
        ),
        CapseeCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpace.radiusCard),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _MenuTile(item: items[i]),
                  if (i != items.length - 1)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: AppSpace.card),
                      color: p.border,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogout(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: p.error.withAlpha(isDark ? 40 : 26),
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        onTap: () => _confirmLogout(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.card),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 20, color: p.error),
                const SizedBox(width: 8),
                Text(
                  'Keluar dari Akun',
                  style: AppText.subtitle(context, color: p.error),
                ),
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
        title: Text('Keluar dari akun?', style: AppText.headline(context)),
        content: Text(
          'Anda perlu masuk lagi untuk memantau lahan.',
          style: AppText.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppText.subtitle(context, color: p.subtitle),
            ),
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
            child: Text('Keluar', style: AppText.subtitle(context, color: p.error)),
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
            Text('CAPSEE PRECISION AGRI', style: AppText.overline(context, color: p.icon)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Versi 2.4.0 (Build 2024.11) • Sistem Terenkripsi',
          textAlign: TextAlign.center,
          style: AppText.bodySm(context, color: p.subtitle.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.card),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subtitle(context).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySm(context),
                  ),
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

class _ThemeOptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: isSelected ? p.primary : p.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? p.onPrimary : p.icon),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppText.micro(context, color: isSelected ? p.onPrimary : p.title).copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
