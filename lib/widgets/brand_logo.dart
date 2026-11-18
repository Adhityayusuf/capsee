import 'package:flutter/material.dart';

/// Aset logo Capsee. Gambar sudah punya latar transparan.
class BrandAssets {
  BrandAssets._();

  static const mark = 'assets/branding/capsee_mark.png';
  static const fullLogo = 'assets/branding/capsee_logo.png';
}

/// Ikon cabai Capsee (tanpa teks). Dipakai di header, tombol, dan logo auth.
class CapseeMark extends StatelessWidget {
  final double size;
  const CapseeMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandAssets.mark,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Logo lengkap Capsee: ikon + nama + tagline. Dipakai di splash/loading.
class CapseeFullLogo extends StatelessWidget {
  final double width;
  const CapseeFullLogo({super.key, this.width = 220});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandAssets.fullLogo,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
