import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../services/services.dart';
import '../../widgets/popup_notifikasi.dart';

class _AdditionalSchedule {
  const _AdditionalSchedule({
    this.id,
    required this.name,
    required this.date,
    required this.description,
    this.status = 'pending',
  });

  final String? id;
  final String name;
  final DateTime date;
  final String description;
  final String status;
}

class TabJadwal extends StatefulWidget {
  final String idLahan;

  const TabJadwal({super.key, required this.idLahan});

  @override
  State<TabJadwal> createState() => _TabJadwalState();
}

class _TabJadwalState extends State<TabJadwal> {
  bool hematAir = true;
  bool showPupukOptions = false;
  bool activitySaved = false;
  bool syncing = false;
  String selectedPupuk = 'npk';
  final Map<DateTime, Map<int, String>> _scheduleStatuses = {};
  final List<_AdditionalSchedule> _additionalSchedules = [];
  DateTime? _expandedScheduleDate;
  Timer? _midnightTimer;

  // ── State backend (jadwal asli per lahan) ──
  bool _backendLoading = true;
  String? _backendError;
  List<Map<String, dynamic>> _siramList = [];
  List<Map<String, dynamic>> _pupukList = [];

  final Map<String, Map<String, String>> pupukData = {
    'npk': {
      'name': 'NPK Mutiara 16-16-16 + Kalsium Nitrat (CNG)',
      'desc':
          'Sangat direkomendasikan pada petak fase pembuahan aktif untuk mempertebal dinding sel pericarp buah cabai, mencegah penyakit patek (antraknosa), dan menekan kerontokan bunga.',
      'dose': '5 gram / tanaman (250 ml larutan / lubang mulsa)',
    },
    'poc': {
      'name': 'Pupuk Organik Cair (POC) Urin Kelinci & Asam Humat',
      'desc':
          'Menggemburkan tanah mulsa, merangsang perakaran baru, dan menyediakan nitrogen organik.',
      'dose': '10 ml POC + 2 gr Asam Humat / Liter air (300 ml / lubang)',
    },
    'mkp': {
      'name': 'MKP (Mono Kalium Fosfat) + Gandasil B',
      'desc':
          'Diformulasikan untuk memaksimalkan akumulasi gula pada buah cabai, mempercepat rona merah panen, dan memperkokoh tangkai buah.',
      'dose': '3 gram / Liter air disemprotkan merata pada daun',
    },
  };

  @override
  void initState() {
    super.initState();
    _scheduleMidnightRefresh();
    _loadBackend();
  }

