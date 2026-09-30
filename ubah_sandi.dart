import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Password Strength State
  String _pwdStrengthText = 'Lemah';
  int _strengthLevel = 0; // 0: Lemah, 1: Sedang, 2: Kuat, 3: Sangat Kuat
  bool _hasMinLength = false;
  bool _hasMixedCase = false;
  bool _hasSymbolOrNumber = false;

  // Colors based on the screenshot
  static const Color cBg = Color(0xFFF9FAFD);
  static const Color cPrimaryGreen = Color(0xFF137F3E);
  static const Color cCardBg = Color(0xFFF2F4FD);
  static const Color cTextTitle = Color(0xFF121B2A);
  static const Color cTextBody = Color(0xFF4A5568);
  static const Color cLabelColor = Color(0xFF222831);
  static const Color cInputBorder = Color(0xFFE2E8F0);
  static const Color cCancelBtnBg = Color(0xFFEBF0FE);

  @override
  void initState() {
    super.initState();
    _newPwdController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final pwd = _newPwdController.text;

    setState(() {
      _hasMinLength = pwd.length >= 8;
      _hasMixedCase = pwd.contains(RegExp(r'[A-Z]')) && pwd.contains(RegExp(r'[a-z]'));
      _hasSymbolOrNumber = pwd.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'));

      int score = 0;
      if (pwd.length >= 6) score++;
      if (_hasMinLength) score++;
      if (_hasMixedCase) score++;
      if (_hasSymbolOrNumber) score++;

      if (score >= 4) {
        _strengthLevel = 3;
        _pwdStrengthText = 'Sangat Kuat';
      } else if (score >= 3) {
        _strengthLevel = 2;
        _pwdStrengthText = 'Kuat';
      } else if (score >= 2) {
        _strengthLevel = 1;
        _pwdStrengthText = 'Sedang';
      } else {
        _strengthLevel = 0;
        _pwdStrengthText = 'Lemah';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: cBg.withOpacity(0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: cTextTitle),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  Container(
                    height: 30,
                    width: 50,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Text(
                      'img',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tambah Data ...',
                      style: TextStyle(
                        color: cTextTitle,
                        fontSize: 18,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: cTextTitle),
                  onPressed: () => Navigator.pop(context),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF0D5C2C),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cCardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F5EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.lock_person, color: cPrimaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Perbarui Kata Sandi\nAkun',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w700,
                                      color: cTextTitle,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF86EFAC),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Aman',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF14532D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pastikan kata sandi baru Anda kuat, unik, dan terdiri dari minimal 8 karakter demi keamanan data lahan Anda.',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'serif',
                                color: cTextBody,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Password Field
                _buildLabel('Kata Sandi Saat Ini', isRequired: true),
                _buildPasswordField(
                  controller: _currentPwdController,
                  hintText: 'Masukkan kata sandi lama',
                  prefixIcon: Icons.lock_outline,
                  isObscure: _obscureCurrent,
                  onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lupa kata sandi saat ini?',
                      style: TextStyle(
                        color: cPrimaryGreen,
                        fontSize: 12,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // New Password Field
                _buildLabel('Kata Sandi Baru', isRequired: true),
                _buildPasswordField(
                  controller: _newPwdController,
                  hintText: 'Buat kata sandi baru',
                  prefixIcon: Icons.vpn_key_outlined,
                  isObscure: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),

                // Password Strength Meter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cCardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kekuatan Kata Sandi',
                            style: TextStyle(fontSize: 11, color: cTextBody),
                          ),
                          Text(
                            _pwdStrengthText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _strengthLevel >= 2 ? cPrimaryGreen : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStrengthBar(1),
                          const SizedBox(width: 4),
                          _buildStrengthBar(2),
                          const SizedBox(width: 4),
                          _buildStrengthBar(3),
                          const SizedBox(width: 4),
                          _buildStrengthBar(4), // Or just 3 bars based on the image
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Rules checklist
                _buildRuleItem('Minimal 8 karakter', _hasMinLength),
                _buildRuleItem('Kombinasi huruf besar & kecil', _hasMixedCase),
                _buildRuleItem('Mengandung angka atau simbol khusus (!@#\$)', _hasSymbolOrNumber),
                const SizedBox(height: 24),

                // Confirm Password Field
                _buildLabel('Konfirmasi Kata Sandi Baru', isRequired: true),
                _buildPasswordField(
                  controller: _confirmPwdController,
                  hintText: 'Ulangi kata sandi baru',
                  prefixIcon: Icons.lock_reset_outlined,
                  isObscure: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Ketik ulang kata sandi baru untuk memastikan kesesuaian.',
                    style: TextStyle(fontSize: 11, fontFamily: 'serif', color: cTextBody),
                  ),
                ),
                const SizedBox(height: 24),

                // Auto Protection Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cCardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user, color: cPrimaryGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perlindungan Akun Otomatis',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.bold,
                                color: cTextTitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Demi keamanan akun Capsee Anda, setelah mengganti kata sandi, sesi aktif di perangkat lain akan tetap aman atau dapat ditinjau ulang pada menu Sesi Masuk.',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'serif',
                                color: cTextBody,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save password logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cPrimaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Simpan Kata Sandi',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: cCancelBtnBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: cTextTitle,
                        fontSize: 15,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Footer Logo
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco_outlined, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'CAPSEE AGRO SECURITY\nSTANDARD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          height: 1.2,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'serif',
              fontWeight: FontWeight.w700,
              color: cLabelColor,
            ),
          ),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isObscure,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cInputBorder),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(fontSize: 15, fontFamily: 'serif', color: cTextTitle),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(prefixIcon, color: Colors.black54, size: 22),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.black45,
              size: 22,
            ),
            onPressed: onToggleObscure,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStrengthBar(int index) {
    Color barColor;
    if (index <= _strengthLevel) {
       // Green if filled
       barColor = cPrimaryGreen;
    } else {
       // Light grey/blue if unfilled
       barColor = const Color(0xFFE2E8F0); 
    }

    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? cPrimaryGreen : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'serif',
              color: isMet ? cTextTitle : cTextBody,
            ),
          ),
        ],
      ),
    );
  }
}
