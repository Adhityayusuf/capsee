import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/core/theme_mode_scope.dart';
import 'package:capsee/screens/home/dashboard_screen.dart';

void main() {
  testWidgets('bottom nav berisi lima item tanpa notifikasi dan tema', (
    tester,
  ) async {
    final themeMode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(
      ThemeModeScope(
        notifier: themeMode,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Lahan'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Notifikasi'), findsNothing);
    expect(find.text('Gelap/Terang'), findsNothing);
    expect(find.byTooltip('Buka notifikasi'), findsOneWidget);
    expect(find.byTooltip('Ganti ke mode gelap'), findsOneWidget);

    await tester.tap(find.byTooltip('Buka notifikasi'));
    await tester.pump();
    expect(find.text('Notifikasi'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Riwayat Scan'), findsOneWidget);
    expect(find.text('Riwayat masih kosong'), findsOneWidget);

    await tester.tap(find.text('Lahan'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Data Lahan'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    themeMode.dispose();
  });

  testWidgets('header atas mengganti tema ke mode gelap', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeMode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(
      ThemeModeScope(
        notifier: themeMode,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Buka notifikasi'), findsOneWidget);
    expect(find.byTooltip('Ganti ke mode gelap'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Ganti ke mode gelap'));
    await tester.pump();
    expect(themeMode.value, ThemeMode.dark);

    await tester.pumpWidget(const SizedBox.shrink());
    themeMode.dispose();
  });
}
