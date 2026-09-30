import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'lahan/tab_jadwal.dart';

class DetailLahanScreen extends StatelessWidget {
  const DetailLahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.title,
          title: const Text('Detail Lahan'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Scan'),
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Jadwal'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ScanTab(), TabJadwal(), _HistoryTab()],
        ),
      ),
    );
  }
}

class _ScanTab extends StatelessWidget {
  const _ScanTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Arahkan kamera ke daun untuk memulai pemindaian AI.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.verified_rounded, color: AppColors.primary),
            title: Text('Diagnosa scan daun'),
            subtitle: Text('Tanaman sehat • Keyakinan AI 98,6%'),
            trailing: Text('Hari ini'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.water_drop_rounded, color: Colors.blue),
            title: Text('Irigasi tetes presisi'),
            subtitle: Text('Penyiraman pagi selesai'),
            trailing: Text('Kemarin'),
          ),
        ),
      ],
    );
  }
}
