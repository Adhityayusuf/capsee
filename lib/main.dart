import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/font_scale_scope.dart';
import 'core/theme_mode_scope.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_client.dart';
import 'widgets/feature_tour.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBaseUrl();
  FeatureTour.register();
  runApp(const CapseeApp());
}

class CapseeApp extends StatefulWidget {
  const CapseeApp({super.key});

  @override
  State<CapseeApp> createState() => _CapseeAppState();
}

class _CapseeAppState extends State<CapseeApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<AppFontSize> _fontSize = ValueNotifier(
    AppFontSize.normal,
  );

  @override
  void dispose() {
    _themeMode.dispose();
    _fontSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      notifier: _themeMode,
      child: FontScaleScope(
        notifier: _fontSize,
        child: ListenableBuilder(
          listenable: Listenable.merge([_themeMode, _fontSize]),
          builder: (context, _) {
            final scale = _fontSize.value.scale;
            return MaterialApp(
              title: 'Capsee',
              debugShowCheckedModeBanner: false,
              themeMode: _themeMode.value,
              theme: AppTheme.light(fontScale: scale),
              darkTheme: AppTheme.dark(fontScale: scale),
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
