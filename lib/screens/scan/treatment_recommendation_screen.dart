import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../models/treatment_recommendation.dart';
import '../../widgets/ui_kit.dart';

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

  BadgeKind _badgeKindFor(TreatmentOption option) {
    if (option.badgeColor == AppColors.warningSoft) return BadgeKind.warning;
    if (option.badgeColor == AppColors.infoSoft) return BadgeKind.info;
    return BadgeKind.success;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final option = sampleTreatmentOptions[_selectedOption];

    return Scaffold(
      backgroundColor: p.background,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.page, 12, AppSpace.page, 24),
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
                        Icon(Icons.qr_code_2_rounded,
                            size: 14, color: p.icon),
                        const SizedBox(width: 6),
                        Text(
                          'ID Diagnosa ${widget.diagnosis.diagnosisId}',
                          style: AppText.caption(context)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  _buildDiagnosisCard(),
                  const SizedBox(height: AppSpace.gapMd),
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
                      const SizedBox(width: AppSpace.gapMd),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.verified_rounded,
                          iconColor: p.onAccentSoft,
                          iconBg: p.accentSoft,
                          label: 'Akurasi Model AI',
                          value:
                              '${widget.diagnosis.aiAccuracyPercent}% Validasi Optik',
                          progress: widget.diagnosis.aiAccuracyPercent / 100,
                          progressColor: p.primary,
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
                      label: const Text('Simpan ke Riwayat Tanaman'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpace.radiusTile),
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
    final p = context.palette;
    return AppBar(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: p.border)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: p.title),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Rekomendasi Penanganan',
        style: AppText.subtitle(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.ios_share_rounded, color: p.icon),
          onPressed: () => _showTodo('Bagikan rekomendasi belum dibuat'),
        ),
        IconButton(
          icon: Icon(Icons.bookmark_border_rounded,
              color: p.icon),
          onPressed: () => _showTodo('Simpan cepat belum dibuat'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // Kartu ringkasan diagnosis
  // ---------------------------------------------------------------
  Widget _buildDiagnosisCard() {
    final p = context.palette;
    final d = widget.diagnosis;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius:
                  BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(Icons.eco_outlined,
                size: 26, color: p.icon),
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
                        style: AppText.body(context, color: p.subtitle)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(
                      label: d.statusLabel,
                      kind: BadgeKind.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  d.diseaseName,
                  style: AppText.title(context),
                ),
                const SizedBox(height: 2),
                Text(
                  d.latinName,
                  style: AppText.bodySm(context, color: p.subtitle)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 6),
                Text(
                  d.dateTime,
                  style: AppText.caption(context),
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
    final p = context.palette;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
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
            style: AppText.caption(context),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppText.subtitle(context, color: p.title)
                .copyWith(fontSize: 12.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSpace.radiusPill),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: p.surfaceAlt,
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
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.flag_rounded,
          title: 'Langkah Tindakan Segera',
          trailing: StatusBadge(
            label: 'Hari Ini',
            kind: BadgeKind.success,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lakukan isolasi mekanis dalam 24 jam pertama agar spora tidak '
          'terbawa percikan air atau angin ke bibit sehat di sekitarnya.',
          style: AppText.body(context),
        ),
        const SizedBox(height: 14),
        CapseeCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < sampleActionSteps.length; i++) ...[
                _buildActionStepTile(sampleActionSteps[i]),
                if (i != sampleActionSteps.length - 1)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    child: Divider(height: 1, color: p.border),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionStepTile(ActionStep step) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: p.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 17, color: p.onAccentSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppText.body(context, color: p.title)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: AppText.bodySm(context),
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
        const SectionHeader(
          icon: Icons.medical_services_outlined,
          title: 'Opsi Solusi Penanganan',
          trailing: StatusBadge(
            label: 'Terverifikasi',
            kind: BadgeKind.info,
          ),
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
    final p = context.palette;
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
                      ? p.primary
                      : p.surface,
                  borderRadius: BorderRadius.circular(
                      AppSpace.radiusTile),
                  border: Border.all(
                    color: _selectedOption == i
                        ? p.primary
                        : p.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      sampleTreatmentOptions[i].tabLabel,
                      style: AppText.subtitle(context,
                          color: _selectedOption == i
                              ? p.onPrimary
                              : p.title),
                    ),
                    if (sampleTreatmentOptions[i].recommended) ...[
                      const SizedBox(height: 2),
                      Text(
                        '(Direkomendasikan)',
                        style: AppText.micro(context,
                          color: _selectedOption == i
                              ? p.onPrimary.withValues(alpha: 0.7)
                              : p.subtitle,
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
    final p = context.palette;
    return CapseeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  option.title,
                  style: AppText.subtitle(context,
                          color: p.title)
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: option.badge,
                kind: _badgeKindFor(option),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            option.description,
            style: AppText.body(context),
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
            padding: const EdgeInsets.all(AppSpace.tile),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius:
                  BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.water_drop_outlined,
                    size: 16, color: p.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.applicationNote,
                    style: AppText.bodySm(context, color: p.title),
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
    final p = context.palette;
    return Column(
      children: [
        Icon(icon, size: 16, color: p.accent),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.micro(context, color: p.subtitle),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppText.caption(context, color: p.title)
              .copyWith(fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOptionDivider() {
    final p = context.palette;
    return Container(
      width: 1,
      height: 44,
      color: p.border,
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
        const SectionHeader(
          icon: Icons.shield_outlined,
          title: 'Pencegahan Jangka Panjang',
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
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infoBg = isDark ? const Color(0xFF0F2A3A) : AppColors.infoSoft;
    final infoFg = isDark ? const Color(0xFF7DD3FC) : AppColors.info;
    return CapseeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius:
                  BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(tip.icon, size: 18, color: infoFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: AppText.body(context, color: p.title)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: AppText.bodySm(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
