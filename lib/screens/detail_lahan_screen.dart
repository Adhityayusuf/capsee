import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detail Lahan Cabai',
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00652C),
          surface: Color(0xFFFAF8FF),
        ),
      ),
      home: const DetailLahanScanPage(),
    );
  }
}

class DetailLahanScanPage extends StatefulWidget {
  const DetailLahanScanPage({super.key});

  @override
  State<DetailLahanScanPage> createState() => _DetailLahanScanPageState();
}

class _DetailLahanScanPageState extends State<DetailLahanScanPage> {
  // State
  int _selectedTab = 0; // 0: Scan, 1: Jadwal, 2: Riwayat
  String _selectedOrgan = 'leaf'; // 'leaf' or 'fruit'
  int _imageSource = 0; // 0: Kamera Langsung, 1: Galeri
  bool _isAnalyzing = false;
  bool _isDone = false;

  void _handleAnalyze() async {
    setState(() {
      _isAnalyzing = true;
      _isDone = false;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isAnalyzing = false;
      _isDone = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isDone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF).withOpacity(0.9),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131B2E)),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Detail Lahan Petak Cabai Rawit Blok A',
          style: TextStyle(
            color: Color(0xFF131B2E),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF3F493F)),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00652C),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Sub-navigation Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEDFF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      _buildSubNavTab(0, Icons.qr_code_scanner, 'Scan'),
                      _buildSubNavTab(1, Icons.calendar_month, 'Jadwal'),
                      _buildSubNavTab(2, Icons.history, 'Riwayat'),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plot Context Banner
                    _buildPlotBanner(),
                    const SizedBox(height: 16),

                    // Organ Selection Section
                    const Text(
                      'Pilih Bagian Tanaman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131B2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tentukan organ yang dicurigai memiliki anomali',
                      style: TextStyle(fontSize: 12, color: Color(0xFF3F493F)),
                    ),
                    const SizedBox(height: 8),
                    _buildOrganSelector(),
                    const SizedBox(height: 16),

                    // Image Source Selector
                    const Text(
                      'Sumber Citra',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131B2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSourceSelector(),
                    const SizedBox(height: 16),

                    // Scan Viewfinder Preview Area
                    _buildViewfinder(),
                    const SizedBox(height: 16),

                    // AI Guidance Alert
                    _buildAiTip(),
                    const SizedBox(height: 12),

                    // Telemetry Snapshot Card
                    _buildTelemetryCard(),
                    const SizedBox(height: 20),

                    // Primary Action Button
                    _buildActionButton(),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Hasil diagnosa patogen, tingkat keparahan, dan rekomendasi penanganan muncul dalam 3 detik.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF3F493F)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubNavTab(int index, IconData icon, String title) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF3F493F),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF3F493F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlotBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD3FFD5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.agriculture, color: Color(0xFF00652C), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petak Cabai Rawit Blok A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131B2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Umur 3 Bulan • Fase Berbuah Aktif',
                  style: TextStyle(fontSize: 12, color: Color(0xFF3F493F)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6BFF8F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Color(0xFF00652C)),
                SizedBox(width: 5),
                Text(
                  'Optimal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF007432),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganSelector() {
    return Row(
      children: [
        Expanded(
          child: _organCard(
            type: 'leaf',
            title: 'Daun Tanaman',
            subtitle: 'Bercak, kutu & tungau',
            icon: Icons.eco,
            isSelected: _selectedOrgan == 'leaf',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _organCard(
            type: 'fruit',
            title: 'Buah Cabai',
            subtitle: 'Antraknosa & busuk buah',
            icon: Icons.restaurant,
            isSelected: _selectedOrgan == 'fruit',
          ),
        ),
      ],
    );
  }

  Widget _organCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedOrgan = type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF2F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00652C).withOpacity(0.1) : const Color(0xFFE2E7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: isSelected ? const Color(0xFF00652C) : const Color(0xFF3F493F)),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF15803D) : const Color(0xFFEAEDFF),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF131B2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF3F493F)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _imageSource = 0),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _imageSource == 0 ? Colors.white : const Color(0xFFF2F3FF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _imageSource == 0
                    ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 18,
                    color: _imageSource == 0 ? const Color(0xFF00652C) : const Color(0xFF3F493F),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kamera Langsung',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _imageSource == 0 ? const Color(0xFF00652C) : const Color(0xFF3F493F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _imageSource = 1),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _imageSource == 1 ? Colors.white : const Color(0xFFF2F3FF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _imageSource == 1
                    ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 18,
                    color: _imageSource == 1 ? const Color(0xFF00652C) : const Color(0xFF3F493F),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ambil Galeri',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _imageSource == 1 ? const Color(0xFF00652C) : const Color(0xFF3F493F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            // Preview Image
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBqsk9DEC0fdIYhAF6WnRGhYSh6E1a8GNxPmI3REjSySEwSliQwGpRZYGWybTRYLP_eUjOOmcYuiPEKJKSxNGmTvbyBY4ofTbgw2RPM4gYQe-29cwf8p9yKJoRzA8RAkt-vs3w1UA0hdei7yogYuLzVZLFa9zQIKy4gFSuP5jzXCb5CGpeqe4ti3QBWFJgEZeAMTxtH8GO3E6HZjdKIfPMyarznYQhxChOXZCXKlygCnFLFRWT-clik6Q',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
            ),

            // Overlay Details
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _glassBadge(
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: Color(0xFF6BFF8F)),
                              SizedBox(width: 6),
                              Text('AI SCANNER AKTIF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        _glassBadge(
                          child: const Row(
                            children: [
                              Icon(Icons.center_focus_strong, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('AF Cepat', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Central Bounding Box
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF95F8A7), width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(0xFF95F8A7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15803D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Fokus: Daun Utama (94%)',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),

                    // Guidance Pill
                    _glassBadge(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny, color: Color(0xFF6BFF8F), size: 14),
                          SizedBox(width: 6),
                          Text('Arahkan ke pusat gejala bercak', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls on Bottom Right
            Positioned(
              bottom: 12,
              right: 12,
              child: Row(
                children: [
                  _circleIconButton(Icons.flash_on),
                  const SizedBox(width: 6),
                  _circleIconButton(Icons.replay),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBadge({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF283044).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _circleIconButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF283044).withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildAiTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified, color: Color(0xFF00652C), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketepatan AI Capsee 95.2%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF131B2E),
                  ),
                ),
                Text(
                  'Jaga jarak kamera sekitar 10–15 cm dari permukaan helai daun.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF3F493F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _telemetryItem(Icons.thermostat, const Color(0xFF6BFF8F), 'Suhu Udara', '28.4 °C'),
          Container(height: 28, width: 1, color: const Color(0xFFEAEDFF)),
          _telemetryItem(Icons.water_drop_outlined, const Color(0xFFCCE5FF), 'Kelembapan', '76% RH'),
          Container(height: 28, width: 1, color: const Color(0xFFEAEDFF)),
          _telemetryItem(Icons.opacity, const Color(0xFFDAE2FD), 'Kebasahan', 'Sedang'),
        ],
      ),
    );
  }

  Widget _telemetryItem(IconData icon, Color iconBg, String label, String value) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF131B2E)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF3F493F))),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131B2E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: _isAnalyzing ? null : _handleAnalyze,
        child: _isAnalyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Text('Memproses Citra Daun...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              )
            : _isDone
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Analisis Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Analisis dengan AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
      ),
    );
  }
}