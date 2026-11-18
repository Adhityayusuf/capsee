import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/core/app_theme.dart';
import 'package:capsee/core/theme_mode_scope.dart';
import 'package:capsee/screens/home/dashboard_screen.dart';
import 'package:capsee/screens/lahan/lahan_page.dart';

void main() {
  testWidgets('bottom nav berisi lima item tanpa notifikasi dan tema', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
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

    expect(find.text('Dashboard'), findsNWidgets(2));
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Lahan'), findsWidgets);
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

    await tester.tap(find.text('Lahan').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lahan'), findsWidgets);
    expect(find.byTooltip('Tambah lahan'), findsOneWidget);
    expect(find.text('Tambah Petak Lahan Baru'), findsNothing);
    expect(
      tester.getCenter(find.byTooltip('Tambah lahan')).dy,
      lessThan(tester.getCenter(find.byType(TextField).first).dy),
    );

    // Tanpa backend, tab Lahan menampilkan data contoh.
    expect(find.text('3 Petak (Contoh)'), findsOneWidget);
    expect(tester.takeException(), isNull);

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

  testWidgets('halaman lahan memakai warna tema gelap', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const LahanPage(),
      ),
    );
    await tester.pump();

    final headerLahan = find.descendant(
      of: find.byType(LahanPage),
      matching: find.text('Lahan'),
    );
    expect(headerLahan, findsOneWidget);
    expect(find.text('Kesehatan Wilayah'), findsNothing);
    expect(find.text('Real-time Sensor'), findsNothing);
    expect(
      tester.widget<Text>(headerLahan).style?.color,
      AppPalette.dark.title,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      AppPalette.dark.background,
    );
  });
}
