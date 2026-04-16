import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumTarotCard extends StatefulWidget {
  final String emoji;
  final String name;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const PremiumTarotCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  State<PremiumTarotCard> createState() => _PremiumTarotCardState();
}

class _PremiumTarotCardState extends State<PremiumTarotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return AnimatedScale(
            scale: _isPressed ? 1.05 : (widget.isSelected ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 150),
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    final glowIntensity = widget.isSelected
        ? (0.6 + _controller.value * 0.4)
        : widget.isDisabled
            ? 0.0
            : (0.25 + sin(_controller.value * 2 * pi) * 0.15);

    return CustomPaint(
      painter: _EnergyBorderPainter(
        progress: _controller.value,
        isSelected: widget.isSelected,
        isDisabled: widget.isDisabled,
        glowIntensity: glowIntensity,
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: widget.isDisabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A0A0A), Color(0xFF0D0505)],
                )
              : widget.isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFCC3030),
                        Color(0xFF881010),
                        Color(0xFF550505),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7A1515).withOpacity(0.9),
                        const Color(0xFF4A0A0A).withOpacity(0.9),
                      ],
                    ),
          boxShadow: widget.isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(glowIntensity * 0.5),
                    blurRadius: widget.isSelected ? 18 : 10,
                    spreadRadius: widget.isSelected ? 3 : 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
        ),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    if (!widget.isSelected) {
      return _buildClosedCard();
    }
    return _buildOpenCard();
  }

  Widget _buildClosedCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _CardPatternPainter(progress: _controller.value)),
          if (!widget.isDisabled)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppTheme.gold.withOpacity(0.6 + _controller.value * 0.3),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Icon(
                Icons.lock_outline,
                color: Colors.white.withOpacity(0.2),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpenCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _CardPatternPainter(progress: _controller.value, selected: true)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.black, size: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnergyBorderPainter extends CustomPainter {
  final double progress;
  final bool isSelected;
  final bool isDisabled;
  final double glowIntensity;

  _EnergyBorderPainter({
    required this.progress,
    required this.isSelected,
    required this.isDisabled,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isDisabled) return;

    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(11));

    final borderPaint = Paint()
      ..color = isSelected
          ? AppTheme.gold.withOpacity(0.9)
          : AppTheme.primary.withOpacity(0.5 + glowIntensity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 3 : 1.5);

    canvas.drawRRect(rrect, borderPaint);

    if (!isDisabled) {
      _drawEnergyLine(canvas, size);
    }
  }

  void _drawEnergyLine(Canvas canvas, Size size) {
    final perimeter = 2 * (size.width + size.height);
    final dotPos = (progress * perimeter) % perimeter;
    final trailLength = perimeter * 0.12;

    final energyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 30; i++) {
      final t = i / 30.0;
      final pos = (dotPos - t * trailLength + perimeter) % perimeter;
      final opacity = (1.0 - t) * (isSelected ? 0.9 : 0.6);
      final pt = _posToPoint(pos, size);

      energyPaint.color = isSelected
          ? AppTheme.gold.withOpacity(opacity)
          : AppTheme.primary.withOpacity(opacity);

      if (i < 29) {
        final nextPos = (dotPos - (i + 1) / 30.0 * trailLength + perimeter) % perimeter;
        final nextPt = _posToPoint(nextPos, size);
        canvas.drawLine(pt, nextPt, energyPaint);
      }

      if (i == 0) {
        final glowPaint = Paint()
          ..color = (isSelected ? AppTheme.gold : AppTheme.primary)
              .withOpacity(opacity * 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(pt, isSelected ? 3.5 : 2.5, glowPaint);
      }
    }
  }

  Offset _posToPoint(double pos, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 11.0;

    if (pos < w) return Offset(pos, 1.5);
    pos -= w;
    if (pos < h) return Offset(w - 1.5, pos);
    pos -= h;
    if (pos < w) return Offset(w - pos, h - 1.5);
    pos -= w;
    return Offset(1.5, h - pos);
  }

  @override
  bool shouldRepaint(_EnergyBorderPainter old) =>
      old.progress != progress || old.isSelected != isSelected;
}

class _CardPatternPainter extends CustomPainter {
  final double progress;
  final bool selected;

  _CardPatternPainter({required this.progress, this.selected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(selected ? 0.06 : 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 1; i <= 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width * 0.3 * i,
          height: size.height * 0.25 * i,
        ),
        paint,
      );
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.4;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi + progress * pi * 0.2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(
          cx + cos(angle) * size.width,
          cy + sin(angle) * size.height,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter old) => old.progress != progress;
}

class GlowPhotoSlot extends StatefulWidget {
  final Widget? child;
  final String label;
  final String icon;
  final bool hasImage;
  final VoidCallback onTap;

  const GlowPhotoSlot({
    super.key,
    this.child,
    required this.label,
    required this.icon,
    required this.hasImage,
    required this.onTap,
  });

  @override
  State<GlowPhotoSlot> createState() => _GlowPhotoSlotState();
}

class _GlowPhotoSlotState extends State<GlowPhotoSlot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _EnergyBorderPainter(
              progress: _controller.value,
              isSelected: widget.hasImage,
              isDisabled: false,
              glowIntensity: 0.4 + sin(_controller.value * 2 * pi) * 0.2,
            ),
            child: Container(
              height: 130,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: widget.hasImage
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.35),
                boxShadow: [
                  BoxShadow(
                    color: widget.hasImage
                        ? AppTheme.gold.withOpacity(0.25)
                        : AppTheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: widget.hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: widget.child,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.icon,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.primary.withOpacity(0.8),
                          size: 20,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
