import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/land_data.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';

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
  late final TextEditingController _siramController;
  late final TextEditingController _pupukController;

  // State Dropdown
  late String _selectedProvince;
  late String _selectedCity;
  late String _selectedDistrict;

  // State Umur Tanaman & Interval
  late int _selectedAgeMonth;
  late int _selectedIntervalWeek;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _namaLahanController = TextEditingController(
      text: initial?.name ?? 'Petak Cabai Rawit Blok A',
    );
    _siramController = TextEditingController(text: '24 Okt 2024');
    _pupukController = TextEditingController(text: '18 Okt 2024');
    _selectedProvince = _matchProvince(initial?.province);
    _selectedCity = _matchCity(initial?.city);
    _selectedDistrict = _matchDistrict(initial?.district);
    _selectedAgeMonth = (initial?.plantAgeMonths ?? 3).clamp(1, 5).toInt();
    _selectedIntervalWeek = initial?.fertilizeIntervalWeeks ?? 1;
  }

  // Nilai dropdown memakai kode; petakan juga nama lengkap dari backend.
  static String _matchProvince(String? value) => switch ((value ?? '').toLowerCase()) {
        'jabar' || 'jawa barat' => 'jabar',
        'jateng' || 'jawa tengah' => 'jateng',
        'jatim' || 'jawa timur' => 'jatim',
        'sumut' || 'sumatera utara' => 'sumut',
        _ => 'jabar',
      };

  static String _matchCity(String? value) => switch ((value ?? '').toLowerCase()) {
        'kbb' || 'kab. bandung barat' || 'bandung barat' => 'kbb',
        'bdg' || 'kab. bandung' || 'bandung' => 'bdg',
        'grt' || 'kab. garut' || 'garut' => 'grt',
        'cjr' || 'kab. cianjur' || 'cianjur' => 'cjr',
        _ => 'kbb',
      };

  static String _matchDistrict(String? value) => switch ((value ?? '').toLowerCase()) {
        'lembang' => 'lembang',
        'parongpong' => 'parongpong',
        'cisarua' => 'cisarua',
        'ngamprah' => 'ngamprah',
        _ => 'lembang',
      };

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
    _siramController.dispose();
    _pupukController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _simpanData() async {
    if (_namaLahanController.text.trim().isEmpty) {
      showErrorPopup(context, 'Nama lahan tidak boleh kosong.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nama = _namaLahanController.text.trim();
      final Map<String, dynamic> lahan;

      if (_isEdit) {
        final id = widget.idLahan ?? widget.initial?.id;
        if (id == null || id.isEmpty) {
          throw ApiException('ID lahan tidak ditemukan.', 0);
        }
        lahan = await editLahan(
          id,
          nama: nama,
          provinsi: _selectedProvince,
          kota: _selectedCity,
          kecamatan: _selectedDistrict,
          umurTanamanBulan: _selectedAgeMonth,
          intervalPupukMinggu: _selectedIntervalWeek,
        );
      } else {
        lahan = await tambahLahan(
          nama: nama,
          provinsi: _selectedProvince,
          kota: _selectedCity,
          kecamatan: _selectedDistrict,
          umurTanamanBulan: _selectedAgeMonth,
          intervalPupukMinggu: _selectedIntervalWeek,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (mounted) {
        showSuccessPopup(
          context,
          _isEdit
              ? 'Data kebun berhasil diperbarui!'
              : 'Data kebun berhasil ditambahkan!',
        );
      }

      // Pop dan kirimkan data lahan terbaru agar pemanggil bisa merefresh.
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.maybePop(context, lahan);
      });
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
                style: TextStyle(
                  color: p.title,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.accentSoft,
                          borderRadius: BorderRadius.circular(12),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: p.title,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lengkapi parameter kebun untuk kalibrasi algoritma pemantauan tanaman cabai Anda secara akurat.',
                              style: TextStyle(
                                fontSize: 12,
                                color: p.subtitle,
                                height: 1.4,
                              ),
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
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                  style: TextStyle(color: p.title),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.label_outline,
                    hint: 'Misal: Petak Cabai Rawit Blok A',
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(icon: Icons.map_outlined, label: 'Provinsi'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedProvince,
                  items: const [
                    DropdownMenuItem(value: 'jabar', child: Text('Jawa Barat')),
                    DropdownMenuItem(
                      value: 'jateng',
                      child: Text('Jawa Tengah'),
                    ),
                    DropdownMenuItem(value: 'jatim', child: Text('Jawa Timur')),
                    DropdownMenuItem(
                      value: 'sumut',
                      child: Text('Sumatera Utara'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedProvince = val!),
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
                _buildDropdown(
                  value: _selectedCity,
                  items: const [
                    DropdownMenuItem(
                      value: 'kbb',
                      child: Text('Kab. Bandung Barat'),
                    ),
                    DropdownMenuItem(value: 'bdg', child: Text('Kab. Bandung')),
                    DropdownMenuItem(value: 'grt', child: Text('Kab. Garut')),
                    DropdownMenuItem(value: 'cjr', child: Text('Kab. Cianjur')),
                  ],
                  onChanged: (val) => setState(() => _selectedCity = val!),
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
                _buildDropdown(
                  value: _selectedDistrict,
                  items: const [
                    DropdownMenuItem(value: 'lembang', child: Text('Lembang')),
                    DropdownMenuItem(
                      value: 'parongpong',
                      child: Text('Parongpong'),
                    ),
                    DropdownMenuItem(value: 'cisarua', child: Text('Cisarua')),
                    DropdownMenuItem(
                      value: 'ngamprah',
                      child: Text('Ngamprah'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedDistrict = val!),
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _agePhases[_selectedAgeMonth] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: p.onAccentSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$month Bln',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? p.onPrimary : p.title,
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
                  label: 'Tanggal Terakhir Siram',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _siramController,
                  style: TextStyle(color: p.title),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.calendar_today,
                    suffixTextBadge: 'Hari ini',
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.science_outlined,
                  label: 'Tanggal Terakhir Pemupukan',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pupukController,
                  style: TextStyle(color: p.title),
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.compost,
                    suffixTextBadge: '6 hari lalu',
                    badgeBg: p.surfaceAlt,
                    badgeTextColor: p.title,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(
                  icon: Icons.repeat,
                  label: 'Interval Pemupukan',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildIntervalButton(
                        weeks: 1,
                        label: '1 Minggu',
                        isSelected: _selectedIntervalWeek == 1,
                        onTap: () => setState(() => _selectedIntervalWeek = 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIntervalButton(
                        weeks: 2,
                        label: '2 Minggu',
                        isSelected: _selectedIntervalWeek == 2,
                        onTap: () => setState(() => _selectedIntervalWeek = 2),
                      ),
                    ),
                  ],
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: p.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Batal & Kembali',
                  style: TextStyle(
                    color: p.subtitle,
                    fontWeight: FontWeight.w600,
                  ),
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
                    style: TextStyle(fontSize: 12, color: p.subtitle),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: p.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sectionTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tagTextColor,
                    ),
                  ),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: p.title,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: p.error,
                    fontWeight: FontWeight.bold,
                  ),
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: p.subtitle)),
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
      hintStyle: TextStyle(color: p.hint),
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    suffixTextBadge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: fg,
                    ),
                  ),
                ),
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.primary, width: 1.5),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final p = context.palette;
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      icon: Icon(Icons.expand_more, color: p.icon),
      dropdownColor: p.surface,
      style: TextStyle(color: p.title),
      decoration: InputDecoration(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildIntervalButton({
    required int weeks,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? p.primary : p.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: p.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.schedule,
              color: isSelected ? p.onPrimary : p.icon,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? p.onPrimary : p.title,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
