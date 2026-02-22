import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wave_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar()
                  .animate()
                  .scale(
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 32),
              const Text(
                'Falcı Teyze',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cinzel',
                  letterSpacing: 2,
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Falcı Teyze\'ye Hoşgeldin',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Cinzel',
                  letterSpacing: 1,
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 60),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF5D2020),
            Color(0xFF3D1010),
          ],
        ),
        border: Border.all(color: AppTheme.primary, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.auto_awesome,
            size: 70,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
