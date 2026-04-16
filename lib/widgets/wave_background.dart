import 'package:flutter/material.dart';
import 'sparkle_background.dart';

class WaveBackground extends StatelessWidget {
  final Widget child;
  final bool animated;

  const WaveBackground({
    super.key,
    required this.child,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SparkleBackground(child: child);
  }
}
