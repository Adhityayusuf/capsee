import 'package:capsee/core/app_text.dart';
import 'package:capsee/core/app_theme.dart';
import 'package:capsee/widgets/ui_kit.dart';
import 'package:flutter/material.dart';

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
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0,
        title: Text(
          'Riwayat Aktivitas',
          style: AppText.headline(context),
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.page, vertical: 12),
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
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
        border: Border.all(color: p.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: p.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.icon),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: p.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppText.bodySm(context, color: p.title)
                          .copyWith(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.fromLTRB(AppSpace.page, 8, AppSpace.page, 24),
      itemCount: _dummyData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _dummyData[index];
        return _buildRiwayatCard(item);
      },
    );
  }

  Widget _buildRiwayatCard(DummyRiwayat item) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData itemIcon;
    Color iconBgColor;
    Color iconColor;

    // Menentukan icon berdasarkan jenis aktivitas (Scan, Siram, Pupuk)
    switch (item.jenisAktivitas) {
      case 'scan':
        itemIcon = Icons.document_scanner_rounded;
        iconBgColor = item.statusAman
            ? p.accentSoft
            : p.error.withValues(alpha: .12);
        iconColor = item.statusAman ? p.accent : p.error;
        break;
      case 'siram':
        itemIcon = Icons.water_drop_rounded;
        iconBgColor =
            isDark ? const Color(0xFF0F2A3A) : const Color(0xFFE3F2FD);
        iconColor =
            isDark ? const Color(0xFF7DD3FC) : const Color(0xFF1976D2);
        break;
      case 'pupuk':
        itemIcon = Icons.eco_rounded;
        iconBgColor = const Color(0xFFFFF8E1);
        iconColor = const Color(0xFFFBC02D);
        break;
      default:
        itemIcon = Icons.history_rounded;
        iconBgColor = p.surfaceAlt;
        iconColor = p.icon;
    }

    return CapseeCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius:
                  BorderRadius.circular(AppSpace.radiusTile),
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
                        style: AppText.subtitle(context),
                      ),
                    ),
                    Text(
                      _formatDate(item.waktu),
                      style: AppText.caption(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.namaLahan,
                  style: AppText.bodySm(context, color: p.accent)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  item.deskripsi,
                  style: AppText.bodySm(context),
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
    return EmptyState(
      icon: Icons.history_rounded,
      title: 'Riwayat masih kosong',
      message:
          'Hasil pindai daun akan tampil di sini setelah Anda mengambil foto dengan kamera.',
      actionLabel: 'Scan Sekarang',
      onAction: () {
        // Aksi tombol scan dummy
      },
    );
  }

  // Helper format tanggal
  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
