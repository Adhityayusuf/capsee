import 'dart:typed_data';

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
  bool _showGrid = true;
  String _bagianTanaman = 'buah';
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  XFile? _reviewFile;
  Uint8List? _reviewBytes;
  FlashMode _flashMode = FlashMode.off;

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
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _reviewFile = file;
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
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _reviewFile = file;
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
      borderRadius: BorderRadius.circular(AppSpace.radiusCard),
      child: SizedBox(
        height: 500,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(context),
            if (_reviewFile == null && _showGrid)
              const IgnorePointer(child: _GridOverlay()),
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
    return Center(child: CameraPreview(controller));
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
              tooltip: _showGrid ? 'Sembunyikan grid' : 'Tampilkan grid',
              onPressed: _reviewFile == null
                  ? () => setState(() => _showGrid = !_showGrid)
                  : null,
              color: Colors.white,
              icon: Icon(
                _showGrid ? Icons.grid_on_rounded : Icons.grid_off_rounded,
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

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdWidth * i, 0),
        Offset(thirdWidth * i, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, thirdHeight * i),
        Offset(size.width, thirdHeight * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
