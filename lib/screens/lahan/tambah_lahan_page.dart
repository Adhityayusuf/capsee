import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../models/land_data.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';
import '../../widgets/ui_kit.dart';

class TambahLahanPage extends StatefulWidget {
  /// Jika [initial] atau [idLahan] diisi, halaman ini menjadi form edit lahan.
  final LandData? initial;
  final String? idLahan;

  const TambahLahanPage({super.key, this.initial, this.idLahan});

  @override
  State<TambahLahanPage> createState() => _TambahLahanPageState();
}

class _TambahLahanPageState extends State<TambahLahanPage> {
  bool get _isEdit => widget.initial != null || widget.idLahan != null;

  // Controller input
  late final TextEditingController _namaLahanController;
  late final TextEditingController _provManualController;
  late final TextEditingController _kotaManualController;
  late final TextEditingController _kecManualController;
  late final TextEditingController _intervalPupukController;
  late final TextEditingController _intervalSiramController;

  // Dropdown wilayah lengkap (nama asli dari API, bukan kode).
  List<Wilayah> _provinces = [];
  List<Wilayah> _cities = [];
  List<Wilayah> _districts = [];
  String? _provId;
  String? _kotaId;
  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  bool _loadingProv = true;
  bool _loadingKota = false;
  bool _loadingKec = false;
  bool _manualWilayah = false;

  // Tanggal terakhir siram/pupuk (opsional, date picker asli).
  DateTime? _tglSiram;
  DateTime? _tglPupuk;

