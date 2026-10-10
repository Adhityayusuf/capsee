import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../core/app_info.dart';
import '../../services/services.dart';
import '../../widgets/auth_widgets.dart';
import '../auth/register_screen.dart';
import '../home/dashboard_screen.dart';

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

  void _lanjut() async {
    if (!mounted) return;
    // Kalau sudah ada token, langsung ke dashboard agar tidak login ulang
    // di tiap buka aplikasi (khusus HP).
    final login = await sudahLogin();
    if (!mounted) return;
    if (login) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }
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
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                        const CapseeLogo(size: 112, onPrimary: true),
                        const SizedBox(height: 26),
                        Text(
                          AppInfo.name,
                          style: AppText.display(context, color: p.onPrimary)
                              .copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppInfo.tagline,
                          style: AppText.body(context,
                                  color: p.onPrimary.withValues(alpha: 0.7))
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _fade,
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: p.onPrimary,
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
                      style: AppText.bodySm(context,
                              color: p.onPrimary.withValues(alpha: 0.7))
                          .copyWith(fontWeight: FontWeight.w600),
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
