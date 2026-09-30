import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../data/wilayah_data.dart';
import '../models/land_data.dart';
import '../widgets/auth_widgets.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des', //
];

String _formatDate(DateTime d) =>
    '${d.day} ${_monthNames[d.month - 1]} ${d.year}';

String _relativeLabel(DateTime d) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(d.year, d.month, d.day))
      .inDays;
  if (diff <= 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return '$diff hari lalu';
}

/// Dekorasi field: latar lavender tanpa border (sesuai desain).
InputDecoration _fieldDecoration({String? hint, IconData? icon}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      color: AppColors.hint,
    ),
    prefixIcon:
        icon != null ? Icon(icon, size: 22, color: AppColors.icon) : null,
    filled: true,
    fillColor: AppColors.chipBg,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    disabledBorder: border(Colors.transparent),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
  );
}

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _province;
  String? _city;
  String? _district;

  int _ageMonths = 3;
  DateTime? _lastWatered;
  DateTime? _lastFertilized;
  int _intervalWeeks = 1;

  bool _submitted = false;
  bool _isLoading = false;

  // ---------- data dropdown bertingkat ----------
  List<String> get _provinces => wilayahData.keys.toList()..sort();

  List<String> get _cities => _province == null
      ? const []
      : (wilayahData[_province]!.keys.toList()..sort());

  List<String> get _districts => (_province == null || _city == null)
      ? const []
      : wilayahData[_province]![_city]!;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    setState(() => _submitted = true);
    if (!valid || _lastWatered == null || _lastFertilized == null) return;

    setState(() => _isLoading = true);

    final land = LandData(
      name: _nameController.text.trim(),
      province: _province!,
      city: _city!,
      district: _district!,
      plantAgeMonths: _ageMonths,
      lastWatered: _lastWatered!,
      lastFertilized: _lastFertilized!,
      fertilizeIntervalWeeks: _intervalWeeks,
    );

    // TODO: kirim `land.toJson()` ke API
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop(land);
  }

  // ---------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInfoBanner(),
                        const SizedBox(height: 16),
                        _buildIdentitySection(),
                        const SizedBox(height: 16),
                        _buildConditionSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          const Icon(Icons.eco_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Tambah Data Lahan',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.title),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {
              // TODO: buka profil pengguna
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Banner "Kalibrasi Presisi ML"
  // ---------------------------------------------------------------
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE1FB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded,
                    size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalibrasi Presisi ML',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lengkapi parameter kebun untuk kalibrasi algoritma '
                      'pemantauan tanaman cabai Anda secara akurat.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Akurasi deteksi patogen meningkat hingga 94.8%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Seksi 1: Identitas & Lokasi Kebun
  // ---------------------------------------------------------------
  Widget _buildIdentitySection() {
    return _SectionCard(
      title: 'Identitas & Lokasi Kebun',
      badge: 'Seksi 1/2',
      children: [
        // ---------- Nama lahan ----------
        const _LabeledField(
          icon: Icons.label_outline_rounded,
          label: 'Nama Lahan',
          required: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: _fieldDecoration(
            hint: 'Contoh: Petak Cabai Rawit Blok A',
            icon: Icons.grass_rounded,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama lahan wajib diisi';
            }
            if (value.trim().length < 3) return 'Nama lahan terlalu pendek';
            return null;
          },
        ),
        const SizedBox(height: 18),

        // ---------- Provinsi ----------
        const _LabeledField(icon: Icons.map_outlined, label: 'Provinsi'),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _province,
          items: _provinces,
          hint: 'Pilih provinsi',
          errorMsg: 'Provinsi wajib dipilih',
          onChanged: (v) => setState(() {
            _province = v;
            _city = null;
            _district = null;
          }),
        ),
        const SizedBox(height: 18),

        // ---------- Kota / Kabupaten ----------
        const _LabeledField(
          icon: Icons.location_city_rounded,
          label: 'Kota/Kabupaten',
          note: '(menyesuaikan provinsi)',
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _city,
          items: _cities,
          hint: _province == null ? 'Pilih provinsi dulu' : 'Pilih kota/kabupaten',
          errorMsg: 'Kota/Kabupaten wajib dipilih',
          onChanged: _province == null
              ? null
              : (v) => setState(() {
                    _city = v;
                    _district = null;
                  }),
        ),
        const SizedBox(height: 18),

        // ---------- Kecamatan ----------
        const _LabeledField(
          icon: Icons.location_on_outlined,
          label: 'Kecamatan',
          note: '(menyesuaikan kota)',
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _district,
          items: _districts,
          hint: _city == null ? 'Pilih kota/kabupaten dulu' : 'Pilih kecamatan',
          errorMsg: 'Kecamatan wajib dipilih',
          onChanged: _city == null ? null : (v) => setState(() => _district = v),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required String errorMsg,
    required ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.icon),
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Colors.white,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        color: AppColors.title,
      ),
      hint: Text(
        hint,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: AppColors.hint,
        ),
      ),
      decoration: _fieldDecoration(),
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? errorMsg : null,
    );
  }

  // ---------------------------------------------------------------
  // Seksi 2: Kondisi & Budidaya
  // ---------------------------------------------------------------
  Widget _buildConditionSection() {
    return _SectionCard(
      title: 'Kondisi & Budidaya',
      badge: 'Seksi 2/2',
      children: [
        // ---------- Umur tanaman ----------
        _LabeledField(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Umur Tanaman',
          trailing: Text(
            plantPhaseLabels[_ageMonths]!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildAgeSelector(),
        const SizedBox(height: 18),

        // ---------- Terakhir disiram ----------
        const _LabeledField(
          icon: Icons.water_drop_outlined,
          label: 'Tanggal Terakhir Disiram',
        ),
        const SizedBox(height: 8),
        _DateField(
          icon: Icons.calendar_today_outlined,
          value: _lastWatered,
          errorText:
              (_submitted && _lastWatered == null) ? 'Pilih tanggal' : null,
          onTap: () => _pickDate(
            current: _lastWatered,
            onPicked: (d) => setState(() => _lastWatered = d),
          ),
        ),
        const SizedBox(height: 18),

        // ---------- Terakhir pemupukan ----------
        const _LabeledField(
          icon: Icons.eco_outlined,
          label: 'Tanggal Terakhir Pemupukan',
        ),
        const SizedBox(height: 8),
        _DateField(
          icon: Icons.event_available_outlined,
          value: _lastFertilized,
          errorText:
              (_submitted && _lastFertilized == null) ? 'Pilih tanggal' : null,
          onTap: () => _pickDate(
            current: _lastFertilized,
            onPicked: (d) => setState(() => _lastFertilized = d),
          ),
        ),
        const SizedBox(height: 18),

        // ---------- Interval pemupukan ----------
        const _LabeledField(
          icon: Icons.repeat_rounded,
          label: 'Interval Pemupukan',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildIntervalButton(1, '1 Minggu')),
            const SizedBox(width: 12),
            Expanded(child: _buildIntervalButton(2, '2 Minggu')),
          ],
        ),
      ],
    );
  }

  // Segmented control 1 Bln .. 5 Bln
  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var m = 1; m <= 5; m++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _ageMonths = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _ageMonths == m
                        ? AppColors.primaryDark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$m Bln',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          _ageMonths == m ? FontWeight.w800 : FontWeight.w500,
                      color:
                          _ageMonths == m ? Colors.white : AppColors.title,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tombol interval "1 Minggu" / "2 Minggu"
  Widget _buildIntervalButton(int weeks, String label) {
    final selected = _intervalWeeks == weeks;
    return GestureDetector(
      onTap: () => setState(() => _intervalWeeks = weeks),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
              size: 20,
              color: selected ? Colors.white : AppColors.icon,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.title,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Bar bawah: tombol simpan + catatan
  // ---------------------------------------------------------------
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Simpan Data Lahan',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.icon),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Data lahan dapat diperbarui sewaktu-waktu melalui '
                        'menu pengaturan.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          height: 1.4,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Kartu seksi: bar hijau + judul + badge "Seksi x/2"
/// ---------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final String badge;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.badge,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Label di atas field: [ikon] Label * ........ catatan
/// ---------------------------------------------------------------
class _LabeledField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;
  final String? note;
  final Widget? trailing;

  const _LabeledField({
    required this.icon,
    required this.label,
    this.required = false,
    this.note,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.icon),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        const Spacer(),
        if (note != null)
          Text(
            note!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.subtitle,
            ),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// ---------------------------------------------------------------
/// Field tanggal: tap untuk membuka date picker
/// ---------------------------------------------------------------
class _DateField extends StatelessWidget {
  final IconData icon;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  const _DateField({
    required this.icon,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final date = value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: _fieldDecoration().copyWith(
          prefixIcon: Icon(icon, size: 22, color: AppColors.primary),
          errorText: errorText,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null ? 'Pilih tanggal' : _formatDate(date),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: date == null ? AppColors.hint : AppColors.title,
                ),
              ),
            ),
            if (date != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _relativeLabel(date),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}