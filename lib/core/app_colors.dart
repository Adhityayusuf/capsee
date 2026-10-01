import 'package:flutter/material.dart';

/// Warna yang dipakai di seluruh aplikasi Capsee.
class AppColors {
  AppColors._();

  static const background = Color(0xFFF7F7FF);
  static const primary = Color(0xFF15803D); // hijau tombol
  static const primaryDark = Color(0xFF166534); // hijau link / checkbox
  static const primarySoft = Color(0xFFDCFCE7); // hijau muda (badge, logo)
  static const glow = Color(0xFFBBF7D0);

  static const title = Color(0xFF1B2B34);
  static const subtitle = Color(0xFF4B5563);
  static const hint = Color(0xFF9CA3AF);
  static const icon = Color(0xFF6B7280);

  static const border = Color(0xFFE5E7EB);
  static const chipBg = Color(0xFFF1F2FC);
  static const error = Color(0xFFDC2626);

  // Warna transparan (ditulis langsung supaya aman di semua versi Flutter)
  static const shadow = Color(0x0A000000);
  static const primaryShadow = Color(0x2615803D);
  static const primaryDisabled = Color(0x9915803D);
}
