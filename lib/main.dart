import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/theme_mode_scope.dart';
import 'screens/auth/register_screen.dart';

void main() {
  runApp(const CapseeApp());
}

class CapseeApp extends StatefulWidget {
  const CapseeApp({super.key});

  @override
  State<CapseeApp> createState() => _CapseeAppState();
}

class _CapseeAppState extends State<CapseeApp> {
  // Awal terang. Ganti ke ThemeMode.system kalau ingin mengikuti pengaturan HP.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      notifier: _themeMode,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeMode,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Capsee',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const RegisterScreen(),
        ),
      ),
    );
  }
}