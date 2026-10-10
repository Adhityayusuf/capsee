import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';

/// Bar atas Beranda dan tab Lahan: logo, judul, lonceng notifikasi, dan avatar.
///
/// Dipakai bersama agar profil & notifikasi selalu terjangkau dari kedua tab.
class HomeTopBar extends StatelessWidget {
  final String title;
  final int unreadCount;
  final VoidCallback onNotifikasi;
  final VoidCallback onAkun;

  const HomeTopBar({
    super.key,
    required this.title,
    required this.unreadCount,
    required this.onNotifikasi,
    required this.onAkun,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.surface,
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: Icon(Icons.eco_rounded, color: p.onPrimary, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CAPSEE', style: AppText.overline(context, color: p.accent)),
              Text(title, style: AppText.headline(context)),
            ],
          ),
          const Spacer(),
          _bellButton(context),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onAkun,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: p.primary,
              child: Icon(Icons.person_rounded, color: p.onPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Ikon lonceng dengan badge jumlah notifikasi belum dibaca.
  Widget _bellButton(BuildContext context) {
    final p = context.palette;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onNotifikasi,
          tooltip: 'Notifikasi',
          icon: Icon(
            Icons.notifications_none_rounded,
            color: p.title,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 3,
            top: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: p.error,
                borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                border: Border.all(color: p.surface, width: 1.5),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: AppText.micro(
                  context,
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
          ),
      ],
    );
  }
}
