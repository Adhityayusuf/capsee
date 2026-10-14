import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/popup_notifikasi.dart';
import '../home/dashboard_screen.dart';

/// Layar wajib isi identitas diri pengganti onboarding lama.
///
/// Field: Nama Lengkap*, No HP/WA*, Provinsi*/Kota*/Kecamatan*.
/// Tidak bisa dilewati: tanpa tombol lewati, tombol back dimatikan,
/// navigasi keluar hanya setelah simpan berhasil.
class LengkapiIdentitasScreen extends StatefulWidget {
  const LengkapiIdentitasScreen({super.key});

  @override
  State<LengkapiIdentitasScreen> createState() =>
      _LengkapiIdentitasScreenState();
}

class _LengkapiIdentitasScreenState extends State<LengkapiIdentitasScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _hpController;
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

  bool _loadingProfil = true;
  bool _loadingProv = true;
  bool _loadingKota = false;
  bool _loadingKec = false;
  bool _manualWilayah = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _hpController = TextEditingController();
    _provManualController = TextEditingController();
    _kotaManualController = TextEditingController();
    _kecManualController = TextEditingController();
    _init();
  }

  Future<void> _init() async {
    // Muat profil (prefill) dan daftar provinsi paralel berurutan.
    try {
      final profil = await getProfil();
      if (!mounted) return;
      _namaController.text = (profil['nama'] ?? '').toString();
      _hpController.text = (profil['nomor_hp'] ?? '').toString();
      final provAwal = (profil['provinsi'] ?? '').toString();
      final kotaAwal = (profil['kota'] ?? '').toString();
      final kecAwal = (profil['kecamatan'] ?? '').toString();
      setState(() => _loadingProfil = false);
      await _loadProvinsi(awalProv: provAwal, awalKota: kotaAwal, awalKec: kecAwal);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProfil = false;
        _loadingProv = false;
        _manualWilayah = true;
      });
    }
  }

  Future<void> _loadProvinsi({String? awalProv, String? awalKota, String? awalKec}) async {
    try {
      final list = await getProvinsi();
      if (!mounted) return;
      setState(() {
        _provinces = list;
        _loadingProv = false;
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
        _loadingProv = false;
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

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _provManualController.dispose();
    _kotaManualController.dispose();
    _kecManualController.dispose();
    super.dispose();
  }

  String? _validateHp(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Nomor HP wajib diisi';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 15) return 'Nomor tidak valid';
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
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
      await lengkapiIdentitas(
        nama: _namaController.text.trim(),
        nomorHp: _hpController.text.trim(),
        provinsi: provinsi,
        kota: kota,
        kecamatan: kecamatan,
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      await showSuccessPopup(context, 'Identitas tersimpan! Selamat datang di Capsee.');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showErrorPopup(context, 'Gagal menyimpan: ${pesanError(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kunci tombol back Android + gesture agar tidak bisa dilewati.
    return PopScope(
      canPop: false,
      child: AuthScaffold(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const AuthHeader(
              title: 'Lengkapi Identitas Diri',
              subtitle:
                  'Data diri wajib diisi dan tidak bisa dilewati. Lokasi ini dipakai untuk cuaca di dashboard.',
            ),
            const SizedBox(height: 20),
            if (_loadingProfil || _loadingProv)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Nama Lengkap *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _namaController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: AppText.body(context,
                            color: context.palette.title),
                        decoration: capseeInputDecoration(
                          context,
                          hint: 'Nama lengkap Anda',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Nama wajib diisi';
                          if (t.length < 3) return 'Nama terlalu pendek';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Nomor HP / WhatsApp *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _hpController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: AppText.body(context,
                            color: context.palette.title),
                        decoration: capseeInputDecoration(
                          context,
                          hint: '08xx-xxxx-xxxx',
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                        validator: _validateHp,
                      ),
                      const SizedBox(height: 16),
                      const FieldLabel('Provinsi *'),
                      const SizedBox(height: 8),
                      _buildProvinsiField(),
                      const SizedBox(height: 16),
                      const FieldLabel('Kota / Kabupaten *'),
                      const SizedBox(height: 8),
                      _buildKotaField(),
                      const SizedBox(height: 16),
                      const FieldLabel('Kecamatan *'),
                      const SizedBox(height: 8),
                      _buildKecField(),
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
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Simpan & Lanjut',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isSaving,
                        onPressed: _simpan,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinsiField() {
    if (_manualWilayah) {
      return TextFormField(
        controller: _provManualController,
        style: AppText.body(context, color: context.palette.title),
        decoration: capseeInputDecoration(context,
            hint: 'Tulis provinsi (offline)',
            prefixIcon: Icons.map_outlined),
        validator: (v) =>
            ((v ?? '').trim().isEmpty) ? 'Provinsi wajib diisi' : null,
      );
    }
    if (_loadingKota && _provId != null) {
      // tetap tampilkan picker saat kota loading
    }
    return _wilayahPicker(
      hint: 'Pilih provinsi (${_provinces.length} tersedia)',
      selected: _selectedProvince,
      onTap: () => _showWilayahDialog(
        label: 'Provinsi',
        items: _provinces,
        onSelect: (w) => _pilihProvinsi(w),
      ),
      validatorText: 'Provinsi wajib dipilih',
    );
  }

  Widget _buildKotaField() {
    if (_manualWilayah) {
      return TextFormField(
        controller: _kotaManualController,
        style: AppText.body(context, color: context.palette.title),
        decoration: capseeInputDecoration(context,
            hint: 'Tulis kota/kabupaten (offline)',
            prefixIcon: Icons.location_city),
        validator: (v) =>
            ((v ?? '').trim().isEmpty) ? 'Kota wajib diisi' : null,
      );
    }
    if (_loadingKota) return const LinearProgressIndicator();
    return _wilayahPicker(
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
      validatorText: 'Kota wajib dipilih',
    );
  }

  Widget _buildKecField() {
    if (_manualWilayah) {
      return TextFormField(
        controller: _kecManualController,
        style: AppText.body(context, color: context.palette.title),
        decoration: capseeInputDecoration(context,
            hint: 'Tulis kecamatan (offline)',
            prefixIcon: Icons.pin_drop_outlined),
        validator: (v) =>
            ((v ?? '').trim().isEmpty) ? 'Kecamatan wajib diisi' : null,
      );
    }
    if (_loadingKec) return const LinearProgressIndicator();
    return _wilayahPicker(
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
      validatorText: 'Kecamatan wajib dipilih',
    );
  }

  Widget _wilayahPicker({
    required String hint,
    required String selected,
    required VoidCallback onTap,
    required String validatorText,
    bool enabled = true,
  }) {
    final p = context.palette;
    return FormField<String>(
      initialValue: selected,
      validator: (_) => selected.trim().isEmpty ? validatorText : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: enabled
                    ? p.surfaceAlt
                    : p.surfaceAlt.withValues(alpha: .5),
                borderRadius:
                    BorderRadius.circular(AppSpace.radiusTile),
                border: state.hasError
                    ? Border.all(color: p.error)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined,
                      color: enabled ? p.accent : p.hint, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selected.isEmpty ? hint : selected,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: selected.isEmpty
                          ? AppText.bodySm(context, color: p.hint)
                          : AppText.body(context, color: p.title),
                    ),
                  ),
                  Icon(Icons.search,
                      color: enabled ? p.icon : p.hint, size: 20),
                ],
              ),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                state.errorText!,
                style: AppText.bodySm(context, color: p.error),
              ),
            ),
        ],
      ),
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
}
