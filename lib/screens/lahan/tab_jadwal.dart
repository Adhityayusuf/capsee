import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class _AdditionalSchedule {
  const _AdditionalSchedule({
    required this.name,
    required this.date,
    required this.description,
  });

  final String name;
  final DateTime date;
  final String description;
}

class TabJadwal extends StatefulWidget {
  const TabJadwal({super.key});

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
          _actions(),
        ],
      ),
    );
  }

  Widget _plotInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Row(
        children: [
          _iconBox(Icons.local_florist, AppColors.primarySoft),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petak Rawit Blok A • Umur 3 Bln',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Fase Berbuah Aktif (Generatif II)',
                  style: TextStyle(fontSize: 12, color: AppColors.hint),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryFixed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud, color: AppColors.tertiary),
              SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'SINKRONISASI BMKG AKTIF\n',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tertiary,
                        ),
                      ),
                      TextSpan(
                        text: 'Hujan lebat diprediksi terjadi ',
                        style: TextStyle(fontSize: 12),
                      ),
                      TextSpan(
                        text: 'hari Rabu & Sabtu',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
                Icons.water_drop,
                'Jadwal Mingguan',
                color: AppColors.tertiaryContainer,
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
                const Text(
                  'Jadwal tambahan mendekat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.hint,
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

    final schedule = await showDialog<_AdditionalSchedule>(
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
                    onPressed: () async {
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      dialogContext,
                      _AdditionalSchedule(
                        name: nameController.text.trim(),
                        date: selectedDate,
                        description: descriptionController.text.trim(),
                      ),
                    ),
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    descriptionController.dispose();
    if (schedule == null || !mounted) return;
    setState(() => _additionalSchedules.add(schedule));
  }

  Widget _additionalScheduleTile(_AdditionalSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_note, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(schedule.date),
                  style: const TextStyle(fontSize: 10, color: AppColors.hint),
                ),
                if (schedule.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.title),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: isExpanded ? 0 : 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.chipBg,
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
                        color: isToday ? Colors.white : AppColors.hint,
                      ),
                    ),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isToday ? Colors.white : AppColors.title,
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
                            ? AppColors.hint
                            : AppColors.title,
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
                  color: AppColors.primary,
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
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keterangan kegiatan',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.hint,
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.title,
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
        style: const TextStyle(fontSize: 10, color: AppColors.title),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tersimpan di Jurnal Petani!')),
              );
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
  IconData icon,
  String title, {
  String? subtitle,
  Color color = AppColors.primary,
  double fontSize = 14, // Sesuaikan ukuran font
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _iconBox(icon, color.withValues(alpha: .12), iconColor: color),
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
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.hint),
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
    Color iconColor = AppColors.primary,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: iconColor, size: 21),
    );
  }

  Widget _status(
    String text, {
    bool active = false,
    double fontSize = 10,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: AppColors.shadow, blurRadius: 5, offset: Offset(0, 2)),
    ],
  );
}
