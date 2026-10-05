import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/screens/home/dashboard_screen.dart';

void main() {
  testWidgets('bottom nav punya 5 slot dan tab berfungsi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump();

    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Riwayat Scan'), findsOneWidget);
    expect(find.text('Riwayat masih kosong'), findsOneWidget);
  });
}
