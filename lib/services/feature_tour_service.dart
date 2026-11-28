import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan status tutorial pop-up otomatis per halaman.
class FeatureTourService {
  FeatureTourService._();

  static const completedPagesKey = 'feature_tour_completed_pages';

  static Future<bool> shouldShow(String pageKey) async {
    final completed = await _completedPages();
    return !completed.contains(pageKey);
  }

  static Future<void> markCompleted(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await _completedPages(prefs);
    if (completed.add(pageKey)) {
      await _saveCompletedPages(prefs, completed);
    }
  }

  static Future<void> resetPage(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await _completedPages(prefs);
    if (completed.remove(pageKey)) {
      await _saveCompletedPages(prefs, completed);
    }
  }

  /// Dipakai untuk pengujian manual atau mengulang semua tutorial.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(completedPagesKey);
  }

  static Future<Set<String>> _completedPages([
    SharedPreferences? prefs,
  ]) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    return {...?storage.getStringList(completedPagesKey)};
  }

  static Future<void> _saveCompletedPages(
    SharedPreferences prefs,
    Set<String> completed,
  ) async {
    await prefs.setStringList(completedPagesKey, completed.toList());
  }
}