  Future<void> _loadBackend() async {
    if (widget.idLahan.isEmpty) {
      if (mounted) {
        setState(() {
          _backendLoading = false;
          _backendError = 'ID lahan tidak tersedia.';
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _backendLoading = true;
        _backendError = null;
      });
    }
    try {
      final results = await Future.wait([
        getJadwalPenyiraman(widget.idLahan),
        getJadwalPemupukan(widget.idLahan),
        getJadwalKegiatan(widget.idLahan),
      ]);
      if (!mounted) return;
      final kegiatan = (results[2] as List<Map<String, dynamic>>)
          .map(
            (e) => _AdditionalSchedule(
              id: e['id'] as String?,
              name: (e['nama_kegiatan'] ?? 'Kegiatan').toString(),
              date:
                  DateTime.tryParse((e['tanggal_jadwal'] ?? '').toString()) ??
                  DateTime.now(),
              description: (e['deskripsi'] ?? '').toString(),
              status: (e['status'] ?? 'pending').toString(),
            ),
          )
          .toList();
      setState(() {
        _siramList = results[0] as List<Map<String, dynamic>>;
        _pupukList = results[1] as List<Map<String, dynamic>>;
        _additionalSchedules
          ..clear()
          ..addAll(kegiatan);
        _backendLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _backendLoading = false;
        _backendError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleMidnightRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _plotInfo(),
          _wateringSection(),
          const SizedBox(height: 16),
          _backendSection(),
          const SizedBox(height: 16),
          _actions(),
        ],
      ),
    );
  }

  Widget _backendSection() {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jadwal Lahan (Server)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.title),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang jadwal',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.refresh, color: p.primary),
                onPressed: _backendLoading ? null : _loadBackend,
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          if (_backendLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_backendError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gagal memuat jadwal: $_backendError',
                  style: TextStyle(fontSize: 12, color: p.error),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _loadBackend,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba lagi'),
                ),
              ],
            )
          else ...[
            _backendGroupTitle(
              'Penyiraman (${_siramList.where((e) => e['status'] != 'selesai').length} pending)',
            ),
            if (_siramList.isEmpty)
              Text(
                'Belum ada jadwal siram.',
                style: TextStyle(fontSize: 12, color: p.subtitle),
              ),
            for (final j in _siramList.take(5))
              _backendTile(
                icon: Icons.water_drop,
                title: 'Siram • ${(j['tanggal_jadwal'] ?? '-').toString()}',
                subtitle: 'Status: ${(j['status'] ?? '-').toString()}',
                status: (j['status'] ?? '').toString(),
                onSelesai: (j['status'] ?? '') == 'selesai'
                    ? null
                    : () => _selesaikanSiram((j['id'] ?? '').toString()),
              ),
            const SizedBox(height: 8),
            _backendGroupTitle(
              'Pemupukan (${_pupukList.where((e) => e['status'] != 'selesai').length} pending)',
            ),
            if (_pupukList.isEmpty)
              Text(
                'Belum ada jadwal pupuk.',
                style: TextStyle(fontSize: 12, color: context.palette.subtitle),
              ),
            for (final j in _pupukList.take(5))
              _backendTile(
                icon: Icons.science,
                title:
                    'Pupuk • ${(j['tanggal_jadwal'] ?? '-').toString()}${j['jenis_pupuk'] != null ? ' • ${j['jenis_pupuk']}' : ''}',
                subtitle: 'Status: ${(j['status'] ?? '-').toString()}',
                status: (j['status'] ?? '').toString(),
                onSelesai: (j['status'] ?? '') == 'selesai'
                    ? null
                    : () => _selesaikanPupuk((j['id'] ?? '').toString()),
              ),
          ],
        ],
      ),
    );
  }

  Widget _backendGroupTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.palette.subtitle,
        ),
      ),
    );
  }

  Widget _backendTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    VoidCallback? onSelesai,
  }) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: p.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.title,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: p.subtitle),
                ),
              ],
            ),
          ),
          if (onSelesai != null)
            TextButton(
              onPressed: onSelesai,
              child: const Text('Selesai', style: TextStyle(fontSize: 11)),
            )
          else
            Text(
              'Selesai',
              style: TextStyle(fontSize: 11, color: p.subtitle),
            ),
        ],
      ),
    );
  }

  Future<void> _selesaikanSiram(String idJadwal) async {
    try {
      await selesaiPenyiraman(widget.idLahan, idJadwal);
      if (!mounted) return;
      showSuccessPopup(context, 'Jadwal siram ditandai selesai.');
      await _loadBackend();
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menyelesaikan siram: ${pesanError(e)}');
    }
  }

  Future<void> _selesaikanPupuk(String idJadwal) async {
    try {
      await selesaiPemupukan(widget.idLahan, idJadwal);
      if (!mounted) return;
      showSuccessPopup(context, 'Jadwal pupuk ditandai selesai.');
      await _loadBackend();
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menyelesaikan pupuk: ${pesanError(e)}');
    }
  }

  Widget _plotInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Row(
        children: [
          _iconBox(Icons.local_florist, context.palette.accentSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petak Rawit Blok A • Umur 3 Bln',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.palette.title),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fase Berbuah Aktif (Generatif II)',
                  style: TextStyle(
                      fontSize: 12, color: context.palette.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _wateringSection() {
    final today = _dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final upcomingAdditionalSchedules = _additionalSchedules.where((schedule) {
      final scheduleDate = _dateOnly(schedule.date);
      return !scheduleDate.isBefore(today) &&
          !scheduleDate.isAfter(today.add(const Duration(days: 7)));
    }).toList()..sort((first, second) => first.date.compareTo(second.date));
    const scheduleDetails = [
      '3 Kegiatan',
      '3 Kegiatan',
      '2 Kegiatan',
      '4 Kegiatan',
      '3 Kegiatan',
      '5 Kegiatan',
      '4 Kegiatan',
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bmkgBg =
        isDark ? const Color(0xFF0F2A3A) : AppColors.tertiaryFixed;
    final bmkgTitle = isDark ? const Color(0xFF7DD3FC) : AppColors.tertiary;
    final bmkgBody = isDark ? context.palette.title : const Color(0xFF1B2B34);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bmkgBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud, color: bmkgTitle),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'SINKRONISASI BMKG AKTIF\n',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: bmkgTitle,
                        ),
                      ),
                      TextSpan(
                        text: 'Hujan lebat diprediksi terjadi ',
                        style: TextStyle(fontSize: 12, color: bmkgBody),
                      ),
                      TextSpan(
                        text: 'hari Rabu & Sabtu',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: bmkgBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                context,
                Icons.water_drop,
                'Jadwal Mingguan',
                color: context.palette.accent,
                fontSize: 14,
              ),
              const Divider(height: 20, thickness: 1),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Tambah jadwal tambahan',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: _showAddScheduleDialog,
                ),
              ),
              for (var index = 0; index < scheduleDetails.length; index++)
                _scheduleRow(
                  scheduledDate: weekStart.add(Duration(days: index)),
                  title: scheduleDetails[index],
                ),
              if (upcomingAdditionalSchedules.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Text(
                  'Jadwal tambahan mendekat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.palette.subtitle,
                  ),
                ),
                for (final schedule in upcomingAdditionalSchedules)
                  _additionalScheduleTile(schedule),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddScheduleDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedDate = _dateOnly(DateTime.now());
    var saving = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Jadwal Tambahan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nama kegiatan',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: _dateOnly(DateTime.now()),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = _dateOnly(pickedDate);
                              });
                            }
                          },
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_formatDate(selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  saving ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed:
                  nameController.text.trim().isEmpty || saving
                  ? null
                  : () async {
                      setDialogState(() => saving = true);
                      try {
                        final iso =
                            '${selectedDate.year.toString().padLeft(4, '0')}-'
                            '${selectedDate.month.toString().padLeft(2, '0')}-'
                            '${selectedDate.day.toString().padLeft(2, '0')}';
                        await tambahJadwalKegiatan(
                          idLahan: widget.idLahan,
                          namaKegiatan: nameController.text.trim(),
                          tanggalJadwal: iso,
                          deskripsi: descriptionController.text.trim(),
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (dialogContext.mounted) {
                          showErrorPopup(
                            dialogContext,
                            'Gagal menambah jadwal: ${pesanError(e)}',
                          );
                        }
                      }
                    },
              child: Text(saving ? 'Menyimpan…' : 'Tambah'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descriptionController.dispose();
    if (confirmed != true || !mounted) return;
    showSuccessPopup(context, 'Jadwal kegiatan tersimpan.');
    await _loadBackend();
  }

  Widget _additionalScheduleTile(_AdditionalSchedule schedule) {
    final isDone = schedule.status == 'selesai';
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_note, size: 18, color: p.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(schedule.date)} • ${schedule.status}',
                  style: TextStyle(fontSize: 10, color: p.subtitle),
                ),
                if (schedule.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule.description,
                    style: TextStyle(fontSize: 11, color: p.title),
                  ),
                ],
                if (schedule.id != null && !isDone) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => _selesaikanKegiatan(schedule.id!),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => _hapusKegiatan(schedule.id!),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.palette.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selesaikanKegiatan(String idJadwal) async {
    try {
      await selesaiJadwalKegiatan(widget.idLahan, idJadwal);
      if (!mounted) return;
      showSuccessPopup(context, 'Kegiatan ditandai selesai.');
      await _loadBackend();
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menyelesaikan kegiatan: ${pesanError(e)}');
    }
  }

  Future<void> _hapusKegiatan(String idJadwal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jadwal?'),
        content: const Text('Jadwal kegiatan ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: context.palette.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await hapusJadwalKegiatan(widget.idLahan, idJadwal);
      if (!mounted) return;
      showSuccessPopup(context, 'Jadwal dihapus.');
      await _loadBackend();
    } catch (e) {
      if (!mounted) return;
      showErrorPopup(context, 'Gagal menghapus: ${pesanError(e)}');
    }
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  Widget _scheduleRow({
    required DateTime scheduledDate,
    required String title,
  }) {
    final date = _dateOnly(scheduledDate);
    final today = _dateOnly(DateTime.now());
    final isPast = date.isBefore(today);
    final isToday = date == today;
    final activityStatuses = _scheduleStatuses[date] ?? const <int, String>{};
    final activities = [
      'Penyiraman sesuai jadwal',
      'Pemeriksaan kondisi tanah dan cuaca',
      'Catat kondisi tanaman dan hasil perawatan',
    ];
    final allActivitiesDone = List.generate(
      activities.length,
      (index) => activityStatuses[index] == 'selesai',
    ).every((done) => done);
    final status = isPast
        ? allActivitiesDone
            ? 'selesai'
            : 'terlewatkan'
        : activityStatuses[0] ?? 'belum';
    final isExpanded = _expandedScheduleDate == date;
    const dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    final p = context.palette;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: isExpanded ? 0 : 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isToday ? p.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? p.primary : p.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabels[date.weekday - 1],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isToday ? p.onPrimary : p.subtitle,
                      ),
                    ),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isToday ? p.onPrimary : p.title,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: status == 'terlewatkan'
                            ? p.subtitle
                            : p.title,
                        decoration: status == 'terlewatkan'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isExpanded ? 'Tutup keterangan' : 'Lihat keterangan',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isExpanded ? Icons.menu_open : Icons.menu,
                  color: p.primary,
                ),
                onPressed: () {
                  setState(() {
                    _expandedScheduleDate = isExpanded ? null : date;
                  });
                },
              ),
            ],
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(left: 54, right: 8, bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan kegiatan',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: p.subtitle,
                  ),
                ),
                const SizedBox(height: 4),
                for (var index = 0; index < activities.length; index++) ...[
                  if (index > 0) const Divider(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activities[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: p.title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _scheduleStatusControl(
                        date: date,
                        activityIndex: index,
                        isPast: isPast,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _scheduleStatusControl({
    required DateTime date,
    required int activityIndex,
    required bool isPast,
  }) {
    final selectedStatus = _scheduleStatuses[date]?[activityIndex] ?? 'belum';

    if (isPast) {
      final isDone = selectedStatus == 'selesai';
      return _status(
        isDone ? 'Selesai' : 'Terlewatkan',
        active: isDone,
        fontSize: 9,
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedStatus,
        isDense: true,
        style: TextStyle(fontSize: 10, color: context.palette.title),
        dropdownColor: context.palette.surface,
        iconSize: 18,
        borderRadius: BorderRadius.circular(8),
        items: const [
          DropdownMenuItem(
            value: 'belum',
            child: Text('Belum', style: TextStyle(fontSize: 10)),
          ),
          DropdownMenuItem(
            value: 'proses',
            child: Text('Proses', style: TextStyle(fontSize: 10)),
          ),
          DropdownMenuItem(
            value: 'selesai',
            child: Text('Selesai', style: TextStyle(fontSize: 10)),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _scheduleStatuses.putIfAbsent(date, () => {})[activityIndex] =
                value;
          });
        },
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => activitySaved = true);
              showSuccessPopup(context, 'Tersimpan di Jurnal Petani!');
            },
            icon: Icon(
              activitySaved ? Icons.done_all : Icons.assignment_turned_in,
            ),
            label: Text(
              activitySaved
                  ? 'Tersimpan di Jurnal Petani!'
                  : 'Catat Realisasi Pupuk / Siram',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.palette.primary,
              foregroundColor: context.palette.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: syncing
                    ? null
                    : () async {
                        setState(() => syncing = true);
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (mounted) setState(() => syncing = false);
                      },
                icon: syncing
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync),
                label: const Text('Sinkronkan Ulang BMKG'),
              ),
            ),
          ],
        ),
      ],
    );
  }

Widget _sectionTitle(
  BuildContext context,
  IconData icon,
  String title, {
  String? subtitle,
  Color? color,
  double fontSize = 14, // Sesuaikan ukuran font
}) {
  final p = context.palette;
  final c = color ?? p.primary;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: c, size: 21),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: p.title,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: p.subtitle),
              ),
          ],
        ),
      ),
    ],
  );
}

  Widget _iconBox(
    IconData icon,
    Color background, {
    Color? iconColor,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: iconColor ?? context.palette.primary, size: 21),
    );
  }

  Widget _status(
    String text, {
    bool active = false,
    double fontSize = 10,
  }) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active ? p.primary : p.accentSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: active ? p.onPrimary : p.primary,
        ),
      ),
    );
  }

  BoxDecoration _box() {
    final p = context.palette;
    return BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: p.border.withValues(alpha: .6)),
      boxShadow: [
        BoxShadow(color: p.shadow, blurRadius: 5, offset: const Offset(0, 2)),
      ],
    );
  }
}
