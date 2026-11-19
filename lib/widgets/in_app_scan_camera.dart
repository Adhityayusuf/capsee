import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';

class ScanCapture {
  final XFile file;
  final Uint8List bytes;
  final String bagianTanaman;

  const ScanCapture({
    required this.file,
    required this.bytes,
    required this.bagianTanaman,
  });
}

class InAppScanCamera extends StatefulWidget {
  final String initialBagianTanaman;
  final ValueChanged<ScanCapture> onConfirmed;
  final VoidCallback onClose;

  const InAppScanCamera({
    super.key,
    this.initialBagianTanaman = 'buah',
    required this.onConfirmed,
    required this.onClose,
  });

  @override
  State<InAppScanCamera> createState() => _InAppScanCameraState();
}

class _InAppScanCameraState extends State<InAppScanCamera>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  String? _errorMessage;
  bool _initializing = true;
  bool _busy = false;
  bool _showScanFrame = true;
  String _bagianTanaman = 'buah';
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  XFile? _reviewFile;
  Uint8List? _reviewBytes;
  FlashMode _flashMode = FlashMode.off;
  final GlobalKey _cameraSurfaceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bagianTanaman = widget.initialBagianTanaman == 'daun' ? 'daun' : 'buah';
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed &&
        _reviewFile == null &&
        mounted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_busy) return;
    _disposeCamera();
    if (mounted) {
      setState(() {
        _initializing = true;
        _errorMessage = null;
      });
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (backCamera.isEmpty) {
        throw StateError('Kamera belakang tidak tersedia di perangkat ini.');
      }

      final controller = CameraController(
        backCamera.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _minZoom = minZoom;
        _maxZoom = maxZoom;
        _zoom = minZoom;
        _flashMode = FlashMode.off;
        _initializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = _cameraErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _cameraErrorMessage(CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' =>
        'Akses kamera ditolak. Izinkan Capsee menggunakan kamera di pengaturan perangkat.',
      'CameraAccessDeniedWithoutPrompt' =>
        'Akses kamera sebelumnya ditolak. Aktifkan izin kamera Capsee melalui pengaturan perangkat.',
      'CameraAccessRestricted' => 'Akses kamera dibatasi oleh perangkat ini.',
      _ => error.description ?? 'Kamera tidak dapat digunakan saat ini.',
    };
  }

  void _disposeCamera() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final viewportSize = _cameraSurfaceKey.currentContext?.size;
      if (viewportSize == null) {
        throw StateError('Area kamera belum siap untuk diproses.');
      }
      final bytes = await _cropToScanFrame(
        await file.readAsBytes(),
        viewportSize,
      );
      if (!mounted) return;
      setState(() {
        _reviewFile = XFile.fromData(
          bytes,
          name: 'capsee-scan.png',
          mimeType: 'image/png',
        );
        _reviewBytes = bytes;
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showError('Gagal mengambil foto: $error');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final viewportSize = _cameraSurfaceKey.currentContext?.size;
      if (viewportSize == null) {
        throw StateError('Area kamera belum siap untuk diproses.');
      }
      final bytes = await _cropToScanFrame(
        await file.readAsBytes(),
        viewportSize,
      );
      if (!mounted) return;
      setState(() {
        _reviewFile = XFile.fromData(
          bytes,
          name: 'capsee-scan.png',
          mimeType: 'image/png',
        );
        _reviewBytes = bytes;
        _busy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showError('Gagal membuka galeri: $error');
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) {
      return;
    }
    final nextMode = _flashMode == FlashMode.off
        ? FlashMode.always
        : FlashMode.off;
    try {
      await controller.setFlashMode(nextMode);
      if (mounted) setState(() => _flashMode = nextMode);
    } catch (error) {
      _showError('Flash tidak tersedia di perangkat ini.');
    }
  }

  Future<void> _setZoom(double value) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() => _zoom = value);
    try {
      await controller.setZoomLevel(value);
    } catch (_) {
      // Sebagian perangkat tidak mendukung semua level zoom.
    }
  }

  Future<Uint8List> _cropToScanFrame(Uint8List bytes, Size viewportSize) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final source = (await codec.getNextFrame()).image;
      try {
        final sourceSize = Size(
          source.width.toDouble(),
          source.height.toDouble(),
        );
        final scale = math.max(
          viewportSize.width / sourceSize.width,
          viewportSize.height / sourceSize.height,
        );
        final renderedSize = Size(
          sourceSize.width * scale,
          sourceSize.height * scale,
        );
        final frame = _scanFrameRect(viewportSize);
        final cropRect = Rect.fromLTRB(
          (frame.left - (viewportSize.width - renderedSize.width) / 2) / scale,
          (frame.top - (viewportSize.height - renderedSize.height) / 2) / scale,
          (frame.right - (viewportSize.width - renderedSize.width) / 2) / scale,
          (frame.bottom - (viewportSize.height - renderedSize.height) / 2) /
              scale,
        ).intersect(Offset.zero & sourceSize);
        final left = cropRect.left.floor();
        final top = cropRect.top.floor();
        final right = cropRect.right.ceil().clamp(left + 1, source.width);
        final bottom = cropRect.bottom.ceil().clamp(top + 1, source.height);
        final width = right - left;
        final height = bottom - top;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawImageRect(
          source,
          Rect.fromLTRB(
            left.toDouble(),
            top.toDouble(),
            right.toDouble(),
            bottom.toDouble(),
          ),
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          Paint()..filterQuality = FilterQuality.high,
        );
        final picture = recorder.endRecording();
        ui.Image croppedImage;
        try {
          croppedImage = await picture.toImage(width, height);
        } finally {
          picture.dispose();
        }
        try {
          final data = await croppedImage.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null) {
            throw StateError('Foto hasil scan tidak dapat disiapkan.');
          }
          return data.buffer.asUint8List();
        } finally {
          croppedImage.dispose();
        }
      } finally {
        source.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  void _confirmPhoto() {
    final file = _reviewFile;
    final bytes = _reviewBytes;
    if (file == null || bytes == null) return;
    widget.onConfirmed(
      ScanCapture(file: file, bytes: bytes, bagianTanaman: _bagianTanaman),
    );
  }

  void _retakePhoto() {
    setState(() {
      _reviewFile = null;
      _reviewBytes = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      key: _cameraSurfaceKey,
      borderRadius: BorderRadius.circular(AppSpace.radiusCard),
      child: SizedBox(
        height: 500,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(context),
            if (_reviewFile == null && _showScanFrame)
              const IgnorePointer(child: _ScanFrameOverlay()),
            _buildTopControls(context, p),
            if (_reviewFile == null)
              _buildLiveControls(context, p)
            else
              _buildReviewControls(context, p),
            if (_busy)
              Container(
                color: Colors.black38,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final p = context.palette;
    if (_reviewBytes != null) {
      return Image.memory(_reviewBytes!, fit: BoxFit.cover);
    }
    final controller = _controller;
    if (_initializing) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Menyiapkan kamera...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (_errorMessage != null || controller == null) {
      return Container(
        color: p.surfaceAlt,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_photography_outlined, color: p.icon, size: 44),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Kamera tidak tersedia.',
                textAlign: TextAlign.center,
                style: AppText.body(context),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final aspectRatio = controller.value.aspectRatio;
        final previewSize = aspectRatio > viewportSize.aspectRatio
            ? Size(viewportSize.height * aspectRatio, viewportSize.height)
            : Size(viewportSize.width, viewportSize.width / aspectRatio);
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.width,
              height: previewSize.height,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context, AppPalette p) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Tutup kamera',
              onPressed: widget.onClose,
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Scan Tanaman',
                  style: AppText.subtitle(context, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              tooltip: _showScanFrame
                  ? 'Sembunyikan bingkai scan'
                  : 'Tampilkan bingkai scan',
              onPressed: _reviewFile == null
                  ? () => setState(() => _showScanFrame = !_showScanFrame)
                  : null,
              color: Colors.white,
              icon: Icon(
                _showScanFrame
                    ? Icons.center_focus_strong_rounded
                    : Icons.center_focus_weak_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveControls(BuildContext context, AppPalette p) {
    final zoomAvailable = _maxZoom > _minZoom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildPartSelector(context),
            if (zoomAvailable)
              Row(
                children: [
                  const Icon(Icons.zoom_out, color: Colors.white, size: 18),
                  Expanded(
                    child: Slider(
                      value: _zoom.clamp(_minZoom, _maxZoom),
                      min: _minZoom,
                      max: _maxZoom,
                      onChanged: _setZoom,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                  ),
                  const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cameraAction(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onPressed: _pickFromGallery,
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                _cameraAction(
                  icon: _flashMode == FlashMode.off
                      ? Icons.flash_off_rounded
                      : Icons.flash_on_rounded,
                  label: 'Flash',
                  onPressed: _toggleFlash,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _partChoice(context, 'buah', 'Buah'),
          _partChoice(context, 'daun', 'Daun'),
        ],
      ),
    );
  }

  Widget _partChoice(BuildContext context, String value, String label) {
    final selected = _bagianTanaman == value;
    return GestureDetector(
      onTap: _busy ? null : () => setState(() => _bagianTanaman = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpace.radiusPill),
        ),
        child: Text(
          label,
          style: AppText.bodySm(
            context,
            color: selected ? Colors.black87 : Colors.white,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildReviewControls(BuildContext context, AppPalette p) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 22, 14, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _retakePhoto,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Ambil Ulang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _confirmPhoto,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Gunakan Foto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          IconButton(
            tooltip: label,
            onPressed: _busy ? null : onPressed,
            color: Colors.white,
            icon: Icon(icon, size: 26),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ScanFrameOverlay extends StatelessWidget {
  const _ScanFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScanFramePainter());
  }
}

Rect _scanFrameRect(Size size) {
  final width = math.min(size.width * 0.82, size.height * 0.62);
  final height = math.min(width, size.height * 0.52);
  final centerY = (size.height * 0.38).clamp(
    height / 2,
    size.height - height / 2,
  );
  return Rect.fromCenter(
    center: Offset(size.width / 2, centerY),
    width: width,
    height: height,
  );
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frame = _scanFrameRect(size);
    final roundedFrame = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(24),
    );
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(roundedFrame);
    canvas.drawPath(mask, Paint()..color = const Color.fromARGB(48, 0, 0, 0));
    canvas.drawRRect(
      roundedFrame,
      Paint()
        ..color = const Color.fromARGB(150, 255, 255, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final cornerLength = math.min(frame.width, frame.height) * 0.12;
    final corners = Path()
      ..moveTo(frame.left, frame.top + cornerLength)
      ..lineTo(frame.left, frame.top + 24)
      ..quadraticBezierTo(frame.left, frame.top, frame.left + 24, frame.top)
      ..lineTo(frame.left + cornerLength, frame.top)
      ..moveTo(frame.right - cornerLength, frame.top)
      ..lineTo(frame.right - 24, frame.top)
      ..quadraticBezierTo(frame.right, frame.top, frame.right, frame.top + 24)
      ..lineTo(frame.right, frame.top + cornerLength)
      ..moveTo(frame.right, frame.bottom - cornerLength)
      ..lineTo(frame.right, frame.bottom - 24)
      ..quadraticBezierTo(
        frame.right,
        frame.bottom,
        frame.right - 24,
        frame.bottom,
      )
      ..lineTo(frame.right - cornerLength, frame.bottom)
      ..moveTo(frame.left + cornerLength, frame.bottom)
      ..lineTo(frame.left + 24, frame.bottom)
      ..quadraticBezierTo(
        frame.left,
        frame.bottom,
        frame.left,
        frame.bottom - 24,
      )
      ..lineTo(frame.left, frame.bottom - cornerLength);
    canvas.drawPath(
      corners,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final guidePaint = Paint()
      ..color = const Color.fromARGB(80, 255, 255, 255)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(frame.left + 24, frame.center.dy),
      Offset(frame.right - 24, frame.center.dy),
      guidePaint,
    );
    canvas.drawLine(
      Offset(frame.center.dx, frame.top + 24),
      Offset(frame.center.dx, frame.bottom - 24),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
