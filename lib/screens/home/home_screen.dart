import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sparkle_background.dart';
import '../../widgets/fortune_icons.dart';
import '../tarot/tarot_screen.dart';
import '../coffee/coffee_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../palm/palm_scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _haloController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ReadingProvider>().loadReadings(uid);
      }
    });
  }

  @override
  void dispose() {
    _haloController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: _currentIndex == 0
            ? SparkleBackground(child: _buildMainContent())
            : IndexedStack(
                index: _currentIndex,
                children: const [
                  SizedBox(),          // 0 — Ana Sayfa (yukarıda özel)
                  CoffeeScreen(),      // 1
                  TarotScreen(),       // 2
                  PalmScanScreen(),    // 3
                  HistoryScreen(),     // 4
                  SettingsScreen(),    // 5
                ],
              ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildMainContent() {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.displayName ?? auth.user?.email ?? 'Güzel Ruh';
    final displayName = name.contains('@') ? 'Güzel Ruh' : name.split(' ').first;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildAvatarSection(),
              const SizedBox(height: 20),
              _buildTitle(displayName),
              const SizedBox(height: 28),
              _buildFortunCards(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: _haloController,
      builder: (_, __) {
        final haloOpacity = 0.4 + _haloController.value * 0.4;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer soft pink glow
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF8AAA).withOpacity(haloOpacity * 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Gold halo ring
            Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.gold.withOpacity(haloOpacity * 0.2),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.25 + haloOpacity * 0.15),
                  width: 1,
                ),
              ),
            ),
            // Avatar circle with 3D glossy effect
            Container(
              width: 178,
              height: 178,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.4),
                  radius: 1.0,
                  colors: [
                    Color(0xFFFF8A80),
                    Color(0xFFCC2030),
                    Color(0xFF8A0010),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8AAA).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(haloOpacity * 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF7A0018).withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                ),
              ),
            ),
            // Top gloss shine
            Positioned(
              top: 31,
              child: Container(
                width: 80,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: CustomPaint(
                size: const Size(240, 240),
                painter: _MysticSymbolsPainter(
                  progress: _haloController.value,
                ),
              ),
            ),
          ],
        );
      },
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 700.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildAvatarFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: [Color(0xFFFF9080), Color(0xFFCC1530), Color(0xFF8A0018)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 178,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8B4513).withOpacity(0.8),
                    const Color(0xFF5C2D0A),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD5B0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.face_retouching_natural,
                    size: 50, color: Color(0xFF8B4513)),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFFFE066), Color(0xFFFFD700)],
              ).createShader(b),
              child: const Text(
                '✦',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String displayName) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFE066), Color(0xFFFFD700), Color(0xFFFFA500)],
          ).createShader(bounds),
          child: Text(
            'Falcim',
            style: AppTheme.logoStyle(
              fontSize: 46,
              letterSpacing: 1.5,
              color: Colors.white,
            ).copyWith(
              shadows: [
                Shadow(
                  color: AppTheme.gold.withOpacity(0.6),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 4),
        Text(
          'Kaderini Keşfet',
          style: TextStyle(
            fontFamily: AppTheme.fontBody,
            fontSize: 13,
            color: Colors.white.withOpacity(0.85),
            letterSpacing: 2,
          ),
        )
            .animate(delay: 350.ms)
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 18),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Merhaba ',
                style: TextStyle(
                  fontFamily: AppTheme.fontBody,
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: displayName,
                style: const TextStyle(
                  fontFamily: AppTheme.fontBody,
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ' 🌙',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        )
            .animate(delay: 450.ms)
            .fadeIn(duration: 500.ms),
        const SizedBox(height: 4),
        Text(
          'Bugün neyi öğrenmek istiyorsun ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontBody,
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        )
            .animate(delay: 550.ms)
            .fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildFortunCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FortuneCard(
                icon: const TarotIcon(size: 72),
                title: 'Tarot Falı',
                onTap: () => setState(() => _currentIndex = 2),
              ).animate(delay: 650.ms).fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _FortuneCard(
                icon: const CoffeeIcon(size: 72),
                title: 'Kahve Falı',
                onTap: () => setState(() => _currentIndex = 1),
              ).animate(delay: 750.ms).fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FortuneCard(
          icon: const PalmIcon(size: 56),
          title: 'El Falı',
          onTap: () => setState(() => _currentIndex = 3),
          fullWidth: true,
        ).animate(delay: 850.ms).fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0),
      ],
    );
  }

  Widget _buildBottomNav() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A0505),
            border: Border(
              top: BorderSide(
                color: AppTheme.gold.withOpacity(0.3 + _glowController.value * 0.15),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: [
              _navItem(Icons.home_rounded,        Icons.home_rounded,        'Ana Sayfa', 0),
              _navItem(Icons.coffee_rounded,       Icons.coffee_rounded,       'Kahve',     1),
              _navItem(Icons.style_rounded,        Icons.style_rounded,        'Tarot',     2),
              _navItem(Icons.back_hand_outlined,   Icons.back_hand_rounded,    'El Falı',   3),
              _navItem(Icons.history_rounded,      Icons.history_rounded,      'Geçmiş',    4),
              _navItem(Icons.settings_rounded,     Icons.settings_rounded,     'Ayarlar',   5),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _navItem(
      IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppTheme.gold.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.gold : Colors.white.withOpacity(0.4),
          size: 24,
        ),
      ),
      label: label,
    );
  }
}

