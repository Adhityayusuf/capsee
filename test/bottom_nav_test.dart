import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/screens/home/dashboard_screen.dart';

void main() {
  testWidgets('bottom nav punya tab Beranda & Lahan plus tombol Scan', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Lahan'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.text('Lahan'));
    await tester.pump(const Duration(milliseconds: 300));

    // Tab Lahan menampilkan tombol Tambah di header-nya.
    expect(find.text('Tambah'), findsOneWidget);
  });
}
