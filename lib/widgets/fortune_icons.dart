import 'dart:math';
import 'package:flutter/material.dart';

/// Tarot kart simgesi — 3 kart üst üste, altın kenarlı, ay sembolü
class TarotIcon extends StatelessWidget {
  final double size;
  final Color glowColor;
  const TarotIcon({super.key, this.size = 64, this.glowColor = const Color(0xFFE6C36A)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TarotPainter(glowColor: glowColor)),
    );
  }
}

/// Kahve fincanı simgesi — fincan, tabak, buhar kıvrımları
class CoffeeIcon extends StatefulWidget {
  final double size;
  final Color glowColor;
  const CoffeeIcon({super.key, this.size = 64, this.glowColor = const Color(0xFFFF8060)});

  @override
  State<CoffeeIcon> createState() => _CoffeeIconState();
}

class _CoffeeIconState extends State<CoffeeIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _CoffeePainter(progress: _ctrl.value, glowColor: widget.glowColor)),
      ),
    );
  }
}

/// El falı simgesi — açık avuç, parlayan çizgiler
class PalmIcon extends StatefulWidget {
  final double size;
  final Color glowColor;
  const PalmIcon({super.key, this.size = 64, this.glowColor = const Color(0xFF80CFFF)});

  @override
  State<PalmIcon> createState() => _PalmIconState();
}

class _PalmIconState extends State<PalmIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _PalmPainter(progress: _ctrl.value, glowColor: widget.glowColor)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// TAROT PAINTER
// ─────────────────────────────────────────────────
class _TarotPainter extends CustomPainter {
  final Color glowColor;
  _TarotPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final cw = s.width * 0.38;
    final ch = s.height * 0.55;

    void drawCard(double dx, double dy, double angle, double opacity) {
      canvas.save();
      canvas.translate(cx + dx, cy + dy);
      canvas.rotate(angle);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
        const Radius.circular(5),
      );

