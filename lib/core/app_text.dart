import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

/// Sistem tipografi tunggal Capsee.
///
/// Semua layar WAJIB memakai helper ini agar font, ukuran, ketebalan,
/// dan warna konsisten di mode terang maupun gelap.
///
/// Skala:
/// - display  : judul halaman (22, w800)
/// - headline : judul seksi (18, w700)
/// - title    : judul kartu (16, w700)
/// - subtitle : sub-judul / aksi (14, w700)
/// - body     : isi (13, w400) & bodySm (12)
/// - caption  : keterangan kecil (11) & micro (10)
/// - overline : label kapital kecil (11, w700, spacing)
class AppText {
  AppText._();

  static TextStyle _base(
    BuildContext context,
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle display(BuildContext context, {Color? color}) =>
      _base(context, 22, FontWeight.w800, color ?? context.palette.title);

  static TextStyle headline(BuildContext context, {Color? color}) =>
      _base(context, 18, FontWeight.w700, color ?? context.palette.title);

  static TextStyle title(BuildContext context, {Color? color}) =>
      _base(context, 16, FontWeight.w700, color ?? context.palette.title);

  static TextStyle subtitle(BuildContext context, {Color? color}) =>
      _base(context, 14, FontWeight.w700, color ?? context.palette.title);

  static TextStyle body(BuildContext context, {Color? color}) => _base(
        context,
        13,
        FontWeight.w400,
        color ?? context.palette.subtitle,
        height: 1.45,
      );

  static TextStyle bodySm(BuildContext context, {Color? color}) => _base(
        context,
        12,
        FontWeight.w400,
        color ?? context.palette.subtitle,
        height: 1.4,
      );

  static TextStyle caption(BuildContext context, {Color? color}) =>
      _base(context, 11, FontWeight.w500, color ?? context.palette.subtitle);

  static TextStyle micro(BuildContext context, {Color? color}) =>
      _base(context, 10, FontWeight.w600, color ?? context.palette.hint);

  static TextStyle overline(BuildContext context, {Color? color}) => _base(
        context,
        11,
        FontWeight.w700,
        color ?? context.palette.subtitle,
        letterSpacing: 1.0,
      );

  static TextStyle badge(BuildContext context, {Color? color}) =>
      _base(context, 11, FontWeight.w800, color ?? context.palette.accent);
}

/// Token jarak & radius tunggal agar bentuk konsisten.
class AppSpace {
  AppSpace._();

  static const double page = 16;
  static const double card = 16;
  static const double tile = 12;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;

  static const double radiusCard = 16;
  static const double radiusTile = 12;
  static const double radiusPill = 999;
}
