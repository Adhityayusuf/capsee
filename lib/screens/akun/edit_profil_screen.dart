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
  late final TextEditingController _provManualController;
  late final TextEditingController _kotaManualController;
  late final TextEditingController _kecManualController;

  List<Wilayah> _provinces = [];
  List<Wilayah> _cities = [];
  List<Wilayah> _districts = [];
  String? _provId;
  String? _kotaId;
  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  bool _loadingWilayah = true;
  bool _loadingKota = false;
  bool _loadingKec = false;
  bool _manualWilayah = false;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _provManualController = TextEditingController();
    _kotaManualController = TextEditingController();
    _kecManualController = TextEditingController();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final profil = await getProfil();
      if (!mounted) return;
      _nameController.text = (profil['nama'] ?? '').toString();
      _emailController.text = (profil['email'] ?? '').toString();
      _phoneController.text = (profil['nomor_hp'] ?? '').toString();
      final provAwal = (profil['provinsi'] ?? '').toString();
      final kotaAwal = (profil['kota'] ?? '').toString();
      final kecAwal = (profil['kecamatan'] ?? '').toString();
      setState(() => _isLoading = false);
      await _loadProvinsi(awalProv: provAwal, awalKota: kotaAwal, awalKec: kecAwal);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingWilayah = false;
        _manualWilayah = true;
      });
      showErrorPopup(context, 'Gagal memuat profil: ${pesanError(e)}');
    }
  }

  Future<void> _loadProvinsi({String? awalProv, String? awalKota, String? awalKec}) async {
    try {
      final list = await getProvinsi();
      if (!mounted) return;
      setState(() {
        _provinces = list;
        _loadingWilayah = false;
      });
      if (awalProv != null && awalProv.trim().isNotEmpty) {
        final cocok = _cariNama(list, awalProv);
        if (cocok != null) {
          await _pilihProvinsi(cocok, awalKota: awalKota, awalKec: awalKec);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingWilayah = false;
        _manualWilayah = true;
      });
    }
  }

  static Wilayah? _cariNama(List<Wilayah> list, String target) {
    final t = target.trim().toLowerCase();
    if (t.isEmpty) return null;
    for (final w in list) {
      if (w.name.toLowerCase() == t) return w;
    }
    String norm(String s) => s
        .toLowerCase()
        .replaceFirst(RegExp(r'^(kab\.|kota adm\.|kota)\s*'), '')
        .trim();
    for (final w in list) {
      if (norm(w.name) == norm(t)) return w;
    }
    for (final w in list) {
      if (w.name.toLowerCase().contains(t) || t.contains(w.name.toLowerCase())) {
        return w;
      }
    }
    return null;
  }

  Future<void> _pilihProvinsi(Wilayah prov, {String? awalKota, String? awalKec}) async {
    setState(() {
      _provId = prov.id;
      _selectedProvince = prov.name;
      _provManualController.text = prov.name;
      _cities = [];
      _districts = [];
      _kotaId = null;
      _selectedCity = '';
      _selectedDistrict = '';
      _loadingKota = true;
    });
    try {
      final list = await getKota(prov.id);
      if (!mounted) return;
      setState(() {
        _cities = list;
        _loadingKota = false;
      });
      if (awalKota != null && awalKota.isNotEmpty) {
        final cocok = _cariNama(list, awalKota);
        if (cocok != null) await _pilihKota(cocok, awalKec: awalKec);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingKota = false);
      showErrorPopup(context, 'Gagal memuat kota: ${pesanError(e)}');
    }
  }

  Future<void> _pilihKota(Wilayah kota, {String? awalKec}) async {
    setState(() {
      _kotaId = kota.id;
      _selectedCity = kota.name;
      _kotaManualController.text = kota.name;
      _districts = [];
      _selectedDistrict = '';
      _loadingKec = true;
    });
    try {
      final list = await getKecamatan(kota.id);
      if (!mounted) return;
      setState(() {
        _districts = list;
        _loadingKec = false;
      });
      if (awalKec != null && awalKec.isNotEmpty) {
        final cocok = _cariNama(list, awalKec);
        if (cocok != null && mounted) {
          setState(() {
            _selectedDistrict = cocok.name;
            _kecManualController.text = cocok.name;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingKec = false);
      showErrorPopup(context, 'Gagal memuat kecamatan: ${pesanError(e)}');
    }
  }

  String? _validatePhone(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Nomor HP wajib diisi';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 15) return 'Nomor tidak valid';
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.trim().length < 3) {
      showErrorPopup(context, 'Nama minimal 3 karakter.');
      return;
    }
    final provinsi = _manualWilayah
        ? _provManualController.text.trim()
        : _selectedProvince.trim();
    final kota = _manualWilayah
        ? _kotaManualController.text.trim()
        : _selectedCity.trim();
    final kecamatan = _manualWilayah
        ? _kecManualController.text.trim()
        : _selectedDistrict.trim();
    if (provinsi.isEmpty || kota.isEmpty || kecamatan.isEmpty) {
      showErrorPopup(context, 'Lengkapi provinsi, kota, dan kecamatan dulu.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await editProfil(
        nama: _nameController.text.trim(),
        nomorHp: _phoneController.text.trim(),
        provinsi: provinsi,
        kota: kota,
        kecamatan: kecamatan,
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
    _provManualController.dispose();
    _kotaManualController.dispose();
    _kecManualController.dispose();
    super.dispose();
  }

  String get _inisial {
    final nama = _nameController.text.trim();
    if (nama.isEmpty) return '?';
    final kata = nama.split(RegExp(r'\s+'));
    if (kata.length == 1) return kata.first.substring(0, 1).toUpperCase();
    return '${kata.first.substring(0, 1)}${kata.last.substring(0, 1)}'.toUpperCase();
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
                // AVATAR (inisial — upload foto belum didukung backend)
                CircleAvatar(
                  radius: 56,
                  backgroundColor: p.accentSoft,
                  child: Text(
                    _inisial,
                    style: AppText.display(context, color: p.onAccentSoft)
                        .copyWith(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_nameController.text.trim().isEmpty
                    ? 'Foto Profil'
                    : _nameController.text.trim()),
                const SizedBox(height: 24),

                // FIELD NAMA
                _buildInput(
                  label: 'NAMA LENGKAP',
                  isRequired: true,
                  controller: _nameController,
                  icon: Icons.person_outline,
                  placeholder: 'Masukkan nama lengkap',
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Nama wajib diisi';
                    if (t.length < 3) return 'Nama terlalu pendek';
                    return null;
                  },
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
                  placeholder: '08xx-xxxx-xxxx',
                  badgeText: 'Aktif WA',
                  badgeIcon: Icons.sms,
                  badgeBg: p.accentSoft,
                  badgeTextColor: p.onAccentSoft,
                  caption: 'Nomor aktif untuk pengiriman notifikasi darurat hama & cuaca ekstrem.',
                  validator: _validatePhone,
                ),
                const SizedBox(height: 18),

                // FIELD LOKASI — sama seperti identitas diri (dropdown wilayah)
                _buildLokasiSection(),
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
                          'Lokasi domisili dipakai untuk cuaca BMKG di dashboard. Ubah di sini kalau Anda pindah domisili.',
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

  Widget _buildLokasiSection() {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('LOKASI / DOMISILI',
                    style: AppText.overline(context, color: p.subtitle)),
                Text(' *',
                    style: AppText.overline(context, color: p.error)),
              ],
            ),
            const StatusBadge(label: 'Cuaca BMKG', kind: BadgeKind.info),
          ],
        ),
        const SizedBox(height: 6),
        if (_loadingWilayah)
          const LinearProgressIndicator()
        else if (_manualWilayah) ...[
          _manualField(
            controller: _provManualController,
            icon: Icons.map_outlined,
            placeholder: 'Provinsi (offline)',
          ),
          const SizedBox(height: 10),
          _manualField(
            controller: _kotaManualController,
            icon: Icons.location_city,
            placeholder: 'Kota / Kabupaten (offline)',
          ),
          const SizedBox(height: 10),
          _manualField(
            controller: _kecManualController,
            icon: Icons.pin_drop_outlined,
            placeholder: 'Kecamatan (offline)',
          ),
        ] else ...[
          _wilayahPicker(
            icon: Icons.map_outlined,
            hint: 'Pilih provinsi (${_provinces.length} tersedia)',
            selected: _selectedProvince,
            onTap: () => _showWilayahDialog(
              label: 'Provinsi',
              items: _provinces,
              onSelect: (w) => _pilihProvinsi(w),
            ),
            errorText: _selectedProvince.isEmpty ? 'Provinsi wajib dipilih' : null,
          ),
          const SizedBox(height: 10),
          if (_loadingKota)
            const LinearProgressIndicator()
          else
            _wilayahPicker(
              icon: Icons.location_city,
              hint: _provId == null
                  ? 'Pilih provinsi dulu'
                  : 'Pilih kota (${_cities.length} tersedia)',
              selected: _selectedCity,
              enabled: _provId != null,
              onTap: () => _showWilayahDialog(
                label: 'Kota / Kabupaten',
                items: _cities,
                onSelect: (w) => _pilihKota(w),
              ),
              errorText: _selectedCity.isEmpty ? 'Kota wajib dipilih' : null,
            ),
          const SizedBox(height: 10),
          if (_loadingKec)
            const LinearProgressIndicator()
          else
            _wilayahPicker(
              icon: Icons.pin_drop_outlined,
              hint: _kotaId == null
                  ? 'Pilih kota dulu'
                  : 'Pilih kecamatan (${_districts.length} tersedia)',
              selected: _selectedDistrict,
              enabled: _kotaId != null,
              onTap: () => _showWilayahDialog(
                label: 'Kecamatan',
                items: _districts,
                onSelect: (w) => setState(() {
                  _selectedDistrict = w.name;
                  _kecManualController.text = w.name;
                }),
              ),
              errorText:
                  _selectedDistrict.isEmpty ? 'Kecamatan wajib dipilih' : null,
            ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() {
              _manualWilayah = !_manualWilayah;
              if (_manualWilayah) {
                _provManualController.text = _selectedProvince;
                _kotaManualController.text = _selectedCity;
                _kecManualController.text = _selectedDistrict;
              }
            }),
            child: Text(_manualWilayah
                ? 'Muat daftar lengkap'
                : 'Isi manual (offline)'),
          ),
        ),
      ],
    );
  }

  Widget _manualField({
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
  }) {
    final p = context.palette;
    return Container(
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
        style: AppText.body(context, color: p.title),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppText.body(context, color: p.hint),
          prefixIcon: Icon(icon, color: p.subtitle, size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        validator: (v) =>
            ((v ?? '').trim().isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _wilayahPicker({
    required IconData icon,
    required String hint,
    required String selected,
    required VoidCallback onTap,
    required String? errorText,
    bool enabled = true,
  }) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              border: errorText != null
                  ? Border.all(color: p.error)
                  : null,
              boxShadow: [
                BoxShadow(
                    color: p.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: enabled ? p.subtitle : p.hint, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selected.isEmpty ? hint : selected,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected.isEmpty
                        ? AppText.body(context, color: p.hint)
                        : AppText.body(context, color: p.title),
                  ),
                ),
                Icon(Icons.search,
                    color: enabled ? p.hint : p.hint, size: 20),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText, style: AppText.caption(context, color: p.error)),
        ],
      ],
    );
  }

  Future<void> _showWilayahDialog({
    required String label,
    required List<Wilayah> items,
    required ValueChanged<Wilayah> onSelect,
  }) async {
    final query = TextEditingController();
    List<Wilayah> filtered = items;
    final picked = await showDialog<Wilayah>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('Pilih $label', style: AppText.title(ctx)),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: Column(
              children: [
                TextField(
                  controller: query,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cari $label...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (q) => setD(() {
                    final s = q.trim().toLowerCase();
                    filtered = s.isEmpty
                        ? items
                        : items
                            .where((w) =>
                                w.name.toLowerCase().contains(s))
                            .toList();
                  }),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ditemukan.',
                            style: AppText.bodySm(ctx),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final w = filtered[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                w.name,
                                style: AppText.body(ctx),
                              ),
                              onTap: () => Navigator.of(ctx).pop(w),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
    query.dispose();
    if (picked != null) onSelect(picked);
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
    String? Function(String?)? validator,
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
              StatusBadge(label: badgeText, kind: BadgeKind.success),
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
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppText.body(context, color: p.hint),
              prefixIcon: Icon(icon, color: p.subtitle, size: 22),
              // Email read-only tidak perlu tombol hapus.
              suffixIcon: readOnly
                  ? null
                  : IconButton(
                      icon: Icon(Icons.cancel_outlined,
                          color: p.hint, size: 20),
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
