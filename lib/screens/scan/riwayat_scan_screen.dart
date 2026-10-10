import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';

class ScanHistoryItem {
  final String imagePath;
  final DateTime scannedAt;

  /// Data dari backend (nullable agar file lokal lama tetap jalan).
  final String? idScan;
  final String? idLahan;
  final String? urlGambar;
  final String? statusHasil;

  const ScanHistoryItem({
    required this.imagePath,
    required this.scannedAt,
    this.idScan,
    this.idLahan,
    this.urlGambar,
    this.statusHasil,
  });
}

class RiwayatScanScreen extends StatefulWidget {
  final List<ScanHistoryItem> items;
  final VoidCallback onScan;

  const RiwayatScanScreen({
    super.key,
    required this.items,
    required this.onScan,
  });

  @override
  State<RiwayatScanScreen> createState() => _RiwayatScanScreenState();
}

class _RiwayatScanScreenState extends State<RiwayatScanScreen> {
  static const _waktuOptions = [
    'Semua Waktu',
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Pilih Tanggal...',
  ];

  String _selectedWaktu = 'Semua Waktu';
  DateTimeRange? _customDateRange;

  List<ScanHistoryItem> get _filteredItems {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.items.where((item) {
      final d = item.scannedAt;
      switch (_selectedWaktu) {
        case 'Hari Ini':
          return d.year == now.year && d.month == now.month && d.day == now.day;
        case 'Minggu Ini':
          // 7 hari terakhir termasuk hari ini.
          return !d.isBefore(today.subtract(const Duration(days: 6)));
        case 'Bulan Ini':
          return d.year == now.year && d.month == now.month;
        case 'Pilih Tanggal...':
          if (_customDateRange == null) return true;
          final start = DateTime(
            _customDateRange!.start.year,
            _customDateRange!.start.month,
            _customDateRange!.start.day,
          );
          final end = DateTime(
            _customDateRange!.end.year,
            _customDateRange!.end.month,
            _customDateRange!.end.day,
            23,
            59,
            59,
          );
          return !d.isBefore(start) && !d.isAfter(end);
        default:
          return true;
      }
    }).toList();
  }

  String get _labelWaktu {
    if (_selectedWaktu == 'Pilih Tanggal...' && _customDateRange != null) {
      final s = _customDateRange!.start;
      final e = _customDateRange!.end;
      return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
    }
    return _selectedWaktu;
  }

  Future<void> _onWaktuChanged(String? val) async {
    if (val == null) return;
    if (val == 'Pilih Tanggal...') {
      final p = context.palette;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: p.primary,
                onPrimary: p.onPrimary,
                surface: p.surface,
                onSurface: p.title,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          _customDateRange = picked;
          _selectedWaktu = val;
        });
      }
    } else {
      setState(() {
        _selectedWaktu = val;
        _customDateRange = null;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedWaktu = 'Semua Waktu';
      _customDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final filtered = _filteredItems;
    final isFiltering =
        _selectedWaktu != 'Semua Waktu' || _customDateRange != null;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(p, filtered.length, isFiltering),
          if (widget.items.isNotEmpty) _filterSection(p),
          Expanded(
            child: widget.items.isEmpty
                ? _empty(p)
                : filtered.isEmpty
                    ? _emptyFiltered(p)
                    : _list(p, filtered),
          ),
        ],
      ),
    );
  }

  Widget _header(AppPalette p, int count, bool isFiltering) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat Scan', style: _style(20, p.title, FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              widget.items.isEmpty
                  ? 'Belum ada foto yang dipindai'
                  : isFiltering
                      ? '$count dari ${widget.items.length} foto (filter: $_labelWaktu)'
                      : '$count foto hasil pindai sesi ini',
              style: _style(12, p.subtitle, FontWeight.w400),
            ),
          ],
        ),
      );

  Widget _filterSection(AppPalette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: _buildDropdown(
        p: p,
        value: _selectedWaktu,
        displayValue: _labelWaktu,
        items: _waktuOptions,
        icon: Icons.calendar_today_rounded,
        onChanged: _onWaktuChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required AppPalette p,
    required String value,
    required String displayValue,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: p.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.icon),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Row(
                children: [
                  Icon(icon, size: 16, color: p.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayValue,
                      style: _style(12, p.title, FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: _style(12, p.title, FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _empty(AppPalette p) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.history_rounded, color: p.accent, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Riwayat masih kosong',
                style: _style(16, p.title, FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Hasil pindai daun akan tampil di sini setelah Anda mengambil foto dengan kamera.',
                textAlign: TextAlign.center,
                style: _style(12, p.subtitle, FontWeight.w400, height: 1.4),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: widget.onScan,
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Scan Sekarang'),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _emptyFiltered(AppPalette p) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.search_off_rounded, color: p.icon, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada hasil',
                style: _style(16, p.title, FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Tidak ada pindaian pada rentang "$_labelWaktu".',
                textAlign: TextAlign.center,
                style: _style(12, p.subtitle, FontWeight.w400, height: 1.4),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _resetFilter,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Reset Filter'),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _list(AppPalette p, List<ScanHistoryItem> items) =>
      ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _card(items[index], p),
      );

  Widget _card(ScanHistoryItem item, AppPalette p) {
    final hasUrl = (item.urlGambar ?? '').isNotEmpty;
    final file = File(item.imagePath);
    final status = (item.statusHasil ?? '').toLowerCase();
    final isSehat = status == 'sehat';
    final isTidakSehat = status == 'tidak_sehat';
    return Card(
      elevation: 1,
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: hasUrl
                  ? Image.network(
                      item.urlGambar!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: p.surfaceAlt,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: p.icon,
                        ),
                      ),
                    )
                  : file.existsSync()
                  ? Image.file(
                      file,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: p.surfaceAlt,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: p.icon,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto Daun',
                    style: _style(13, p.title, FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _format(item.scannedAt),
                    style: _style(11, p.subtitle, FontWeight.w400),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isSehat
                    ? const Color(0xFFDCFCE7)
                    : isTidakSehat
                    ? const Color(0xFFFFDAD6)
                    : p.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSehat
                    ? 'Sehat'
                    : isTidakSehat
                    ? 'Tidak sehat'
                    : 'Menunggu analisis',
                style: _style(
                  10,
                  isSehat
                      ? const Color(0xFF166534)
                      : isTidakSehat
                      ? const Color(0xFF93000A)
                      : p.subtitle,
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} • ${two(d.hour)}:${two(d.minute)} WIB';
  }
}

TextStyle _style(
  double size,
  Color color,
  FontWeight weight, {
  double? height,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
