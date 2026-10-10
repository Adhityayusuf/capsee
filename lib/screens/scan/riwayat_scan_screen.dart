import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DATA DUMMY ---
class DummyRiwayat {
  final String id;
  final String jenisAktivitas; // 'scan', 'siram', 'pupuk'
  final String judul;
  final String namaLahan;
  final DateTime waktu;
  final String deskripsi;
  final bool statusAman;

  DummyRiwayat({
    required this.id,
    required this.jenisAktivitas,
    required this.judul,
    required this.namaLahan,
    required this.waktu,
    required this.deskripsi,
    this.statusAman = true,
  });
}

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // State untuk filter
  String _selectedLahan = 'Semua Lahan';
  String _selectedWaktu = 'Semua Waktu';

  // Toggle ini untuk melihat tampilan kosong (Empty State)
  // Ubah menjadi true untuk melihat desain saat riwayat kosong
  final bool _isEmptyState = false;

  final List<DummyRiwayat> _dummyData = [
    DummyRiwayat(
      id: '1',
      jenisAktivitas: 'scan',
      judul: 'Scan Daun - Bercak Daun',
      namaLahan: 'Petak Cabai Rawit Blok A',
      waktu: DateTime.now().subtract(const Duration(hours: 2)),
      deskripsi: 'Terdeteksi penyakit bercak daun. Perlu penanganan fungisida.',
      statusAman: false,
    ),
    DummyRiwayat(
      id: '2',
      jenisAktivitas: 'siram',
      judul: 'Penyiraman Rutin',
      namaLahan: 'Lahan Samping Rumah',
      waktu: DateTime.now().subtract(const Duration(days: 1)),
      deskripsi: 'Disiram sesuai jadwal cuaca cerah.',
      statusAman: true,
    ),
    DummyRiwayat(
      id: '3',
      jenisAktivitas: 'scan',
      judul: 'Scan Buah - Sehat',
      namaLahan: 'Petak Cabai Rawit Blok A',
      waktu: DateTime.now().subtract(const Duration(days: 2)),
      deskripsi: 'Kondisi buah sehat dan perkembangannya normal.',
      statusAman: true,
    ),
    DummyRiwayat(
      id: '4',
      jenisAktivitas: 'pupuk',
      judul: 'Pemupukan NPK',
      namaLahan: 'Lahan Samping Rumah',
      waktu: DateTime.now().subtract(const Duration(days: 5)),
      deskripsi: 'Pemupukan interval 2 minggu selesai dilakukan.',
      statusAman: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Text(
          'Riwayat Aktivitas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isEmptyState ? _buildEmptyState() : _buildRiwayatList(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET FILTER (Lahan & Waktu) ---
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              value: _selectedLahan,
              items: ['Semua Lahan', 'Petak Cabai Rawit Blok A', 'Lahan Samping Rumah'],
              icon: Icons.landscape_rounded,
              onChanged: (val) => setState(() => _selectedLahan = val!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              value: _selectedWaktu,
              items: ['Semua Waktu', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'],
              icon: Icons.calendar_today_rounded,
              onChanged: (val) => setState(() => _selectedWaktu = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- WIDGET DAFTAR RIWAYAT ---
  Widget _buildRiwayatList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _dummyData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _dummyData[index];
        return _buildRiwayatCard(item);
      },
    );
  }

  Widget _buildRiwayatCard(DummyRiwayat item) {
    IconData itemIcon;
    Color iconBgColor;
    Color iconColor;

    // Menentukan icon berdasarkan jenis aktivitas (Scan, Siram, Pupuk)
    switch (item.jenisAktivitas) {
      case 'scan':
        itemIcon = Icons.document_scanner_rounded;
        iconBgColor = item.statusAman ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
        iconColor = item.statusAman ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
        break;
      case 'siram':
        itemIcon = Icons.water_drop_rounded;
        iconBgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        break;
      case 'pupuk':
        itemIcon = Icons.eco_rounded;
        iconBgColor = const Color(0xFFFFF8E1);
        iconColor = const Color(0xFFFBC02D);
        break;
      default:
        itemIcon = Icons.history_rounded;
        iconBgColor = Colors.grey.shade200;
        iconColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(itemIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.judul,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(item.waktu),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.namaLahan,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.deskripsi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KETIKA RIWAYAT KOSONG ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFF2E7D32),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Riwayat masih kosong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil pindai daun akan tampil di sini setelah Anda mengambil foto dengan kamera.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aksi tombol scan dummy
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(
                  'Scan Sekarang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 60), // Mengangkat konten sedikit dari bottom nav
          ],
        ),
      ),
    );
  }

  // Helper format tanggal
  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
