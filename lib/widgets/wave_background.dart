import 'package:flutter/material.dart';

class WaveBackground extends StatefulWidget {
  final Widget child;
  final bool animated;

  const WaveBackground({
    super.key,
    required this.child,
    this.animated = true,
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3D1515),
                Color(0xFF1A0505),
                Color(0xFF0D0000),
              ],
            ),
          ),
        ),
        if (widget.animated) ...[
          AnimatedBuilder(
            animation: _controller1,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _WavePainter(
                progress: _controller1.value,
                color: const Color(0x15E8654A),
                waveCount: 2,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller2,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _WavePainter(
                progress: _controller2.value,
                color: const Color(0x0DB84035),
                waveCount: 3,
                offsetY: 0.3,
              ),
            ),
          ),
        ],
        widget.child,
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int waveCount;
  final double offsetY;

  _WavePainter({
    required this.progress,
    required this.color,
    this.waveCount = 2,
    this.offsetY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.04;
    final startY = size.height * (0.6 + offsetY * 0.2);

    path.moveTo(0, startY);
    for (int i = 0; i < size.width.toInt(); i++) {
      final x = i.toDouble();
      final y = startY +
          waveHeight *
              _sin((x / size.width * waveCount * 3.14159) + progress * 6.28318);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    final normalized = x % (2 * 3.14159);
    if (normalized < 3.14159) {
      return normalized / 3.14159 * 2 - 1;
    } else {
      return 1 - (normalized - 3.14159) / 3.14159 * 2;
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress || old.color != color;
}
