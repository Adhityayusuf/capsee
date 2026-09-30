import 'package:flutter/material.dart';

class TambahLahanPage extends StatefulWidget {
  const TambahLahanPage({super.key});

  @override
  State<TambahLahanPage> createState() => _TambahLahanPageState();
}

class _TambahLahanPageState extends State<TambahLahanPage> {
  // Controller input
  final TextEditingController _namaLahanController =
      TextEditingController(text: 'Petak Cabai Rawit Blok A');
  final TextEditingController _siramController =
      TextEditingController(text: '24 Okt 2024');
  final TextEditingController _pupukController =
      TextEditingController(text: '18 Okt 2024');

  // State Dropdown
  String _selectedProvince = 'jabar';
  String _selectedCity = 'kbb';
  String _selectedDistrict = 'lembang';

  // State Umur Tanaman & Interval
  int _selectedAgeMonth = 3;
  int _selectedIntervalWeek = 1;

  final Map<int, String> _agePhases = {
    1: 'Fase Vegetatif Awal',
    2: 'Fase Vegetatif Aktif',
    3: 'Fase Berbunga & Berbuah',
    4: 'Fase Pematangan Buah',
    5: 'Fase Panen Berkala',
  };

  // Warna sesuai tema Capsee
  static const Color primaryGreen = Color(0xFF00652C);
  static const Color lightGreenBg = Color(0xFFE8F5E9);
  static const Color surfaceBg = Color(0xFFF9FAFD);
  static const Color cardFieldBg = Color(0xFFF1F3F9);
  static const Color textDark = Color(0xFF131B2E);
  static const Color textMuted = Color(0xFF5E6A75);

  @override
  void dispose() {
    _namaLahanController.dispose();
    _siramController.dispose();
    _pupukController.dispose();
    super.dispose();
  }

  void _simpanData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF283044),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified, color: Color(0xFF6BFF8F), size: 20),
            SizedBox(width: 8),
            Text(
              'Data kebun berhasil diperbarui!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.eco, color: primaryGreen, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tambah Data Lahan',
                style: TextStyle(
                  color: textDark,
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
            icon: const Icon(Icons.close, color: textMuted),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: primaryGreen,
              child: Icon(Icons.person, color: Colors.white, size: 18),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco, color: primaryGreen, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kalibrasi Presisi ML',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Lengkapi parameter kebun untuk kalibrasi algoritma pemantauan tanaman cabai Anda secara akurat.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textMuted,
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
                    children: const [
                      Icon(Icons.auto_awesome, color: primaryGreen, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Akurasi deteksi patogen meningkat hingga 94.8%',
                          style: TextStyle(
                            color: primaryGreen,
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
              tagColor: lightGreenBg,
              tagTextColor: primaryGreen,
              children: [
                _buildFieldLabel(icon: Icons.grass, label: 'Nama Lahan', isRequired: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaLahanController,
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
                    DropdownMenuItem(value: 'jateng', child: Text('Jawa Tengah')),
                    DropdownMenuItem(value: 'jatim', child: Text('Jawa Timur')),
                    DropdownMenuItem(value: 'sumut', child: Text('Sumatera Utara')),
                  ],
                  onChanged: (val) => setState(() => _selectedProvince = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel(icon: Icons.location_city, label: 'Kota / Kabupaten'),
                    _buildSubTag('(menyesuaikan provinsi)'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedCity,
                  items: const [
                    DropdownMenuItem(value: 'kbb', child: Text('Kab. Bandung Barat')),
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
                    _buildFieldLabel(icon: Icons.pin_drop_outlined, label: 'Kecamatan'),
                    _buildSubTag('(menyesuaikan kota)'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedDistrict,
                  items: const [
                    DropdownMenuItem(value: 'lembang', child: Text('Lembang')),
                    DropdownMenuItem(value: 'parongpong', child: Text('Parongpong')),
                    DropdownMenuItem(value: 'cisarua', child: Text('Cisarua')),
                    DropdownMenuItem(value: 'ngamprah', child: Text('Ngamprah')),
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
              tagColor: const Color(0xFFE8F5E9),
              tagTextColor: primaryGreen,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel(icon: Icons.hourglass_top, label: 'Umur Tanaman'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: lightGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _agePhases[_selectedAgeMonth] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardFieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3, 4, 5].map((month) {
                      final isSelected = _selectedAgeMonth == month;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAgeMonth = month),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$month Bln',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(icon: Icons.water_drop_outlined, label: 'Tanggal Terakhir Siram'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _siramController,
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.calendar_today,
                    suffixTextBadge: 'Hari ini',
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(icon: Icons.science_outlined, label: 'Tanggal Terakhir Pemupukan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pupukController,
                  decoration: _buildInputDecoration(
                    prefixIcon: Icons.compost,
                    suffixTextBadge: '6 hari lalu',
                    badgeBg: const Color(0xFFE2E7FF),
                    badgeTextColor: textDark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel(icon: Icons.repeat, label: 'Interval Pemupukan'),
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
                onPressed: _simpanData,
                icon: const Icon(Icons.task_alt, color: Colors.white),
                label: const Text(
                  'Simpan Data Lahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  backgroundColor: cardFieldBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Batal & Kembali',
                  style: TextStyle(color: textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline, size: 16, color: textMuted),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Data lahan dapat diperbarui sewaktu-waktu melalui menu pengaturan.',
                    style: TextStyle(fontSize: 12, color: textMuted),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sectionTag,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tagTextColor),
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

  Widget _buildFieldLabel({required IconData icon, required String label, bool isRequired = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryGreen),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cardFieldBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: textMuted)),
    );
  }

  InputDecoration _buildInputDecoration({
    required IconData prefixIcon,
    String? hint,
    String? suffixTextBadge,
    Color badgeBg = const Color(0xFFC8E6C9),
    Color badgeTextColor = primaryGreen,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: cardFieldBg,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: primaryGreen, size: 20),
      suffixIcon: suffixTextBadge != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Align(
                widthFactor: 1.0,
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    suffixTextBadge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
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
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.expand_more, color: textMuted),
      decoration: InputDecoration(
        filled: true,
        fillColor: cardFieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : cardFieldBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.schedule,
              color: isSelected ? Colors.white : textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textDark,
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