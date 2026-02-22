import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';
import '../../widgets/coral_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gizlilik politikası ve kullanım koşullarını kabul etmelisiniz',
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.registerWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.textPrimary),
                      ),
                      const Expanded(
                        child: Text(
                          'Hesap Oluştur',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: AppTheme.gold, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'İlk kayıt için 1 ücretsiz fal hakkı hediyemiz!',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontFamily: 'Cinzel',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 28),
                  _buildErrorBanner(),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ad soyad giriniz';
                      }
                      return null;
                    },
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 14),
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
                  ).animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 14),
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
                      if (v.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontFamily: 'Cinzel'),
                    decoration: InputDecoration(
                      labelText: 'Şifre Tekrar',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ).animate(delay: 250.ms).fadeIn(),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.primary;
                          }
                          return Colors.transparent;
                        }),
                        side: const BorderSide(color: AppTheme.primary),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Cinzel',
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(text: 'Okudum, kabul ediyorum: '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                          context, '/terms'),
                                      child: const Text(
                                        'Kullanım Koşulları',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontFamily: 'Cinzel',
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' ve '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                          context, '/privacy'),
                                      child: const Text(
                                        'Gizlilik Politikası',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontFamily: 'Cinzel',
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => CoralButton(
                      text: 'Kayıt Ol',
                      isLoading: auth.isLoading,
                      onPressed: _register,
                    ),
                  ).animate(delay: 350.ms).fadeIn(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Zaten hesabın var mı? ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Giriş Yap',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            border: Border.all(color: AppTheme.error.withOpacity(0.5)),
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
}
