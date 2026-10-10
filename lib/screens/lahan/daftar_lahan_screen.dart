import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../widgets/home_top_bar.dart';
import '../../widgets/land_card.dart';

TextStyle _style(
  double size,
  Color color,
  FontWeight weight, {
  double? height,
  double? letterSpacing,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
  letterSpacing: letterSpacing,
);

/// Tab "Lahan" — daftar seluruh petak milik pengguna.
///
/// Data dimiliki oleh [DashboardScreen] dan diteruskan ke sini agar tidak
/// terjadi pemanggilan API ganda saat berpindah tab.
class DaftarLahanScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? lahanList;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic> land) onOpenDetail;
  final void Function(Map<String, dynamic> land) onEditLand;
  final void Function(Map<String, dynamic> land) onDeleteLand;
  final VoidCallback onScan;
  final int unreadCount;
  final VoidCallback onNotifikasi;
  final VoidCallback onAkun;

  const DaftarLahanScreen({
    super.key,
    required this.lahanList,
    required this.isLoading,
    required this.onRefresh,
    required this.onAdd,
    required this.onOpenDetail,
    required this.onEditLand,
    required this.onDeleteLand,
    required this.onScan,
    required this.unreadCount,
    required this.onNotifikasi,
    required this.onAkun,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          HomeTopBar(
            title: 'Lahan',
            unreadCount: unreadCount,
            onNotifikasi: onNotifikasi,
            onAkun: onAkun,
          ),
          _header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: _body(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        const Icon(Icons.grass_rounded, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Lahan Anda',
            style: _style(17, AppColors.title, FontWeight.w700),
          ),
        ),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Tambah'),
        ),
      ],
    ),
  );

  Widget _body(BuildContext context) {
    if (lahanList == null || lahanList!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: [
          Icon(
            Icons.eco_outlined,
            size: 56,
            color: AppColors.primary.withAlpha(120),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data lahan.',
            textAlign: TextAlign.center,
            style: _style(15, AppColors.title, FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan petak lahan pertama Anda untuk mulai memantau '
            'kondisi tanaman cabai.',
            textAlign: TextAlign.center,
            style: _style(12, AppColors.subtitle, FontWeight.w400, height: 1.4),
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Tambah Lahan Baru'),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: lahanList!.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, index) {
        final land = lahanList![index];
        return LandCard(
          land: land,
          onDetail: () => onOpenDetail(land),
          onEdit: () => onEditLand(land),
          onDelete: () => onDeleteLand(land),
          onScan: onScan,
        );
      },
    );
  }
}