class _FortuneCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  const _FortuneCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_FortuneCard> createState() => _FortuneCardState();
}

class _FortuneCardState extends State<_FortuneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _pressController.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.fullWidth ? 96 : 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            // Outer glow shadow
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppTheme.gold.withOpacity(0.55)
                    : AppTheme.gold.withOpacity(0.22),
                blurRadius: _isPressed ? 32 : 20,
                spreadRadius: _isPressed ? 4 : 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFFF3040).withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Glass blur layer
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isPressed
                            ? [
                                const Color(0xBBFF6B55),
                                const Color(0x99CC2020),
                                const Color(0x88990A0A),
                              ]
                            : [
                                const Color(0x88FF6B55),
                                const Color(0x66CC2020),
                                const Color(0x55990A0A),
                              ],
                      ),
                    ),
                  ),
                ),

                // Inner glow — top edge
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: widget.fullWidth ? 36 : 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Inner glow — bottom edge (warm coral)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: widget.fullWidth ? 24 : 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.gold.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Gold border overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _isPressed
                          ? AppTheme.gold.withOpacity(0.9)
                          : AppTheme.gold.withOpacity(0.55),
                      width: _isPressed ? 2 : 1.5,
                    ),
                  ),
                ),

                // CENTER CONTENT — Positioned.fill garantili merkez
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: widget.fullWidth
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGlowIconWrapper(widget.icon),
                                const SizedBox(width: 16),
                                _buildLabel(widget.title, fontSize: 18),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGlowIconWrapper(widget.icon),
                                const SizedBox(height: 14),
                                _buildLabel(widget.title, fontSize: 15),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowIconWrapper(Widget icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.gold.withOpacity(0.18),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withOpacity(_isPressed ? 0.45 : 0.2),
            blurRadius: _isPressed ? 20 : 14,
            spreadRadius: _isPressed ? 4 : 1,
          ),
        ],
      ),
      child: icon,
    );
  }

  Widget _buildLabel(String text, {double fontSize = 15}) {
    return ShaderMask(
      shaderCallback: (b) => const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFE8C0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(b),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTheme.fontBody,
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _MysticSymbolsPainter extends CustomPainter {
  final double progress;
  _MysticSymbolsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final symbols = ['☽', '✦', '⋆', '✧', '◈', '❋'];

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + progress * pi * 0.3;
      final x = center.dx + cos(angle) * (radius - 10);
      final y = center.dy + sin(angle) * (radius - 10);

      final tp = TextPainter(
        text: TextSpan(
          text: symbols[i % symbols.length],
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.3 + progress * 0.2),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
          canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MysticSymbolsPainter old) => old.progress != progress;
}
