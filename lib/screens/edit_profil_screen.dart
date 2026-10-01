import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'notifikasi_screen.dart' show C; // Aktifkan jika class C Anda sudah ada

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _farmLocationController;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _avatarBytes;

  // Jika belum ada class C, definisikan di sini atau ambil dari C.primary dsb
  static const Color cPrimaryGreen = Color(0xFF00652C);
  static const Color cPrimaryContainer = Color(0xFF15803D);
  static const Color cBackground = Color(0xFFFAF8FF);
  static const Color cOnSurface = Color(0xFF131B2E);
  static const Color cMutedText = Color(0xFF3F493F);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Budi Santoso');
    _emailController = TextEditingController(text: 'budi.santoso@agrimail.id');
    _phoneController = TextEditingController(text: '+62 812-3456-7890');
    _farmLocationController = TextEditingController(text: 'Kab. Malang, Jawa Timur');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }

  // Helper TextStyle menggunakan GoogleFonts Plus Jakarta Sans
  TextStyle _font({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = cOnSurface,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBackground,
      extendBodyBehindAppBar: true, // Agar efek BackdropFilter ImageFilter terasa
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          // PENGGUNAAN ImageFilter DARI dart:ui
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: cBackground.withOpacity(0.8),
              elevation: 0.5,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: cOnSurface),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                'Edit Profil',
                style: _font(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: cOnSurface),
                  onPressed: () => Navigator.maybePop(context),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: cPrimaryGreen,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // AVATAR
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!) as ImageProvider
                          : const NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuACNX9MgbxmS9XouZIyGyGTYaG8XqKIMVJ85MZIYLKV0h89F0EHGJTlwNT2kVYy-UaxvQuY3WIrglRqD9r6uEoNFYUvZze58N_jbMiC_TbBu5zoy4KWO5zFaPck-_qz0Yxlct1JzFsrMix1FdvBoEdtXvF3mGz1rIbSYgGyY2lFJhW5yY4lhAm77yP-AsrqNyH5h78bra9xhTI_kDwo3CcLQLAJ_lw-IfIfyQh_jqz8DhDqJvq7Q4fLTg',
                            ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: cPrimaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera, color: Colors.white, size: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Ubah Foto Profil',
                    style: _font(fontSize: 14, fontWeight: FontWeight.w700, color: cPrimaryGreen)),
                const SizedBox(height: 4),
                Text('Format JPG atau PNG, maks. 5 MB',
                    style: _font(fontSize: 12, color: cMutedText)),
                const SizedBox(height: 24),

                // FIELD NAMA
                _buildInput(
                  label: 'NAMA LENGKAP',
                  isRequired: true,
                  controller: _nameController,
                  icon: Icons.person_outline,
                  placeholder: 'Masukkan nama lengkap',
                ),
                const SizedBox(height: 18),

                // FIELD EMAIL
                _buildInput(
                  label: 'ALAMAT EMAIL',
                  isRequired: true,
                  controller: _emailController,
                  icon: Icons.mail_outline,
                  placeholder: 'contoh@domain.id',
                  badgeText: 'Terverifikasi',
                  badgeBg: const Color(0xFFD3FFD5).withOpacity(0.5),
                  badgeTextColor: cPrimaryContainer,
                  caption: 'Email digunakan untuk laporan ringkasan mingguan petak dan diagnosa ML.',
                ),
                const SizedBox(height: 18),

                // FIELD WA
                _buildInput(
                  label: 'NOMOR WHATSAPP / HP',
                  isRequired: true,
                  controller: _phoneController,
                  icon: Icons.phone_android_outlined,
                  placeholder: '+62 8xx-xxxx-xxxx',
                  badgeText: 'Aktif WA',
                  badgeIcon: Icons.sms,
                  badgeBg: const Color(0xFF6BFF8F).withOpacity(0.3),
                  badgeTextColor: const Color(0xFF005321),
                  caption: 'Nomor aktif untuk pengiriman notifikasi darurat hama & cuaca ekstrem.',
                ),
                const SizedBox(height: 18),

                // FIELD LOKASI
                _buildInput(
                  label: 'LOKASI / DOMISILI KEBUN',
                  controller: _farmLocationController,
                  icon: Icons.location_on_outlined,
                  placeholder: 'Kecamatan, Kabupaten / Kota',
                ),
                const SizedBox(height: 18),

                // INFO CARD
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: cPrimaryContainer, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data profil digunakan untuk sinkronisasi sensor lahan cabai secara real-time.',
                          style: _font(fontSize: 12, color: cMutedText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BUTTON SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Simpan Perubahan',
                            style: _font(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // BUTTON BATAL
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEAEDFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Batal',
                        style: _font(fontSize: 15, fontWeight: FontWeight.w600, color: cOnSurface)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    bool isRequired = false,
    String? badgeText,
    IconData? badgeIcon,
    Color? badgeBg,
    Color? badgeTextColor,
    String? caption,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: _font(fontSize: 11, fontWeight: FontWeight.w700, color: cMutedText)),
                if (isRequired)
                  Text(' *', style: _font(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
              ],
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (badgeIcon != null) ...[
                      Icon(badgeIcon, size: 12, color: badgeTextColor),
                      const SizedBox(width: 4),
                    ],
                    Text(badgeText,
                        style: _font(fontSize: 10, fontWeight: FontWeight.w700, color: badgeTextColor!)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: _font(fontSize: 15),
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: Icon(icon, color: cMutedText, size: 22),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Colors.black26, size: 20),
                onPressed: () => controller.clear(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(caption, style: _font(fontSize: 11, color: cMutedText)),
        ],
      ],
    );
  }
}
