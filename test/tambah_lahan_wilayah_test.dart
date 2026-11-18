import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/screens/lahan/tambah_lahan_page.dart';

void main() {
  testWidgets('pilih provinsi lewat dialog pencarian tanpa error', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TambahLahanPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pilih provinsi (10 tersedia)'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Provinsi'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'jawa barat');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jawa Barat'));
    await tester.pumpAndSettle();

    // Dialog tertutup, nilai terpilih tampil di field, dan tidak ada
    // exception "controller used after being disposed".
    expect(find.text('Pilih Provinsi'), findsNothing);
    expect(find.text('Jawa Barat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog wilayah tidak overflow di layar kecil', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TambahLahanPage()));
    await tester.pumpAndSettle();

    final provinsi = find.text('Pilih provinsi (10 tersedia)');
    await tester.ensureVisible(provinsi);
    await tester.pumpAndSettle();
    await tester.tap(provinsi);
    await tester.pumpAndSettle();

    expect(find.text('Pilih Provinsi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menutup dialog wilayah tanpa memilih tetap aman', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TambahLahanPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pilih provinsi (10 tersedia)'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ditemukan.'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Provinsi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
