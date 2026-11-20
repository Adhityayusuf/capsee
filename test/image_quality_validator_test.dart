import 'dart:typed_data';

import 'package:capsee/core/ml/image_quality_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List solidImage(int w, int h, int r, int g, int b) {
  final image = img.Image(width: w, height: h);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List checkerboard(int size) {
  final image = img.Image(width: size, height: size);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final on = ((x ~/ 8) + (y ~/ 8)) % 2 == 0;
      final v = on ? 255 : 0;
      image.setPixelRgb(x, y, v, v, v);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  const validator = ImageQualityValidator();

  test('menolak bytes yang bukan gambar', () async {
    final result = await validator.validate(
      Uint8List.fromList(List<int>.filled(64, 7)),
    );
    expect(result.isValid, isFalse);
    expect(result.reason, contains('tidak dapat dibaca'));
  });

  test('menolak gambar resolusi terlalu kecil', () async {
    final result = await validator.validate(solidImage(40, 40, 120, 120, 120));
    expect(result.isValid, isFalse);
    expect(result.reason, contains('Resolusi'));
  });

  test('menolak gambar terlalu gelap', () async {
    final result = await validator.validate(solidImage(240, 240, 2, 2, 2));
    expect(result.isValid, isFalse);
    expect(result.reason, contains('terlalu gelap'));
  });

  test('menolak gambar terlalu terang', () async {
    final result = await validator.validate(solidImage(240, 240, 255, 255, 255));
    expect(result.isValid, isFalse);
    expect(result.reason, contains('terlalu terang'));
  });

  test('menerima gambar tajam dengan pencahayaan wajar', () async {
    final result = await validator.validate(checkerboard(240));
    expect(result.isValid, isTrue, reason: result.reason);
  });

  test('menolak gambar buram (blur)', () async {
    // Gradien halus tanpa detail tinggi menyerupai gambar buram.
    final image = img.Image(width: 240, height: 240);
    for (int y = 0; y < 240; y++) {
      for (int x = 0; x < 240; x++) {
        image.setPixelRgb(x, y, 110 + x ~/ 24, 120, 130);
      }
    }
    final bytes = Uint8List.fromList(img.encodePng(image));
    final result = await validator.validate(bytes);
    expect(result.isValid, isFalse);
    expect(result.reason, contains('buram'));
  });
}
