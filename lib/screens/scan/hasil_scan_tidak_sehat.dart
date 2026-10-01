import 'package:flutter/material.dart';

class HasilScanTidakSehatPage extends StatelessWidget {
  const HasilScanTidakSehatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Scan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Hasil Scan Terakhir'),
          SizedBox(height: 16),
          Text('Tanaman Sehat & Bebas Hama'),
          SizedBox(height: 16),
          Text('Sensor Realtime'),
        ],
      ),
    );
  }
}
