import 'package:tflite_flutter/tflite_flutter.dart';
import 'model_config.dart';

/// Singleton yang mengelola lifecycle interpreter TFLite.
///
/// Model di-load secara lazy (saat pertama kali dibutuhkan) dan
/// di-cache selama lifecycle interpreter tidak di-dispose.
/// Panggil [disposeLeaf] / [disposeFruit] saat layar ditutup.
class ModelLoader {
  ModelLoader._();

  static Interpreter? _leafInterpreter;
  static Interpreter? _fruitInterpreter;

  // ──────────────────────────────────────────────────────────────────────────
  // Model daun
  // ──────────────────────────────────────────────────────────────────────────

  /// Mengembalikan interpreter model daun (load jika belum dimuat).
  static Future<Interpreter> getLeafInterpreter() async {
    if (_leafInterpreter == null || !_isValid(_leafInterpreter)) {
      _leafInterpreter = await _load(ModelConfig.leafModelPath);
    }
    return _leafInterpreter!;
  }

  static void disposeLeaf() {
    _leafInterpreter?.close();
    _leafInterpreter = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Model buah
  // ──────────────────────────────────────────────────────────────────────────

  /// Mengembalikan interpreter model buah (load jika belum dimuat).
  static Future<Interpreter> getFruitInterpreter() async {
    if (_fruitInterpreter == null || !_isValid(_fruitInterpreter)) {
      _fruitInterpreter = await _load(ModelConfig.fruitModelPath);
    }
    return _fruitInterpreter!;
  }

  static void disposeFruit() {
    _fruitInterpreter?.close();
    _fruitInterpreter = null;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dispose semua
  // ──────────────────────────────────────────────────────────────────────────

  static void disposeAll() {
    disposeLeaf();
    disposeFruit();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  static Future<Interpreter> _load(String assetPath) async {
    try {
      final options = InterpreterOptions()..threads = 2;
      return await Interpreter.fromAsset(assetPath, options: options);
    } catch (e) {
      throw Exception(
        'Gagal memuat model TFLite dari "$assetPath": $e\n'
        'Pastikan file model tersedia di folder assets/models/.',
      );
    }
  }

  static bool _isValid(Interpreter? interpreter) {
    if (interpreter == null) return false;
    try {
      // Mencoba akses info tensor untuk memverifikasi interpreter masih valid.
      interpreter.getInputTensor(0);
      return true;
    } catch (_) {
      return false;
    }
  }
}
