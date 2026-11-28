import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../core/app_text.dart';
import '../services/feature_tour_service.dart';

/// Opsi halaman yang dapat dipilih dari menu "Lihat Tutorial".
class FeatureTourPageOption {
  final String pageKey;
  final String title;
  final IconData icon;
  final int tabIndex;

  const FeatureTourPageOption({
    required this.pageKey,
    required this.title,
    required this.icon,
    required this.tabIndex,
  });

  static const mainPages = [
    FeatureTourPageOption(
      pageKey: 'dashboard',
      title: 'Dashboard',
      icon: Icons.home_outlined,
      tabIndex: 0,
    ),
    FeatureTourPageOption(
      pageKey: 'riwayat_scan',
      title: 'Riwayat Scan',
      icon: Icons.history_rounded,
      tabIndex: 1,
    ),
    FeatureTourPageOption(
      pageKey: 'lahan',
      title: 'Lahan',
      icon: Icons.landscape_outlined,
      tabIndex: 2,
    ),
    FeatureTourPageOption(
      pageKey: 'notifikasi',
      title: 'Notifikasi',
      icon: Icons.notifications_outlined,
      tabIndex: 3,
    ),
    FeatureTourPageOption(
      pageKey: 'akun',
      title: 'Akun dan Pengaturan',
      icon: Icons.settings_outlined,
      tabIndex: 4,
    ),
  ];

  static FeatureTourPageOption? fromKey(String pageKey) {
    for (final page in mainPages) {
      if (page.pageKey == pageKey) return page;
    }
    return null;
  }
}

/// Koordinator coach mark per halaman.
///
/// Semua halaman memakai satu [ShowcaseView]. Koordinator ini memastikan
/// hanya satu rangkaian tutorial yang berjalan dan permintaan lama dibatalkan
/// ketika halaman lain mulai meminta tutorial.
class FeatureTour {
  FeatureTour._();

  static const _maxRenderAttempts = 15;
  static bool _registered = false;
  static int _generation = 0;
  static int? _activeGeneration;
  static String? _activePageKey;
  static List<GlobalKey> _activeKeys = const [];
  static final ValueNotifier<String> _progressText = ValueNotifier('');

  /// Register hanya sekali. Register ulang akan mengganti registry target
  /// milik showcaseview dan dapat membuat target yang sudah dibangun hilang.
  static void register() {
    if (_registered) return;

    ShowcaseView.register(
      enableAutoScroll: true,
      onStart: (index, key) {
        final total = _activeKeys.length;
        if (total == 0) return;
        _progressText.value = 'Langkah ${(index ?? 0) + 1} dari $total';
      },
      onComplete: (index, key) {
        final pageKey = _activePageKey;
        if (pageKey == null || _activeGeneration == null) return;
        if (index == _activeKeys.length - 1) {
          FeatureTourService.markCompleted(pageKey);
        }
      },
      onFinish: _clearActiveTour,
      onDismiss: (_) => _clearActiveTour(),
    );
    _registered = true;
  }

  /// Menjalankan ulang tutorial halaman tertentu dari langkah pertama.
  static Future<void> replay({
    required String pageKey,
    required List<GlobalKey> keys,
  }) async {
    register();
    final showcaseView = ShowcaseView.get();
    if (showcaseView.isShowcaseRunning && _activePageKey == pageKey) {
      showcaseView.dismiss();
      _generation++;
      _clearActiveTour();
    }
    await FeatureTourService.resetPage(pageKey);
    await start(pageKey: pageKey, keys: keys);
  }

  /// Menjalankan tutorial otomatis jika halaman tersebut belum selesai.
  static Future<void> start({
    required String pageKey,
    required List<GlobalKey> keys,
  }) async {
    if (keys.isEmpty) return;

    register();
    final showcaseView = ShowcaseView.get();
    _dismissTourFromAnotherPage(showcaseView, pageKey);
    if (!await FeatureTourService.shouldShow(pageKey)) return;

    // Setiap permintaan baru membatalkan callback penantian dari halaman lama.
    final generation = ++_generation;
    _activePageKey = pageKey;
    _activeKeys = List<GlobalKey>.unmodifiable(keys);

    _configureTooltipActions(showcaseView, keys);
    _scheduleStart(
      pageKey: pageKey,
      keys: keys,
      generation: generation,
    );
  }

  static void _dismissTourFromAnotherPage(
    ShowcaseView showcaseView,
    String pageKey,
  ) {
    if (!showcaseView.isShowcaseRunning) return;
    if (_activePageKey == pageKey) return;

    showcaseView.dismiss();
    _generation++;
    _clearActiveTour();
  }

  static void _configureTooltipActions(
    ShowcaseView showcaseView,
    List<GlobalKey> keys,
  ) {
    showcaseView.globalFloatingActionWidget = null;
    showcaseView.globalTooltipActionConfig = const TooltipActionConfig(
      position: TooltipActionPosition.inside,
      alignment: MainAxisAlignment.spaceBetween,
      actionGap: 8,
    );
    showcaseView.globalTooltipActions = [
      TooltipActionButton(
        type: TooltipDefaultActionType.previous,
        textStyle: const TextStyle(color: Colors.white),
        hideActionWidgetForShowcase: [keys.first],
      ),
      TooltipActionButton.custom(
        button: ValueListenableBuilder<String>(
          valueListenable: _progressText,
          builder: (context, text, _) => Text(
            text,
            style: AppText.micro(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      TooltipActionButton.custom(
        button: TextButton(
          onPressed: _skipCurrentTour,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Lewati'),
        ),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        textStyle: const TextStyle(color: Colors.white),
        hideActionWidgetForShowcase: [keys.last],
      ),
    ];
  }

  static void _scheduleStart({
    required String pageKey,
    required List<GlobalKey> keys,
    required int generation,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWhenTargetsReady(
        pageKey: pageKey,
        keys: keys,
        generation: generation,
      );
    });
  }

  static void _startWhenTargetsReady({
    required String pageKey,
    required List<GlobalKey> keys,
    required int generation,
    int attempt = 0,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (generation != _generation || _activePageKey != pageKey) return;

      final showcaseView = ShowcaseView.get();
      if (showcaseView.isShowcaseRunning) return;

      if (keys.every(showcaseView.isTargetRendered)) {
        _activeGeneration = generation;
        showcaseView.startShowCase(keys);
      } else if (attempt < _maxRenderAttempts) {
        _startWhenTargetsReady(
          pageKey: pageKey,
          keys: keys,
          generation: generation,
          attempt: attempt + 1,
        );
      } else {
        // Jangan menyimpan status selesai jika target gagal dirender. Pada
        // pembukaan halaman berikutnya tutorial masih boleh dicoba lagi.
        _clearActiveTour();
      }
    });
  }

  static Future<void> _skipCurrentTour() async {
    final currentPage = _activePageKey;
    if (currentPage != null) {
      await FeatureTourService.markCompleted(currentPage);
    }
    ShowcaseView.get().dismiss();
  }

  static void _clearActiveTour() {
    _progressText.value = '';
    _activeGeneration = null;
    _activePageKey = null;
    _activeKeys = const [];
  }
}
