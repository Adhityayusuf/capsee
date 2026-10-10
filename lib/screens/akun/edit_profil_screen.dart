import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _farmLocationController;

  Uint8List? _avatarBytes;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _farmLocationController = TextEditingController();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final profil = await getProfil();
      if (!mounted) return;
      setState(() {
        _nameController.text = (profil['nama'] ?? '').toString();
        _emailController.text = (profil['email'] ?? '').toString();
        _phoneController.text = (profil['nomor_hp'] ?? '').toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorPopup(context, 'Gagal memuat profil: ${pesanError(e)}');
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.trim().length < 3) {
      showErrorPopup(context, 'Nama minimal 3 karakter.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await editProfil(
        nama: _nameController.text.trim(),
        nomorHp: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (!mounted) return;
      showSuccessPopup(context, 'Profil berhasil disimpan.');
      Navigator.maybePop(context, true);
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menyimpan: ${pesanError(e)}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: p.title),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Edit Profil',
            style: AppText.headline(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: p.background,
      extendBodyBehindAppBar: true, // Agar efek BackdropFilter ImageFilter terasa
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          // PENGGUNAAN ImageFilter DARI dart:ui
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: p.surface.withValues(alpha: 0.85),
              elevation: 0.5,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: p.title),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                'Edit Profil',
                style: AppText.headline(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, color: p.title),
                  onPressed: () => Navigator.maybePop(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: p.primary,
                    child: Icon(Icons.person, color: p.onPrimary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.page, AppSpace.gapMd, AppSpace.page, AppSpace.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // AVATAR
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: p.surfaceAlt,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!) as ImageProvider
                          : const NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuACNX9MgbxmS9XouZIyGyGTYaG8XqKIMVJ85MZIYLKV0h89F0EHGJTlwNT2kVYy-UaxvQuY3WIrglRqD9r6uEoNFYUvZze58N_jbMiC_TbBu5zoy4KWO5zFaPck-_qz0Yxlct1JzFsrMix1FdvBoEdtXvF3mGz1rIbSYgGyY2lFJhW5yY4lhAm77yP-AsrqNyH5h78bra9xhTI_kDwo3CcLQLAJ_lw-IfIfyQh_jqz8DhDqJvq7Q4fLTg',
                            ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: p.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.photo_camera, color: p.onPrimary, size: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Ubah Foto Profil',
                    style: AppText.subtitle(context, color: p.accent)),
                const SizedBox(height: 4),
                Text('Format JPG atau PNG, maks. 5 MB',
                    style: AppText.bodySm(context)),
                const SizedBox(height: 24),

                // FIELD NAMA
                _buildInput(
                  label: 'NAMA LENGKAP',
                  isRequired: true,
                  controller: _nameController,
                  icon: Icons.person_outline,
                  placeholder: 'Masukkan nama lengkap',
                ),
                const SizedBox(height: 18),

                // FIELD EMAIL
                _buildInput(
                  label: 'ALAMAT EMAIL',
                  isRequired: true,
                  readOnly: true,
                  controller: _emailController,
                  icon: Icons.mail_outline,
                  placeholder: 'contoh@domain.id',
                  badgeText: 'Terverifikasi',
                  badgeBg: p.accentSoft,
                  badgeTextColor: p.onAccentSoft,
                  caption: 'Email tidak dapat diubah. Digunakan untuk laporan ringkasan mingguan petak dan diagnosa ML.',
                ),
                const SizedBox(height: 18),

                // FIELD WA
                _buildInput(
                  label: 'NOMOR WHATSAPP / HP',
                  isRequired: true,
                  controller: _phoneController,
                  icon: Icons.phone_android_outlined,
                  placeholder: '+62 8xx-xxxx-xxxx',
                  badgeText: 'Aktif WA',
                  badgeIcon: Icons.sms,
                  badgeBg: p.accentSoft,
                  badgeTextColor: p.onAccentSoft,
                  caption: 'Nomor aktif untuk pengiriman notifikasi darurat hama & cuaca ekstrem.',
                ),
                const SizedBox(height: 18),

                // FIELD LOKASI
                _buildInput(
                  label: 'LOKASI / DOMISILI KEBUN',
                  controller: _farmLocationController,
                  icon: Icons.location_on_outlined,
                  placeholder: 'Kecamatan, Kabupaten / Kota',
                ),
                const SizedBox(height: 18),

                // INFO CARD
                CapseeCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, color: p.accent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data profil digunakan untuk sinkronisasi sensor lahan cabai secara real-time.',
                          style: AppText.bodySm(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BUTTON SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.primary,
                      foregroundColor: p.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpace.radiusTile)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: p.onPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text('Simpan Perubahan',
                            style: AppText.subtitle(context,
                                    color: p.onPrimary)
                                .copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // BUTTON BATAL
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: p.surfaceAlt,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpace.radiusTile)),
                    ),
                    child: Text('Batal',
                        style: AppText.subtitle(context)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    bool isRequired = false,
    bool readOnly = false,
    String? badgeText,
    IconData? badgeIcon,
    Color? badgeBg,
    Color? badgeTextColor,
    String? caption,
  }) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label,
                    style: AppText.overline(context, color: p.subtitle)),
                if (isRequired)
                  Text(' *',
                      style: AppText.overline(context, color: p.error)),
              ],
            ),
            if (badgeText != null)
              StatusBadge(label: badgeText!, kind: BadgeKind.success),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            boxShadow: [
              BoxShadow(color: p.shadow, blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: AppText.body(context, color: p.title),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppText.body(context, color: p.hint),
              prefixIcon: Icon(icon, color: p.subtitle, size: 22),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel_outlined, color: p.hint, size: 20),
                onPressed: () => controller.clear(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(caption, style: AppText.caption(context)),
        ],
      ],
    );
  }
}
