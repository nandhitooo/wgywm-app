import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'package:wgym/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _showError(l10n.bahasaIndonesia == 'Bahasa Indonesia'
          ? 'Semua kolom harus diisi.'
          : 'All fields are required.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      // StreamBuilder di main.dart akan secara otomatis me-render MainNav
      Navigator.popUntil(context, (route) => route.isFirst);
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
                  l10n.welcomeBack,
                  style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginToAccount,
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
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: l10n.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.gray,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button with Shadow
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
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(l10n.login),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.orContinueWith,
                            style: GoogleFonts.dmSans(
                                color: AppTheme.gray,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  _GoogleButton(
                    loading: _googleLoading,
                    onTap: _loginGoogle,
                  ),
                  const SizedBox(height: 32),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.gray, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: Text(
                          l10n.register,
                          style: GoogleFonts.dmSans(
                              color: AppTheme.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget Tombol Google (sama persis dengan register_screen) ───────────────────
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
