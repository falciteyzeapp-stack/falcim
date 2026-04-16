import 'dart:math';
import 'package:flutter/material.dart';

class SparkleBackground extends StatefulWidget {
  final Widget child;
  const SparkleBackground({super.key, required this.child});

  @override
  State<SparkleBackground> createState() => _SparkleBackgroundState();
}

class _SparkleBackgroundState extends State<SparkleBackground>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  final List<_Firefly> _fireflies = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);

    // 200 ateşböceği — pırlanta gibi bol, mikroskopik, her yerde
    for (int i = 0; i < 200; i++) {
      _fireflies.add(_Firefly(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 1.4 + 0.6,
        phase: _rng.nextDouble(),
        blinkSpeed: _rng.nextDouble() * 1.2 + 0.3,
        driftX: (_rng.nextDouble() - 0.5) * 0.015,
        driftY: (_rng.nextDouble() - 0.5) * 0.015,
        isCross: i % 4 == 0,
      ));
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // — Arka plan degrade —
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final t = _pulseCtrl.value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                        const Color(0xFFFF3D50), const Color(0xFFEE1E2E), t)!,
                    Color.lerp(
                        const Color(0xFFCC1020), const Color(0xFF9A0818), t)!,
                    const Color(0xFF780010),
                    const Color(0xFF4A0008),
                  ],
                  stops: const [0.0, 0.28, 0.62, 1.0],
                ),
              ),
            );
          },
        ),

        // — Merkez büyülü aura —
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final glow = 0.12 + _pulseCtrl.value * 0.10;
            return Align(
              alignment: const Alignment(0, -0.2),
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(glow * 0.18),
                      const Color(0xFFFF5060).withOpacity(glow * 0.45),
                      const Color(0xFFCC0020).withOpacity(glow * 0.25),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // — Ateşböceği katmanı —
        AnimatedBuilder(
          animation: _mainCtrl,
          builder: (_, __) => CustomPaint(
            painter: _FireflyPainter(
              fireflies: _fireflies,
              progress: _mainCtrl.value,
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

class _Firefly {
  final double x, y, size, phase, blinkSpeed, driftX, driftY;
  final bool isCross;
  const _Firefly({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.blinkSpeed,
    required this.driftX,
    required this.driftY,
    required this.isCross,
  });
}

class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double progress;
  const _FireflyPainter({required this.fireflies, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in fireflies) {
      // Yanıp sönme — sin dalgası, her biri farklı hızda
      final blink = ((progress * f.blinkSpeed + f.phase) % 1.0);
      final opacity = pow(sin(blink * pi), 1.8).toDouble().clamp(0.0, 1.0);
      if (opacity < 0.04) continue;

      final cx = (f.x + sin(progress * 2 * pi * 0.7 + f.phase * 4) * f.driftX) *
          size.width;
      final cy = (f.y + cos(progress * 2 * pi * 0.5 + f.phase * 6) * f.driftY) *
          size.height;

      if (f.isCross) {
        _drawMicroCross(canvas, Offset(cx, cy), f.size, opacity);
      } else {
        _drawFirefly(canvas, Offset(cx, cy), f.size, opacity);
      }
    }
  }

  // Mikroskopik 4-kollu ışık (kar tanesi gibi)
  void _drawMicroCross(Canvas canvas, Offset c, double sz, double op) {
    // Çok küçük glow halkası
    canvas.drawCircle(
      c,
      sz * 2.2,
      Paint()
        ..color = Colors.white.withOpacity(op * 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz * 1.8),
    );
    // 4 ince kol — gerçekten mikroskopik
    final p = Paint()
      ..color = Colors.white.withOpacity(op * 0.85)
      ..strokeWidth = sz * 0.25
      ..strokeCap = StrokeCap.round;
    final len = sz * 1.6;
    canvas.drawLine(Offset(c.dx, c.dy - len), Offset(c.dx, c.dy + len), p);
    canvas.drawLine(Offset(c.dx - len, c.dy), Offset(c.dx + len, c.dy), p);
    // Merkez beyaz nokta
    canvas.drawCircle(c, sz * 0.18, Paint()..color = Colors.white.withOpacity(op));
  }

  // Ateşböceği — soft beyaz glow nokta
  void _drawFirefly(Canvas canvas, Offset c, double sz, double op) {
    // Dış soft aura (çok küçük)
    canvas.drawCircle(
      c,
      sz * 2.8,
      Paint()
        ..color = Colors.white.withOpacity(op * 0.07)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz * 2.0),
    );
    // İç parlak çekirdek
    canvas.drawCircle(
      c,
      sz * 0.85,
      Paint()
        ..color = Colors.white.withOpacity(op * 0.50)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz * 0.5),
    );
    // Merkez beyaz nokta
    canvas.drawCircle(
      c,
      sz * 0.28,
      Paint()..color = Colors.white.withOpacity(op * 0.95),
    );
  }

  @override
  bool shouldRepaint(_FireflyPainter old) => old.progress != progress;
}
