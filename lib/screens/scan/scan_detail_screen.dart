import 'package:flutter/material.dart';

import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/ui_kit.dart';

/// Detail satu hasil scan dari server.
/// Dibuka saat kartu riwayat scan dipencet.
class ScanDetailScreen extends StatefulWidget {
  final String idScan;

  const ScanDetailScreen({super.key, required this.idScan});

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await getDetailScan(widget.idScan);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = pesanError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: p.title),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Hasil Scan', style: AppText.headline(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.page),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: AppText.body(context)),
                        const SizedBox(height: AppSpace.gapMd),
                        OutlinedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _isi(),
    );
  }

  Widget _isi() {
    final scan = (_data!['pemindaian'] ?? {}) as Map<String, dynamic>;
    final penyakit = _data!['penyakit'] as Map<String, dynamic>?;
    final penanganan =
        List<Map<String, dynamic>>.from(_data!['penanganan'] ?? []);
    final langkah =
        List<Map<String, dynamic>>.from(_data!['langkah_tindakan'] ?? []);
    final pencegahan =
        List<Map<String, dynamic>>.from(_data!['pencegahan'] ?? []);

    final status = (scan['status_hasil'] ?? '').toString();
    final isSehat = status == 'sehat';
    final tanggal = (scan['dipindai_pada'] ?? '').toString().replaceAll('T', ' ');
    final skor = scan['skor_keyakinan']?.toString() ?? '-';
    final bagian = (scan['bagian_tanaman'] ?? '-').toString();
    final url = (scan['url_gambar'] ?? '').toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.page, AppSpace.gapMd, AppSpace.page, 24),
      children: [
        if (url.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpace.radiusCard),
            child: Image.network(
              url,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 220,
                color: context.palette.surfaceAlt,
                child: Icon(Icons.broken_image_outlined,
                    size: 48, color: context.palette.icon),
              ),
            ),
          ),
        const SizedBox(height: AppSpace.gapMd),
        CapseeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Hasil Diagnosa',
                        style: AppText.subtitle(context)),
                  ),
                  StatusBadge(
                    label: isSehat ? 'Sehat' : 'Tidak sehat',
                    kind: isSehat ? BadgeKind.success : BadgeKind.error,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.gapSm),
              _baris('Tanggal', tanggal.isEmpty ? '-' : tanggal),
              _baris('Bagian tanaman', bagian),
              _baris('Keyakinan AI', '$skor%'),
              if (penyakit != null) ...[
                const Divider(height: 20),
                Text((penyakit['nama'] ?? 'Penyakit').toString(),
                    style: AppText.title(context)),
                if ((penyakit['nama_latin'] ?? '').toString().isNotEmpty)
                  Text(
                    (penyakit['nama_latin'] ?? '').toString(),
                    style: AppText.bodySm(context).copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  (penyakit['deskripsi'] ?? '').toString(),
                  style: AppText.body(context),
                ),
              ],
            ],
          ),
        ),
        if (penanganan.isNotEmpty) ...[
          const SizedBox(height: AppSpace.gapMd),
          SectionHeader(
            icon: Icons.medical_services_outlined,
            title: 'Penanganan',
            subtitle: '${penanganan.length} rekomendasi',
          ),
          const SizedBox(height: AppSpace.gapSm),
          for (final t in penanganan)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.gapSm),
              child: CapseeCard(
                padding: const EdgeInsets.all(AppSpace.tile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((t['nama_produk'] ?? '-').toString(),
                        style: AppText.subtitle(context)),
                    if ((t['dosis'] ?? '').toString().isNotEmpty)
                      Text('Dosis: ${t['dosis']}',
                          style: AppText.caption(context)),
                    if ((t['cara_pakai'] ?? '').toString().isNotEmpty)
                      Text((t['cara_pakai'] ?? '').toString(),
                          style: AppText.bodySm(context)),
                  ],
                ),
              ),
            ),
        ],
        if (langkah.isNotEmpty) ...[
          const SizedBox(height: AppSpace.gapMd),
          SectionHeader(
            icon: Icons.checklist_rounded,
            title: 'Langkah Tindakan',
          ),
          const SizedBox(height: AppSpace.gapSm),
          for (final l in langkah)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.gapSm),
              child: CapseeCard(
                padding: const EdgeInsets.all(AppSpace.tile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((l['judul'] ?? '-').toString(),
                        style: AppText.subtitle(context)),
                    if ((l['deskripsi'] ?? '').toString().isNotEmpty)
                      Text((l['deskripsi'] ?? '').toString(),
                          style: AppText.bodySm(context)),
                  ],
                ),
              ),
            ),
        ],
        if (pencegahan.isNotEmpty) ...[
          const SizedBox(height: AppSpace.gapMd),
          SectionHeader(
            icon: Icons.shield_outlined,
            title: 'Pencegahan',
          ),
          const SizedBox(height: AppSpace.gapSm),
          for (final c in pencegahan)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.gapSm),
              child: CapseeCard(
                padding: const EdgeInsets.all(AppSpace.tile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((c['judul'] ?? '-').toString(),
                        style: AppText.subtitle(context)),
                    if ((c['deskripsi'] ?? '').toString().isNotEmpty)
                      Text((c['deskripsi'] ?? '').toString(),
                          style: AppText.bodySm(context)),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _baris(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppText.caption(context)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.bodySm(context, color: context.palette.title),
            ),
          ),
        ],
      ),
    );
  }
}