  // State Umur Tanaman
  late int _selectedAgeMonth;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _namaLahanController = TextEditingController(
      text: initial?.name ?? '',
    );
    _provManualController =
        TextEditingController(text: _legacyName(initial?.province));
    _kotaManualController =
        TextEditingController(text: _legacyName(initial?.city));
    _kecManualController =
        TextEditingController(text: _legacyName(initial?.district));
    _tglSiram = initial?.lastWatered;
    _tglPupuk = initial?.lastFertilized;
    _intervalPupukController = TextEditingController(
      text: '${initial?.fertilizeIntervalWeeks ?? 1}',
    );
    _intervalSiramController = TextEditingController(
      text: '${initial?.wateringIntervalWeeks ?? 1}',
    );
    _selectedAgeMonth = (initial?.plantAgeMonths ?? 3).clamp(1, 5).toInt();
    _loadProvinsi();
  }

  /// Data lama tersimpan sebagai kode (jabar/kbb/...) → tampilkan nama lengkap.
  static String _legacyName(String? value) {
    const map = {
      'jabar': 'Jawa Barat',
      'jateng': 'Jawa Tengah',
      'jatim': 'Jawa Timur',
      'sumut': 'Sumatera Utara',
      'kbb': 'Kab. Bandung Barat',
      'bdg': 'Kab. Bandung',
      'grt': 'Kab. Garut',
      'cjr': 'Kab. Cianjur',
      'lembang': 'Lembang',
      'parongpong': 'Parongpong',
      'cisarua': 'Cisarua',
      'ngamprah': 'Ngamprah',
    };
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    return map[v.toLowerCase()] ?? v;
  }

  static Wilayah? _cariNama(List<Wilayah> list, String target) {
    final t = target.trim().toLowerCase();
    if (t.isEmpty) return null;
    for (final w in list) {
      if (w.name.toLowerCase() == t) return w;
    }
    // Hilangkan awalan kab./kota agar "Bandung Barat" cocok dengan "Kab. Bandung Barat".
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

  Future<void> _loadProvinsi() async {
    try {
      final list = await getProvinsi();
      if (!mounted) return;
      setState(() {
        _provinces = list;
        _loadingProv = false;
      });
      // Cocokkan nilai awal (mode edit) ke daftar lengkap.
      final awal = _legacyName(widget.initial?.province);
      final cocok = _cariNama(list, awal);
      if (cocok != null) await _pilihProvinsi(cocok, awalKota: _legacyName(widget.initial?.city), awalKec: _legacyName(widget.initial?.district));
    } catch (e) {
      // API gagal (offline) → jatuh ke input manual agar user tidak buntu.
      if (!mounted) return;
      setState(() {
        _loadingProv = false;
        _manualWilayah = true;
      });
    }
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

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _tglIndo(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  final Map<int, String> _agePhases = {
    1: 'Fase Vegetatif Awal',
    2: 'Fase Vegetatif Aktif',
    3: 'Fase Berbunga & Berbuah',
    4: 'Fase Pematangan Buah',
    5: 'Fase Panen Berkala',
  };

  @override
  void dispose() {
    _namaLahanController.dispose();
    _provManualController.dispose();
    _kotaManualController.dispose();
    _kecManualController.dispose();
    _intervalPupukController.dispose();
    _intervalSiramController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _simpanData() async {
    if (_namaLahanController.text.trim().isEmpty) {
      showErrorPopup(context, 'Nama lahan tidak boleh kosong.');
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
    final intervalPupuk =
        int.tryParse(_intervalPupukController.text.trim()) ?? 0;
    if (intervalPupuk < 1 || intervalPupuk > 12) {
      showErrorPopup(context, 'Interval pupuk 1–12 minggu (contoh: 4).');
      return;
    }
    final intervalSiram =
        int.tryParse(_intervalSiramController.text.trim()) ?? 0;
    if (intervalSiram < 1 || intervalSiram > 12) {
      showErrorPopup(context, 'Interval siram 1–12 minggu (contoh: 1).');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nama = _namaLahanController.text.trim();

      if (_isEdit) {
        final id = widget.idLahan ?? widget.initial?.id;
        if (id == null || id.isEmpty) {
          throw ApiException('ID lahan tidak ditemukan.', 0);
        }
        await editLahan(
          id,
          nama: nama,
          provinsi: provinsi,
          kota: kota,
          kecamatan: kecamatan,
          umurTanamanBulan: _selectedAgeMonth,
          intervalPupukMinggu: intervalPupuk,
          intervalSiramMinggu: intervalSiram,
        );
      } else {
        await tambahLahan(
          nama: nama,
          provinsi: provinsi,
          kota: kota,
          kecamatan: kecamatan,
          umurTanamanBulan: _selectedAgeMonth,
          intervalPupukMinggu: intervalPupuk,
          intervalSiramMinggu: intervalSiram,
          tanggalTerakhirSiram: _tglSiram == null ? null : _iso(_tglSiram!),
          tanggalTerakhirPupuk: _tglPupuk == null ? null : _iso(_tglPupuk!),
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Tunggu user tutup dialog sukses DULU, baru keluar halaman.
      // (Kalau dialog masih terbuka saat pop, yang tertutup cuma dialognya
      // dan halaman input tidak jadi keluar.)
      if (mounted) {
        await showSuccessPopup(
          context,
          _isEdit
              ? 'Data kebun berhasil diperbarui!'
              : 'Data kebun berhasil ditambahkan!',
        );
      }

      // Keluar + kirim true agar pemanggil merefresh dari server.
      if (mounted) Navigator.maybePop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorPopup(context, 'Gagal menyimpan: ${pesanError(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.title),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.eco, color: p.accent, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isEdit ? 'Edit Data Lahan' : 'Tambah Data Lahan',
                style: AppText.headline(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: p.subtitle),
            onPressed: () => Navigator.maybePop(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: p.primary,
              child: Icon(Icons.person, color: p.onPrimary, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Banner Kalibrasi Presisi ML
            CapseeCard(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.accentSoft,
                          borderRadius: BorderRadius.circular(
                            AppSpace.radiusTile,
                          ),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: p.accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kalibrasi Presisi ML',
                              style: AppText.title(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lengkapi parameter kebun untuk kalibrasi algoritma pemantauan tanaman cabai Anda secara akurat.',
                              style: AppText.bodySm(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: p.accent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Akurasi deteksi patogen meningkat hingga 94.8%',
                          style: AppText.bodySm(
                            context,
                            color: p.accent,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Identitas & Lokasi Kebun
            _buildCardWrapper(
              title: 'Identitas & Lokasi Kebun',
              sectionTag: 'Seksi 1/2',
              tagColor: p.accentSoft,
              tagTextColor: p.onAccentSoft,
              children: [
                _buildFieldLabel(
                  icon: Icons.grass,
                  label: 'Nama Lahan',
                  isRequired: true,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaLahanController,
                  style: AppText.body(context, color: p.title),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.label_outline,
                    hint: 'Misal: Petak Cabai Rawit Blok A',
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(icon: Icons.map_outlined, label: 'Provinsi'),
                const SizedBox(height: 8),
                if (_manualWilayah)
                  TextFormField(
                    controller: _provManualController,
                    style: AppText.body(context, color: p.title),
                    decoration: _buildInputDecoration(
                      prefixIcon: Icons.map_outlined,
                      hint: 'Tulis provinsi (offline)',
                    ),
                  )
                else if (_loadingProv)
                  const LinearProgressIndicator(),
                if (!_manualWilayah && !_loadingProv)
                  _buildWilayahPicker(
                    icon: Icons.map_outlined,
                    hint: 'Pilih provinsi (${_provinces.length} tersedia)',
                    selected: _selectedProvince,
                    onTap: () => _showWilayahDialog(
                      label: 'Provinsi',
                      items: _provinces,
                      onSelect: (w) => _pilihProvinsi(w),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldLabel(
                        icon: Icons.location_city,
                        label: 'Kota / Kabupaten',
                      ),
                    ),
                    Flexible(child: _buildSubTag('(menyesuaikan provinsi)')),
                  ],
                ),
                const SizedBox(height: 8),
                if (_manualWilayah)
                  TextFormField(
                    controller: _kotaManualController,
                    style: AppText.body(context, color: p.title),
                    decoration: _buildInputDecoration(
                      prefixIcon: Icons.location_city,
                      hint: 'Tulis kota/kabupaten (offline)',
                    ),
                  )
                else if (_loadingKota)
                  const LinearProgressIndicator(),
                if (!_manualWilayah && !_loadingKota)
                  _buildWilayahPicker(
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
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.pin_drop_outlined,
                      label: 'Kecamatan',
                    ),
                    _buildSubTag('(menyesuaikan kota)'),
                  ],
                ),
                const SizedBox(height: 8),
                if (_manualWilayah)
                  TextFormField(
                    controller: _kecManualController,
                    style: AppText.body(context, color: p.title),
                    decoration: _buildInputDecoration(
                      prefixIcon: Icons.pin_drop_outlined,
                      hint: 'Tulis kecamatan (offline)',
                    ),
                  )
                else if (_loadingKec)
                  const LinearProgressIndicator(),
                if (!_manualWilayah && !_loadingKec)
                  _buildWilayahPicker(
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
                  ),
                const SizedBox(height: 8),
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
            ),
            const SizedBox(height: 20),

            // Card 2: Kondisi & Budidaya
            _buildCardWrapper(
              title: 'Kondisi & Budidaya',
              sectionTag: 'Seksi 2/2',
              tagColor: p.accentSoft,
              tagTextColor: p.onAccentSoft,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel(
                      icon: Icons.hourglass_top,
                      label: 'Umur Tanaman',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.accentSoft,
                        borderRadius: BorderRadius.circular(
                          AppSpace.radiusPill,
                        ),
                      ),
                      child: Text(
                        _agePhases[_selectedAgeMonth] ?? '',
                        style: AppText.micro(
                          context,
                          color: p.onAccentSoft,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3, 4, 5].map((month) {
                      final isSelected = _selectedAgeMonth == month;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAgeMonth = month),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? p.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppSpace.radiusTile,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$month Bln',
                              style: AppText.body(
                                context,
                                color: isSelected ? p.onPrimary : p.title,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.water_drop_outlined,
                  label: 'Tanggal Terakhir Siram (opsional)',
                ),
                const SizedBox(height: 8),
                _buildDatePicker(
                  value: _tglSiram,
                  hint: 'Pilih tanggal',
                  onPick: (d) => setState(() => _tglSiram = d),
                  onClear: () => setState(() => _tglSiram = null),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.science_outlined,
                  label: 'Tanggal Terakhir Pemupukan (opsional)',
                ),
                const SizedBox(height: 8),
                _buildDatePicker(
                  value: _tglPupuk,
                  hint: 'Pilih tanggal',
                  onPick: (d) => setState(() => _tglPupuk = d),
                  onClear: () => setState(() => _tglPupuk = null),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.water_drop_outlined,
                  label: 'Interval Penyiraman',
                ),
                const SizedBox(height: 8),
                _buildNumberField(
                  controller: _intervalSiramController,
                  hint: 'Contoh: 1',
                  suffix: 'minggu sekali',
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.repeat,
                  label: 'Interval Pemupukan',
                ),
                const SizedBox(height: 8),
                _buildNumberField(
                  controller: _intervalPupukController,
                  hint: 'Contoh: 4',
                  suffix: 'minggu sekali',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Aksi
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpanData,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: p.onPrimary, strokeWidth: 2)
                      )
                    : Icon(Icons.task_alt, color: p.onPrimary),
                label: Text(
                  _isLoading
                      ? 'Menyimpan...'
                      : (_isEdit ? 'Simpan Perubahan' : 'Simpan Data Lahan'),
                  style: AppText.title(context, color: p.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.maybePop(context),
                style: TextButton.styleFrom(
                  backgroundColor: p.surfaceAlt,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                ),
                child: Text(
                  'Batal & Kembali',
                  style: AppText.subtitle(
                    context,
                    color: p.subtitle,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: p.subtitle),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Data lahan dapat diperbarui sewaktu-waktu melalui menu pengaturan.',
                    style: AppText.bodySm(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCardWrapper({
    required String title,
    required String sectionTag,
    required Color tagColor,
    required Color tagTextColor,
    required List<Widget> children,
  }) {
    final p = context.palette;
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 18,
                      decoration: BoxDecoration(
                        color: p.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title(context),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StatusBadge(
                  label: sectionTag,
                  kind: BadgeKind.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel({
    required IconData icon,
    required String label,
    bool isRequired = false,
  }) {
    final p = context.palette;
    return Row(
      children: [
        Icon(icon, size: 16, color: p.accent),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            text: label,
            style: AppText.body(
              context,
              color: p.title,
            ).copyWith(fontWeight: FontWeight.w600),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: AppText.body(
                    context,
                    color: p.error,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTag(String text) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
      child: Text(text, style: AppText.caption(context)),
    );
  }

  InputDecoration _buildInputDecoration({
    required IconData prefixIcon,
    String? hint,
    String? suffixTextBadge,
    Color? badgeBg,
    Color? badgeTextColor,
  }) {
    final p = context.palette;
    final bg = badgeBg ?? p.accentSoft;
    final fg = badgeTextColor ?? p.onAccentSoft;
    return InputDecoration(
      filled: true,
      fillColor: p.surfaceAlt,
      hintText: hint,
      hintStyle: AppText.bodySm(context, color: p.hint),
      prefixIcon: Icon(prefixIcon, color: p.accent, size: 20),
      suffixIcon: suffixTextBadge != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                widthFactor: 1.0,
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                  ),
                  child: Text(
                    suffixTextBadge,
                    style: AppText.micro(
                      context,
                      color: fg,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        borderSide: BorderSide(color: p.primary, width: 1.5),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime? value,
    required String hint,
    required ValueChanged<DateTime> onPick,
    required VoidCallback onClear,
  }) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? now,
                firstDate: DateTime(now.year - 2),
                lastDate: now,
              );
              if (picked != null) onPick(picked);
            },
            icon: Icon(Icons.calendar_today, size: 18, color: p.accent),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value == null ? hint : _tglIndo(value),
                style: value == null
                    ? AppText.bodySm(context, color: p.hint)
                    : AppText.body(context, color: p.title),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: p.surfaceAlt,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpace.radiusTile),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Kosongkan',
            onPressed: onClear,
            icon: Icon(Icons.clear, color: p.icon),
          ),
        ],
      ],
    );
  }

  /// Field pilih wilayah dengan dialog + pencarian (pengganti dropdown
  /// biasa yang kepanjangan dan naik-turun saat item puluhan/ratusan).
  Widget _buildWilayahPicker({
    required IconData icon,
    required String hint,
    required String selected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final p = context.palette;
    final active = enabled;
    return InkWell(
      onTap: active ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? p.surfaceAlt
              : p.surfaceAlt.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? p.accent : p.hint, size: 20),
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
            Icon(Icons.search, color: active ? p.icon : p.hint, size: 20),
          ],
        ),
      ),
    );
  }

  /// Dialog daftar wilayah + kolom cari. Tinggi dikunci agar rapi.
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    required String suffix,
  }) {
    final p = context.palette;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppText.body(context, color: p.title),
      decoration: InputDecoration(
        filled: true,
        fillColor: p.surfaceAlt,
        hintText: hint,
        hintStyle: AppText.bodySm(context, color: p.hint),
        suffixText: suffix,
        suffixStyle: AppText.caption(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusTile),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
      ),
    );
  }
}
