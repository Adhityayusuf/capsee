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

  Widget _aboutDisease() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Color(0xFF00652C), size: 20),
              SizedBox(width: 7),
              Text('Tentang Penyakit Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Disebabkan oleh cendawan Cercospora capsici, ditandai dengan bercak bulat konsentris berwarna cokelat keabuan dengan halo klorotik kuning pada helai daun. Jika tidak ditangani, dapat memicu defoliasi daun prematur dan menurunkan produksi buah hingga 40%.',
            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _parameter(Icons.pie_chart, 'Luas Permukaan Terinfeksi',
              '~18% permukaan helai daun menunjukkan nekrosis aktif.'),
          _parameter(Icons.water_drop, 'Faktor Pemicu Spora',
              'Suhu 27°C - 30°C dengan periode daun basah lebih dari 6 jam.'),
          _parameter(Icons.shield, 'Risiko Penyebaran Lahan',
              'Tinggi pada tanaman sekitarnya dalam radius 1.5 - 3 meter.'),
        ],
      ),
    );
  }

  Widget _visualFindings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech, color: Color(0xFF006E2F), size: 20),
              SizedBox(width: 7),
              Text('Temuan Diagnosa Visual & Lingkungan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          _finding(Icons.lens, 'Bercak Mata Katak',
              'Titik nekrotik putih-abu di pusat lesi', 'Konfirmasi'),
          _finding(Icons.water_drop, 'Kelembapan Udara',
              'Tercatat 82% berdasar data cuaca', 'API BMKG'),
          _finding(Icons.forest, 'Kerapatan Kanopi',
              'Sirkulasi udara bawah terhambat', 'Perlu Pruning'),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Membuka rekomendasi penanganan...')),
            ),
            icon: const Icon(Icons.medical_services),
            label: const Text('Lihat Rekomendasi Penanganan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Petak Blok A ditandai untuk isolasi.')),
            ),
            icon: const Icon(Icons.flag),
            label: const Text('Tandai Isolasi Petak Blok A'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.photo_camera, color: Color(0xFF00652C)),
            label: const Text('Pindai Daun Lain'),
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, String note,
      {bool error = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFE4E0) : const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: error
                      ? const Color(0xFF93000A)
                      : Colors.grey)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: error
                      ? const Color(0xFFBA1A1A)
                      : const Color(0xFF00652C))),
          const SizedBox(height: 3),
          Text(note,
              style: TextStyle(
                  fontSize: 10,
                  color: error
                      ? const Color(0xFF93000A)
                      : Colors.grey)),
        ],
      ),
    );
  }

  Widget _severityBar(bool filled, bool current) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: filled
            ? current
                ? const Color(0xFFBA1A1A)
                : const Color(0xFF006E2F)
            : const Color(0xFFDCE1DC),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _parameter(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBA1A1A)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _finding(
      IconData icon, String title, String description, String badge) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE1DC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                Text(description,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF93000A),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color background, Color foreground,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  fontSize: 9,
                  color: foreground,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      );
}
