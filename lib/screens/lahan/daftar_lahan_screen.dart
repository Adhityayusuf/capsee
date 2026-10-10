import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/home_top_bar.dart';
import '../../widgets/land_card.dart';
import '../../widgets/ui_kit.dart';

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
    final p = context.palette;
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
          _header(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: _body(context, p),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(
      AppSpace.page,
      AppSpace.gapMd,
      AppSpace.page,
      AppSpace.gapSm,
    ),
    child: SectionHeader(
      icon: Icons.grass_rounded,
      title: 'Lahan Anda',
      trailing: FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Tambah'),
      ),
    ),
  );

  Widget _body(BuildContext context, AppPalette p) {
    if (lahanList == null || lahanList!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: [
          EmptyState(
            icon: Icons.eco_outlined,
            title: 'Belum ada data lahan.',
            message: 'Tambahkan petak lahan pertama Anda untuk mulai memantau '
                'kondisi tanaman cabai.',
            actionLabel: 'Tambah Lahan Baru',
            onAction: onAdd,
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
