import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';

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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.eco_rounded, color: p.onPrimary, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAPSEE',
                style: _style(
                  10,
                  p.accent,
                  FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                title,
                style: _style(18, p.title, FontWeight.w700, height: 1),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.surface, width: 1.5),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: _style(
                  9,
                  isDark ? p.surface : Colors.white,
                  FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
