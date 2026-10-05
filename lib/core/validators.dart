/// Validator form bersama untuk seluruh layar Capsee.
///
/// Sebelumnya logika ini disalin-tempel di login, register, dan lupa sandi.
/// Sekarang satu sumber kebenaran agar aturan validasi konsisten.
final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Nama lengkap wajib diisi';
  if (name.length < 3) return 'Nama terlalu pendek';
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';
  if (!isValidEmail(email)) return 'Format email tidak valid';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
  if (value.length < 8) return 'Minimal 8 karakter';
  return null;
}

String? validatePhone(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return 'Nomor WhatsApp / HP wajib diisi';
  if (phone.startsWith('0')) return 'Tulis tanpa angka 0 di depan';
  if (phone.length < 9 || phone.length > 13) return 'Nomor tidak valid';
  return null;
}
