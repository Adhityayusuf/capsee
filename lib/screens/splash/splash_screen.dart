import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/app_info.dart';
import '../../widgets/auth_widgets.dart';
import '../auth/register_screen.dart';

/// Layar pembuka: logo, nama aplikasi, indikator loading, dan versi
/// sebelum masuk ke alur utama.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _splashDuration = Duration(milliseconds: 2200);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _timer = Timer(_splashDuration, _lanjut);
  }

  void _lanjut() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.6,
                  colors: [AppColors.glow, Color(0x00F7F7FF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      children: [
                        const CapseeLogo(size: 112),
                        const SizedBox(height: 26),
                        Text(
                          AppInfo.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppInfo.tagline,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _fade,
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: FadeTransition(
                    opacity: _fade,
                    child: Text(
                      'Versi ${AppInfo.version}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.icon,
                      ),
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
}
