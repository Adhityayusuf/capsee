import 'inference_result.dart';

/// Implementasi Non-Maximum Suppression untuk output YOLOv5.
///
/// Menghilangkan bounding box duplikat yang mendeteksi objek yang sama
/// berdasarkan IoU (Intersection over Union) threshold.
class NonMaxSuppression {
  const NonMaxSuppression();

  /// Jalankan NMS pada list [detections].
  ///
  /// [iouThreshold]: IoU di atas ini dianggap duplikat (default 0.45).
  List<FruitDetection> run(
    List<FruitDetection> detections, {
    double iouThreshold = 0.45,
  }) {
    if (detections.isEmpty) return const [];

    // Urutkan berdasarkan confidence (tertinggi dulu)
    final sorted = List<FruitDetection>.from(detections)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final kept = <FruitDetection>[];

    for (final candidate in sorted) {
      bool shouldKeep = true;
      for (final kept_ in kept) {
        // Hanya bandingkan box dengan kelas yang sama
        if (candidate.classIndex != kept_.classIndex) continue;
        final iou = _iou(candidate.boundingBox, kept_.boundingBox);
        if (iou > iouThreshold) {
          shouldKeep = false;
          break;
        }
      }
      if (shouldKeep) kept.add(candidate);
    }

    return kept;
  }

  /// Hitung IoU (Intersection over Union) dua bounding box.
  double _iou(BoxRect a, BoxRect b) {
    final interLeft = a.left > b.left ? a.left : b.left;
    final interTop = a.top > b.top ? a.top : b.top;
    final interRight = a.right < b.right ? a.right : b.right;
    final interBottom = a.bottom < b.bottom ? a.bottom : b.bottom;

    final interW = interRight - interLeft;
    final interH = interBottom - interTop;

    if (interW <= 0 || interH <= 0) return 0.0;

    final interArea = interW * interH;
    final areaA = a.width * a.height;
    final areaB = b.width * b.height;
    final unionArea = areaA + areaB - interArea;

    return unionArea <= 0 ? 0.0 : (interArea / unionArea).clamp(0.0, 1.0);
  }
}
