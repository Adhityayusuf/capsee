import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
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
      'answer': 'Untuk memperoleh akurasi model machine learning yang maksimal di atas 95%, ikuti langkah standar lapangan berikut:\n\n• Jarak Ideal: Tempatkan lensa kamera 10–15 cm dari helai daun.\n• Pencahayaan: Gunakan sinar matahari pagi atau alami, hindari bayangan tubuh menutupi daun.\n• Fokus: Arahkan tepat pada bercak daun dan pastikan tanaman tidak bergoyang tertiup angin kencang.',
    },
    {
      'category': 'Hasil Diagnosis',
      'icon': Icons.analytics,
      'question': 'Bagaimana cara membaca hasil diagnosis & tingkat keparahan penyakit?',
      'answer': 'Setelah proses inferensi neural network selesai, kartu diagnosis memaparkan 3 parameter utama:\n\n• Persentase Akurasi: Menunjukkan derajat kepastian AI terhadap pola gejala visual (contoh: 98.4%).\n• Patogen Terdeteksi: Klasifikasi spesifik seperti Bercak Daun Cercospora, Antraknosa, atau Virus Kuning (Gemini).\n• Tingkat Keparahan: Diukur dari rasio nekrosis daun dalam skala Ringan (tindakan preventif), Sedang (fungisida terarah), hingga Kritis (isolasi tanaman).',
    },
    {
      'category': 'Jadwal & Cuaca',
      'icon': Icons.calendar_month,
      'question': 'Bagaimana cara mengatur dan mengubah jadwal penyiraman serta pemupukan?',
      'answer': 'Masuk ke menu Jadwal Tani pada navigasi utama. Anda dapat menyesuaikan formulasi pupuk (NPK Mutiara, POC, atau Pupuk Kandang terfermentasi) serta menetapkan rotasi 7 hari atau 14 hari sekali.\n\nAlgoritma Capsee otomatis memundurkan pengingat penyiraman jika radar mikro BMKG mendeteksi anomali cuaca di koordinat kebun Anda.',
    },
    {
      'category': 'Pemindaian Daun',
      'icon': Icons.warning,
      'question': 'Mengapa hasil pemindaian menampilkan status \'Kondisi Tidak Terdefinisi\'?',
      'answer': 'Status ini terjadi sebagai mekanisme pengaman (fail-safe) saat model visi komputer tidak memperoleh kepastian minimum (di bawah ambang 65%). Faktor penyebab umumnya meliputi:\n\n• Lensa kamera buram atau mengalami goncangan saat rana ditekan.\n• Silau cahaya matahari langsung (overexposure) yang menghapus kontras urat daun.\n• Objek bukan merupakan dedaunan famili solanaceae / tanaman cabai.',
    },
    {
      'category': 'Akun & Sensor',
      'icon': Icons.verified_user,
      'question': 'Apakah data lahan dan foto tanaman saya aman dan rahasia?',
      'answer': 'Sangat aman. Seluruh data koordinat geospasial blok lahan, foto daun, serta riwayat panen dienkripsi dengan standar TLS 1.3 saat transmisi dan AES-256 saat disimpan di server Cloud.\n\nKedaulatan kepemilikan data 100% berada di bawah kendali Anda sesuai Perjanjian Privasi Petani Capsee dan tidak diperjualbelikan kepada pihak ketiga.',
    },

  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory = _selectedCategory == 'Semua' || faq['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          faq['question'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.surface,
      appBar: AppBar(
        backgroundColor: C.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: C.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bantuan & Faq',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: C.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: C.primary,
              radius: 16,
              child: const Icon(Icons.person, size: 18, color: C.onPrimary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: C.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: C.outline),
                hintText: 'Cari topik bantuan atau pertanyaan...',
                hintStyle: GoogleFonts.plusJakartaSans(color: C.onSurfaceVariant),
                border: InputBorder.none,
              ),
              style: GoogleFonts.plusJakartaSans(color: C.onSurface, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? C.onPrimary : C.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    backgroundColor: C.surfaceHigh,
                    selectedColor: C.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Panduan Cepat Banner
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PanduanScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: C.surfaceHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: C.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_alt, color: C.primary, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PANDUAN CEPAT CAPSEE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: C.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Solusi Tani Cerdas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: C.onSurface,
                          ),
                        ),
                        Text(
                          'Temukan jawaban akurat seputar kecerdasan buatan & kesehatan cabai Anda.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: C.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FAQ List
          if (_filteredFaqs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 48, color: C.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Topik tidak ditemukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: C.onSurface,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._filteredFaqs.map((faq) => _buildFaqItem(faq)),

          const SizedBox(height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: C.onSurfaceVariant,
          collapsedIconColor: C.onSurfaceVariant,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(faq['icon'] as IconData, color: C.primary, size: 22),
          title: Text(
            faq['question'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: C.onSurface,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  height: 1.5,
                  color: C.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.forum, color: AppColors.onSecondaryContainer, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masih membutuhkan bantuan?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: C.onSurface,
                      ),
                    ),
                    Text(
                      'Tim ahli agronomis kami siap mendampingi lahan Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: C.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildContactCard(
            icon: Icons.mail,
            iconColor: C.tertiary,
            title: 'Email Dukungan Teknis',
            subtitle: 'bantuan@capsee.id',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send, size: 20),
              label: Text(
                'Hubungi Tim Ahli Agronomis',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primaryContainer,
                foregroundColor: C.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: C.surfaceHigh,
                foregroundColor: C.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Kembali ke Akun & Bantuan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: C.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: C.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: C.outline, size: 20),
        ],
      ),
    );
  }
}