      // Glow
      canvas.drawRRect(
        rect,
        Paint()
          ..color = glowColor.withOpacity(opacity * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Card background gradient
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A0A1A).withOpacity(opacity),
              const Color(0xFF1A0510).withOpacity(opacity),
            ],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch)),
      );

      // Gold border
      canvas.drawRRect(
        rect,
        Paint()
          ..color = glowColor.withOpacity(opacity * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Inner pattern — diamond shape
      final dp = Paint()
        ..color = glowColor.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      final dPath = Path()
        ..moveTo(0, -ch * 0.3)
        ..lineTo(cw * 0.25, 0)
        ..lineTo(0, ch * 0.3)
        ..lineTo(-cw * 0.25, 0)
        ..close();
      canvas.drawPath(dPath, dp);

      // Star at top
      final sp = Paint()..color = glowColor.withOpacity(opacity);
      _drawStar(canvas, Offset(0, -ch * 0.18), 4, sp);

      canvas.restore();
    }

    // Back cards (rotated)
    drawCard(-s.width * 0.13, s.height * 0.05, -0.22, 0.55);
    drawCard(s.width * 0.13, s.height * 0.05, 0.22, 0.55);
    // Front card
    drawCard(0, -s.height * 0.04, 0, 1.0);

    // Moon symbol at top
    final moonPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final moonPath = Path();
    moonPath.addArc(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.44), width: 14, height: 14), -0.4, pi + 0.8);
    canvas.drawPath(moonPath, moonPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(
        Offset(center.dx + cos(a) * r * 1.4, center.dy + sin(a) * r * 1.4),
        Offset(center.dx + cos(a) * r * 0.1, center.dy + sin(a) * r * 0.1),
        paint..strokeWidth = 1.2..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(center, r * 0.3, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(_TarotPainter old) => false;
}

// ─────────────────────────────────────────────────
// COFFEE PAINTER
// ─────────────────────────────────────────────────
class _CoffeePainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  _CoffeePainter({required this.progress, required this.glowColor});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 + s.height * 0.05;
    final r = s.width * 0.32;

    // Outer glow
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.1,
      Paint()
        ..color = glowColor.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Cup body
    final cupPath = Path();
    cupPath.moveTo(cx - r * 0.7, cy - r * 0.4);
    cupPath.lineTo(cx - r * 0.55, cy + r * 0.55);
    cupPath.quadraticBezierTo(cx, cy + r * 0.72, cx + r * 0.55, cy + r * 0.55);
    cupPath.lineTo(cx + r * 0.7, cy - r * 0.4);
    cupPath.close();
    canvas.drawPath(
      cupPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF3A1010), const Color(0xFF1E0808)],
        ).createShader(Rect.fromLTWH(cx - r, cy - r, r * 2, r * 2)),
    );
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = glowColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Cup rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - r * 0.4), width: r * 1.4, height: r * 0.3),
      Paint()
        ..color = glowColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Handle
    final handlePath = Path();
    handlePath.addArc(
      Rect.fromCenter(center: Offset(cx + r * 0.78, cy + r * 0.08), width: r * 0.5, height: r * 0.65),
      -pi / 2.2, pi,
    );
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = glowColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Saucer
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.65), width: r * 1.8, height: r * 0.25),
      Paint()
        ..color = glowColor.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Animated steam curls
    for (int i = 0; i < 3; i++) {
      final phase = progress + i * 0.33;
      final steamPath = Path();
      final sx = cx + (i - 1) * r * 0.3;
      final baseY = cy - r * 0.42;
      steamPath.moveTo(sx, baseY);
      steamPath.cubicTo(
        sx + sin(phase * 2 * pi) * r * 0.18, baseY - r * 0.25,
        sx - sin(phase * 2 * pi + 1) * r * 0.18, baseY - r * 0.5,
        sx + sin(phase * 2 * pi + 2) * r * 0.1, baseY - r * 0.75,
      );
      canvas.drawPath(
        steamPath,
        Paint()
          ..color = Colors.white.withOpacity(0.25 * (1 - (phase % 1.0)))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Small heart inside cup
    final heartPaint = Paint()
      ..color = const Color(0xFFFF6060).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    _drawHeart(canvas, Offset(cx, cy + r * 0.05), r * 0.18, heartPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + r * 0.6);
    path.cubicTo(center.dx - r * 2, center.dy - r * 0.6, center.dx - r * 2, center.dy - r * 2, center.dx, center.dy - r * 0.8);
    path.cubicTo(center.dx + r * 2, center.dy - r * 2, center.dx + r * 2, center.dy - r * 0.6, center.dx, center.dy + r * 0.6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CoffeePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────
// PALM PAINTER — gerçek el silueti + parlayan çizgiler
// ─────────────────────────────────────────────────
class _PalmPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  _PalmPainter({required this.progress, required this.glowColor});

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2 + s.height * 0.08;
    final scale = s.width / 64.0;

    // — Avuç içi dış aura —
    canvas.drawCircle(
      Offset(cx, cy + 2 * scale),
      22 * scale,
      Paint()
        ..color = glowColor.withOpacity(0.15 + progress * 0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * scale),
    );

    // — El (avuç + parmaklar) dolgu —
    final handPath = _buildHandPath(cx, cy, scale);
    canvas.drawPath(
      handPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.2),
          colors: [const Color(0xFF4A1528), const Color(0xFF1E0810)],
        ).createShader(Rect.fromCenter(
            center: Offset(cx, cy), width: 50 * scale, height: 60 * scale)),
    );

    // — El kenar çizgisi —
    canvas.drawPath(
      handPath,
      Paint()
        ..color = glowColor.withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 * scale
        ..strokeJoin = StrokeJoin.round,
    );

    // — Yaşam çizgisi (life line) — yeşil —
    final lifeLine = Path()
      ..moveTo(cx - 6 * scale, cy - 8 * scale)
      ..cubicTo(
        cx - 14 * scale, cy - 2 * scale,
        cx - 16 * scale, cy + 6 * scale,
        cx - 10 * scale, cy + 14 * scale,
      );
    _drawGlowLine(canvas, lifeLine, const Color(0xFF50FF90),
        0.55 + progress * 0.35, scale);

    // — Kalp çizgisi (heart line) — pembe —
    final heartLine = Path()
      ..moveTo(cx - 13 * scale, cy - 4 * scale)
      ..cubicTo(
        cx - 5 * scale, cy - 7 * scale,
        cx + 5 * scale, cy - 6 * scale,
        cx + 12 * scale, cy - 2 * scale,
      );
    _drawGlowLine(canvas, heartLine, const Color(0xFFFF6090),
        0.55 + (1 - progress) * 0.35, scale);

    // — Kader çizgisi (fate line) — altın —
    final fateLine = Path()
      ..moveTo(cx + 2 * scale, cy + 14 * scale)
      ..cubicTo(
        cx + 1 * scale, cy + 6 * scale,
        cx, cy - 2 * scale,
        cx - 2 * scale, cy - 10 * scale,
      );
    _drawGlowLine(canvas, fateLine, const Color(0xFFFFD060),
        0.45 + sin(progress * pi) * 0.3, scale);

    // — Baş çizgisi (head line) — beyaz —
    final headLine = Path()
      ..moveTo(cx - 13 * scale, cy - 1 * scale)
      ..cubicTo(
        cx - 4 * scale, cy + 1 * scale,
        cx + 4 * scale, cy + 1 * scale,
        cx + 12 * scale, cy + 3 * scale,
      );
    _drawGlowLine(canvas, headLine, Colors.white,
        0.4 + progress * 0.25, scale);

    // — Merkez enerji noktası —
    canvas.drawCircle(
      Offset(cx, cy + 3 * scale),
      3 * scale,
      Paint()
        ..color = glowColor.withOpacity(0.5 + progress * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * scale),
    );
    canvas.drawCircle(
      Offset(cx, cy + 3 * scale),
      1.2 * scale,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
  }

  // Gerçekçi el silueti — 5 parmak
  Path _buildHandPath(double cx, double cy, double sc) {
    final p = Path();

    // Avuç tabanı
    p.moveTo(cx - 14 * sc, cy + 16 * sc);
    p.quadraticBezierTo(
        cx - 16 * sc, cy + 20 * sc, cx - 10 * sc, cy + 22 * sc);
    p.lineTo(cx + 10 * sc, cy + 22 * sc);
    p.quadraticBezierTo(
        cx + 16 * sc, cy + 20 * sc, cx + 14 * sc, cy + 16 * sc);

    // Serçe parmak
    p.lineTo(cx + 14 * sc, cy - 2 * sc);
    p.quadraticBezierTo(
        cx + 14 * sc, cy - 8 * sc, cx + 11 * sc, cy - 8 * sc);
    p.quadraticBezierTo(
        cx + 8 * sc, cy - 8 * sc, cx + 8 * sc, cy - 2 * sc);

    // Yüzük parmak
    p.lineTo(cx + 8 * sc, cy - 4 * sc);
    p.quadraticBezierTo(
        cx + 8 * sc, cy - 14 * sc, cx + 5 * sc, cy - 14 * sc);
    p.quadraticBezierTo(
        cx + 2 * sc, cy - 14 * sc, cx + 2 * sc, cy - 4 * sc);

    // Orta parmak
    p.lineTo(cx + 2 * sc, cy - 6 * sc);
    p.quadraticBezierTo(
        cx + 2 * sc, cy - 17 * sc, cx - 1 * sc, cy - 17 * sc);
    p.quadraticBezierTo(
        cx - 4 * sc, cy - 17 * sc, cx - 4 * sc, cy - 6 * sc);

    // İşaret parmak
    p.lineTo(cx - 4 * sc, cy - 4 * sc);
    p.quadraticBezierTo(
        cx - 4 * sc, cy - 14 * sc, cx - 7 * sc, cy - 14 * sc);
    p.quadraticBezierTo(
        cx - 10 * sc, cy - 14 * sc, cx - 10 * sc, cy - 4 * sc);

    // Başparmak
    p.lineTo(cx - 10 * sc, cy + 2 * sc);
    p.quadraticBezierTo(
        cx - 14 * sc, cy - 4 * sc, cx - 17 * sc, cy - 2 * sc);
    p.quadraticBezierTo(
        cx - 20 * sc, cy + 2 * sc, cx - 16 * sc, cy + 8 * sc);
    p.lineTo(cx - 14 * sc, cy + 16 * sc);

    p.close();
    return p;
  }

  void _drawGlowLine(
      Canvas canvas, Path path, Color color, double opacity, double sc) {
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(opacity * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * sc
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * sc));
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * sc
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PalmPainter old) => old.progress != progress;
}
