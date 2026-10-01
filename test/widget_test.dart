import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsee/main.dart';
import 'package:capsee/models/land_data.dart';
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

    await tester.pumpWidget(
      MaterialApp(
        home: LandDetailScreen(
          land: LandData(
            name: 'Petak Cabai Rawit Blok A',
            province: 'Jawa Barat',
            city: 'Bandung Barat',
            district: 'Lembang',
            plantAgeMonths: 3,
            lastWatered: DateTime(2024, 10, 26),
            lastFertilized: DateTime(2024, 10, 24),
            fertilizeIntervalWeeks: 1,
          ),
        ),
      ),
    );
    expect(find.text('Kronologi Aktivitas'), findsOneWidget);
    expect(
      find.text('Penyakit Terdeteksi: Bercak Daun Cercospora'),
      findsOneWidget,
    );
    expect(find.text('Lihat Rekomendasi Penanganan'), findsOneWidget);

    await tester.tap(find.text('Jadwal'));
    await tester.pump();
    expect(find.text('Jadwal Penyiraman Mingguan'), findsOneWidget);
    expect(find.text('Jadwal Nutrisi & Pemupukan'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pump();
    expect(find.text('Hasil Scan Terakhir'), findsOneWidget);
    expect(find.text('Tanaman Sehat & Bebas Hama'), findsOneWidget);
    expect(find.text('Sensor Realtime'), findsOneWidget);
  });
}
