import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/main.dart';
import 'package:capsee/screens/detail_lahan_screen.dart';
import 'package:capsee/screens/tambah_lahan_page.dart';

void main() {
  testWidgets('Capsee membuka halaman register', (tester) async {
    await tester.pumpWidget(const CapseeApp());

    expect(find.text('Daftar Akun Capsee'), findsOneWidget);
  });

  testWidgets('Dashboard membuka tambah lahan dan tab jadwal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TambahLahanPage()));
    expect(find.text('Tambah Data Lahan'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: DetailLahanScreen()));
    expect(find.text('Jadwal Penyiraman Mingguan'), findsOneWidget);
  });
}
