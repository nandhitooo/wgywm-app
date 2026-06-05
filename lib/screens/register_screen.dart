import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:wgym/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _retypeCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  DateTime? _birthDate;
  final _authService = AuthService();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _retypeCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String get _birthDateText {
    if (_birthDate == null) return AppLocalizations.of(context)!.pickBirthDate;
    final y = _birthDate!.year.toString();
    final m = _birthDate!.month.toString().padLeft(2, '0');
    final d = _birthDate!.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  Future<void> _pickBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.orange),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _birthDate = selected);
    }
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty ||
        _birthDate == null ||
        _weightCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty) {
      _showError(l10n.allFieldsRequired);
      return;
    }
    if (_passCtrl.text != _retypeCtrl.text) {
      _showError(l10n.passwordNotMatch);
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        birthDate: _birthDate!.toIso8601String(),
        weight: _weightCtrl.text.trim(),
        height: _heightCtrl.text.trim(),
      );

      // Logout dulu supaya tidak auto-login
      await _authService.logout();

      if (!mounted) return;

      // Popup sukses
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.registrationSuccess,
                style: GoogleFonts.bebasNeue(
                    fontSize: 22,
                    letterSpacing: 1,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.accountCreatedLogin,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.loginNow),
                ),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;
      // Kembali ke Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        // [PERBAIKAN]: Tutup halaman Register ini dan kembali ke root
        // StreamBuilder di main.dart akan secara otomatis me-render MainNav
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (result == null && mounted) {
        setState(() => _googleLoading = false);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.orange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 48,
              left: 32,
              right: 32,
              bottom: 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.joinUsToday,
                  style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerYourAccount,
                  style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 48,
                      letterSpacing: 1,
                      height: 1),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: l10n.fullName,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: l10n.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF242424)
                            : const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFEBEBEB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_birthDateText,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: _birthDate == null
                                      ? AppTheme.gray
                                      : (isDark
                                          ? Colors.white
                                          : AppTheme.dark))),
                          const Icon(Icons.calendar_month_outlined,
                              color: AppTheme.orange, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.weight + ' (kg)',
                            prefixIcon: const Icon(
                                Icons.monitor_weight_outlined,
                                size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.height + ' (cm)',
                            prefixIcon:
                                const Icon(Icons.height_outlined, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure1,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.gray,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _retypeCtrl,
                    obscureText: _obscure2,
                    decoration: InputDecoration(
                      hintText: l10n.retypePassword,
                      prefixIcon: const Icon(Icons.lock_reset, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.gray,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(l10n.register.toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  _GoogleButton(
                    loading: _googleLoading,
                    onTap: _loginGoogle,
                  ),
                  const SizedBox(height: 32),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.gray, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          l10n.login,
                          style: GoogleFonts.dmSans(
                              color: AppTheme.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget Tombol Google (sama persis dengan login_screen) ───────────────────
class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isDark ? const Color(0xFF3E3E3E) : const Color(0xFFDDDDDD)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: AppTheme.orange, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.continueWithGoogle,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3C4043),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];

    double startAngle = -90.0;
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.68),
        startAngle * 3.14159265 / 180,
        89.5 * 3.14159265 / 180,
        false,
        paint,
      );
      startAngle += 90.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
