import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated circular progress ring that displays a probability as a
/// percentage inside a tinted arc. No external assets.
class ProbabilityRing extends StatelessWidget {
  const ProbabilityRing({
    required this.value,
    required this.size,
    super.key,
  });

  /// Target value in `[0.0, 1.0]`. Values outside the range are clamped.
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final color = _colorForValue(context, animated);
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: animated,
              trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              fillColor: color,
            ),
            child: Center(
              child: Text(
                '${(animated * 100).round()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _colorForValue(BuildContext context, double v) {
    final cs = Theme.of(context).colorScheme;
    if (v >= 0.7) return cs.primary;
    if (v >= 0.4) return cs.tertiary;
    return cs.error;
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawCircle(center, radius, trackPaint)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        fillPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
      old.fillColor != fillColor ||
      old.trackColor != trackColor;
}
