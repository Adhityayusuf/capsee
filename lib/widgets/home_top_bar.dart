import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAPSEE',
                style: _style(
                  10,
                  AppColors.primary,
                  FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                title,
                style: _style(18, AppColors.title, FontWeight.w700, height: 1),
              ),
            ],
          ),
          const Spacer(),
          _bellButton(),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onAkun,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Ikon lonceng dengan badge jumlah notifikasi belum dibaca.
  Widget _bellButton() => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        onPressed: onNotifikasi,
        tooltip: 'Notifikasi',
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.title,
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
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              textAlign: TextAlign.center,
              style: _style(9, Colors.white, FontWeight.w700, height: 1.2),
            ),
          ),
        ),
    ],
  );
}
