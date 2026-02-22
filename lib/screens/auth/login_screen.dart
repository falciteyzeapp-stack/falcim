import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.signInWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  _buildLogo(),
                  const SizedBox(height: 28),
                  const Text(
                    'Falcı Teyze',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Cinzel',
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 6),
                  const Text(
                    'Falcı Teyze\'ye Hoşgeldin',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cinzel',
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 40),
                  _buildErrorBanner(),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'E-posta giriniz';
                      if (!v.contains('@')) return 'Geçerli e-posta giriniz';
                      return null;
                    },
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Şifre giriniz';
                      return null;
                    },
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => CoralButton(
                      text: 'Giriş Yap',
                      isLoading: auth.isLoading,
                      onPressed: _login,
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildSocialButtons(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hesabın yok mu? ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF5D2020), Color(0xFF3D1010)],
        ),
        border: Border.all(color: AppTheme.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.auto_awesome,
            size: 55,
            color: AppTheme.primary,
          ),
        ),
      ),
    ).animate().scale(duration: 700.ms, curve: Curves.elasticOut);
  }

  Widget _buildErrorBanner() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.error == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.error.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.error, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  auth.error!,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF5D3030))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cinzel',
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF5D3030))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SocialButton(
          text: 'Google ile Devam Et',
          logo: const Icon(Icons.g_mobiledata_rounded,
              color: Colors.white, size: 24),
          onPressed: () async {
            final success =
                await context.read<AuthProvider>().signInWithGoogle();
            if (success && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        const SizedBox(height: 10),
        SocialButton(
          text: 'Facebook ile Devam Et',
          logo: const Icon(Icons.facebook_rounded,
              color: Color(0xFF1877F2), size: 22),
          onPressed: () async {
            final success =
                await context.read<AuthProvider>().signInWithFacebook();
            if (success && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        const SizedBox(height: 10),
        SocialButton(
          text: 'Apple ile Devam Et',
          logo:
              const Icon(Icons.apple, color: Colors.white, size: 22),
          onPressed: () async {
            final success =
                await context.read<AuthProvider>().signInWithApple();
            if (success && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ],
    );
  }
}
