import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../models/treatment_recommendation.dart';

class TreatmentRecommendationScreen extends StatefulWidget {
  final DiagnosisSummary diagnosis;

  const TreatmentRecommendationScreen({
    super.key,
    this.diagnosis = sampleDiagnosisSummary,
  });

  @override
  State<TreatmentRecommendationScreen> createState() =>
      _TreatmentRecommendationScreenState();
}

class _TreatmentRecommendationScreenState
    extends State<TreatmentRecommendationScreen> {
  int _selectedOption = 0; // index ke sampleTreatmentOptions

  void _showTodo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final option = sampleTreatmentOptions[_selectedOption];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded,
                            size: 14, color: AppColors.icon),
                        const SizedBox(width: 6),
                        Text(
                          'ID Diagnosa ${widget.diagnosis.diagnosisId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDiagnosisCard(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppColors.warning,
                          iconBg: AppColors.warningSoft,
                          label: 'Tingkat Keparahan',
                          value: widget.diagnosis.severityLabel,
                          progress: widget.diagnosis.severityProgress,
                          progressColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.verified_rounded,
                          iconColor: AppColors.primaryDark,
                          iconBg: AppColors.primarySoft,
                          label: 'Akurasi Model AI',
                          value:
                              '${widget.diagnosis.aiAccuracyPercent}% Validasi Optik',
                          progress: widget.diagnosis.aiAccuracyPercent / 100,
                          progressColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildImmediateActionSection(),
                  const SizedBox(height: 22),
                  _buildTreatmentOptionSection(option),
                  const SizedBox(height: 22),
                  _buildPreventionSection(),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showTodo('Rekomendasi disimpan ke riwayat tanaman'),
                      icon: const Icon(Icons.bookmark_added_outlined,
                          size: 20),
                      label: Text(
                        'Simpan ke Riwayat Tanaman',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Rekomendasi Penanganan',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: AppColors.title,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share_rounded, color: AppColors.icon),
          onPressed: () => _showTodo('Bagikan rekomendasi belum dibuat'),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border_rounded,
              color: AppColors.icon),
          onPressed: () => _showTodo('Simpan cepat belum dibuat'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Kartu ringkasan diagnosis
  // ---------------------------------------------------------------
  Widget _buildDiagnosisCard() {
    final d = widget.diagnosis;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_outlined,
                size: 26, color: AppColors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.plantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        d.statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  d.diseaseName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.latinName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.dateTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Kartu metrik kecil (keparahan / akurasi)
  // ---------------------------------------------------------------
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: AppColors.subtitle,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.chipBg,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Seksi "Langkah Tindakan Segera"
  // ---------------------------------------------------------------
  Widget _buildImmediateActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🚩 ', style: TextStyle(fontSize: 15)),
            Expanded(
              child: Text(
                'Langkah Tindakan Segera',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
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
                'Hari Ini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Lakukan isolasi mekanis dalam 24 jam pertama agar spora tidak '
          'terbawa percikan air atau angin ke bibit sehat di sekitarnya.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.45,
            color: AppColors.subtitle,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < sampleActionSteps.length; i++) ...[
                _buildActionStepTile(sampleActionSteps[i], i + 1),
                if (i != sampleActionSteps.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionStepTile(ActionStep step, int number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 17, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Seksi "Opsi Solusi Penanganan"
  // ---------------------------------------------------------------
  Widget _buildTreatmentOptionSection(TreatmentOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Opsi Solusi Penanganan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.title,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: AppColors.primaryDark),
                  const SizedBox(width: 5),
                  Text(
                    'Terverifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOptionTabs(),
        const SizedBox(height: 12),
        _buildOptionDetailCard(option),
      ],
    );
  }

  // Tab pilihan Organik / Kimia
  Widget _buildOptionTabs() {
    return Row(
      children: [
        for (var i = 0; i < sampleTreatmentOptions.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedOption = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedOption == i
                      ? AppColors.primaryDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedOption == i
                        ? AppColors.primaryDark
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      sampleTreatmentOptions[i].tabLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _selectedOption == i
                            ? Colors.white
                            : AppColors.title,
                      ),
                    ),
                    if (sampleTreatmentOptions[i].recommended) ...[
                      const SizedBox(height: 2),
                      Text(
                        '(Direkomendasikan)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _selectedOption == i
                              ? Colors.white70
                              : AppColors.subtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Kartu detail opsi terpilih
  Widget _buildOptionDetailCard(TreatmentOption option) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  option.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: option.badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option.badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: option.badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            option.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.45,
              color: AppColors.subtitle,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildOptionStat(
                    Icons.science_outlined, 'Dosis', option.dosis),
              ),
              _buildOptionDivider(),
              Expanded(
                child: _buildOptionStat(Icons.schedule_rounded,
                    'Waktu Aplikasi', option.waktuAplikasi),
              ),
              _buildOptionDivider(),
              Expanded(
                child: _buildOptionStat(
                    Icons.repeat_rounded, 'Frekuensi', option.frekuensi),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.water_drop_outlined,
                    size: 16, color: AppColors.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.applicationNote,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryDark),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: AppColors.subtitle,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionDivider() {
    return Container(
      width: 1,
      height: 44,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  // ---------------------------------------------------------------
  // Seksi "Pencegahan Jangka Panjang"
  // ---------------------------------------------------------------
  Widget _buildPreventionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pencegahan Jangka Panjang',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 12),
        for (final tip in samplePreventionTips) ...[
          _buildPreventionCard(tip),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildPreventionCard(PreventionTip tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip.icon, size: 18, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}