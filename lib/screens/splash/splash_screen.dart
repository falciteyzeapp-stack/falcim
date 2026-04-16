import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sparkle_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SparkleBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(height: 28),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFFE066),
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Falcim',
                    style: TextStyle(
                      fontFamily: AppTheme.fontLogo,
                      fontSize: 48,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Falcım\'ye Hoşgeldin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1.5,
                  ),
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 6),
                Text(
                  'Kaderini Keşfet ✨',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gold.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 60),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppTheme.gold.withOpacity(0.8),
                    strokeWidth: 2,
                  ),
                ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final glow = 0.4 + _pulseController.value * 0.4;
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.gold.withOpacity(glow * 0.4),
                AppTheme.primary.withOpacity(glow * 0.2),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withOpacity(glow * 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8A70),
              Color(0xFFCC2020),
              Color(0xFF7A0A0A),
            ],
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/avatar.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.face_retouching_natural,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      )
          .animate()
          .scale(
            duration: 900.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 600.ms),
    );
  }
}
