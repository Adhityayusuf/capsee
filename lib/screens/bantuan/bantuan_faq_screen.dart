import 'package:flutter/material.dart';
import '../../core/app_text.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui_kit.dart';
import 'panduan_screen.dart';

class BantuanFaqScreen extends StatefulWidget {
  const BantuanFaqScreen({super.key});

  @override
  State<BantuanFaqScreen> createState() => _BantuanFaqScreenState();
}

class _BantuanFaqScreenState extends State<BantuanFaqScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Pemindaian Daun',
    'Hasil Diagnosis',
    'Jadwal & Cuaca',
    'Akun & Sensor'
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Pemindaian Daun',
      'icon': Icons.center_focus_strong,
      'question': 'Bagaimana cara melakukan pemindaian (scan) daun cabai yang benar?',
      'answer':
          'Untuk memperoleh akurasi model machine learning yang maksimal di atas 95%, ikuti langkah standar lapangan berikut:\n\n• Jarak Ideal: Tempatkan lensa kamera 10–15 cm dari helai daun.\n• Pencahayaan: Gunakan sinar matahari pagi atau alami, hindari bayangan tubuh menutupi daun.\n• Fokus: Arahkan tepat pada bercak daun dan pastikan tanaman tidak bergoyang tertiup angin kencang.',
    },
    {
      'category': 'Hasil Diagnosis',
      'icon': Icons.analytics,
      'question': 'Bagaimana cara membaca hasil diagnosis & tingkat keparahan penyakit?',
      'answer':
          'Setelah proses inferensi neural network selesai, kartu diagnosis memaparkan 3 parameter utama:\n\n• Persentase Akurasi: Menunjukkan derajat kepastian AI terhadap pola gejala visual (contoh: 98.4%).\n• Patogen Terdeteksi: Klasifikasi spesifik seperti Bercak Daun Cercospora, Antraknosa, atau Virus Kuning (Gemini).\n• Tingkat Keparahan: Diukur dari rasio nekrosis daun dalam skala Ringan (tindakan preventif), Sedang (fungisida terarah), hingga Kritis (isolasi tanaman).',
    },
    {
      'category': 'Jadwal & Cuaca',
      'icon': Icons.calendar_month,
      'question': 'Bagaimana cara mengatur dan mengubah jadwal penyiraman serta pemupukan?',
      'answer':
          'Masuk ke menu Jadwal Tani pada navigasi utama. Anda dapat menyesuaikan formulasi pupuk (NPK Mutiara, POC, atau Pupuk Kandang terfermentasi) serta menetapkan rotasi 7 hari atau 14 hari sekali.\n\nAlgoritma Capsee otomatis memundurkan pengingat penyiraman jika radar mikro BMKG mendeteksi anomali cuaca di koordinat kebun Anda.',
    },
    {
      'category': 'Pemindaian Daun',
      'icon': Icons.warning,
      'question':
          'Mengapa hasil pemindaian menampilkan status \'Kondisi Tidak Terdefinisi\'?',
      'answer':
          'Status ini terjadi sebagai mekanisme pengaman (fail-safe) saat model visi komputer tidak memperoleh kepastian minimum (di bawah ambang 65%). Faktor penyebab umumnya meliputi:\n\n• Lensa kamera buram atau mengalami goncangan saat rana ditekan.\n• Silau cahaya matahari langsung (overexposure) yang menghapus kontras urat daun.\n• Objek bukan merupakan dedaunan famili solanaceae / tanaman cabai.',
    },
    {
      'category': 'Akun & Sensor',
      'icon': Icons.verified_user,
      'question': 'Apakah data lahan dan foto tanaman saya aman dan rahasia?',
      'answer':
          'Sangat aman. Seluruh data koordinat geospasial blok lahan, foto daun, serta riwayat panen dienkripsi dengan standar TLS 1.3 saat transmisi dan AES-256 saat disimpan di server Cloud.\n\nKedaulatan kepemilikan data 100% berada di bawah kendali Anda sesuai Perjanjian Privasi Petani Capsee dan tidak diperjualbelikan kepada pihak ketiga.',
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'Semua' || faq['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq['question'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.title),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bantuan & Faq',
          style: AppText.headline(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.page),
            child: CircleAvatar(
              backgroundColor: p.primary,
              radius: 16,
              child: Icon(Icons.person, size: 18, color: p.onPrimary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.page),
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpace.radiusTile),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppText.body(context, color: p.title),
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: p.icon),
                hintText: 'Cari topik bantuan atau pertanyaan...',
                hintStyle: AppText.bodySm(context),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.gapLg),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.gapSm),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: AppText.caption(context).copyWith(
                        color: isSelected ? p.onPrimary : p.title,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    backgroundColor: p.surfaceAlt,
                    selectedColor: p.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpace.gapLg),

          // Panduan Cepat Banner
          CapseeCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PanduanScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: p.accentSoft,
                    borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                  ),
                  child: Icon(Icons.psychology_alt, color: p.onAccentSoft, size: 26),
                ),
                const SizedBox(width: AppSpace.page),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PANDUAN CEPAT CAPSEE',
                        style: AppText.overline(context, color: p.accent),
                      ),
                      Text(
                        'Solusi Tani Cerdas',
                        style: AppText.title(context),
                      ),
                      Text(
                        'Temukan jawaban akurat seputar kecerdasan buatan & kesehatan cabai Anda.',
                        style: AppText.bodySm(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: AppSpace.gapLg),

          // FAQ List
          if (_filteredFaqs.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              title: 'Topik tidak ditemukan',
              message: 'Coba kata kunci lain atau pilih kategori berbeda.',
            )
          else
            ..._filteredFaqs.map((faq) => _buildFaqItem(faq)),

          const SizedBox(height: AppSpace.gapXl),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.gapSm),
      child: CapseeCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: p.subtitle,
            collapsedIconColor: p.subtitle,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: AppSpace.page, vertical: 4),
            leading: Icon(faq['icon'] as IconData, color: p.accent, size: 22),
            title: Text(
              faq['question'],
              style: AppText.subtitle(context),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.page, 0, AppSpace.page, AppSpace.page),
                child: Text(
                  faq['answer'],
                  style: AppText.body(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final p = context.palette;
    return CapseeCard(
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.forum,
            title: 'Masih membutuhkan bantuan?',
            subtitle: 'Tim ahli agronomis kami siap mendampingi lahan Anda.',
          ),
          const SizedBox(height: AppSpace.page),

          _buildContactCard(
            icon: Icons.mail,
            iconColor: p.accent,
            title: 'Email Dukungan Teknis',
            subtitle: 'bantuan@capsee.id',
          ),
          const SizedBox(height: AppSpace.page),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.send, size: 20, color: p.onPrimary),
              label: Text(
                'Hubungi Tim Ahli Agronomis',
                style: AppText.subtitle(context, color: p.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.gapSm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: p.surfaceAlt,
                foregroundColor: p.title,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpace.radiusTile),
                ),
              ),
              child: Text(
                'Kembali ke Akun & Bantuan',
                style: AppText.subtitle(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpace.radiusTile),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpace.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.subtitle(context),
                ),
                Text(
                  subtitle,
                  style: AppText.bodySm(context),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: p.icon, size: 20),
        ],
      ),
    );
  }
}
