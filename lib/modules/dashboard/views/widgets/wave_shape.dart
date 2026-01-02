import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

/// ويدجت الشكل المتموج
/// يستخدم لإنشاء أشكال عضوية متموجة في الواجهة
class WaveShape extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final Color? secondaryColor;
  final double amplitude;
  final double frequency;
  final double phase;
  final bool isAnimated;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;
  final BoxShadow? shadow;

  const WaveShape({
    Key? key,
    required this.height,
    required this.width,
    required this.color,
    this.secondaryColor,
    this.amplitude = 20.0,
    this.frequency = 0.1,
    this.phase = 0.0,
    this.isAnimated = true,
    this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.alignment = Alignment.center,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isAnimated
        ? _buildAnimatedWave()
        : _buildStaticWave();
  }

  Widget _buildStaticWave() {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _WavePainter(
          color: color,
          secondaryColor: secondaryColor,
          amplitude: amplitude,
          frequency: frequency,
          phase: phase,
          shadow: shadow,
        ),
        child: Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedWave() {
    return PlayAnimationBuilder<double>(
      tween: 0.0.tweenTo(2 * 3.14159),
      duration: 3.seconds,
      curve: Curves.easeInOut,
      builder: (context, value,  child) {
        return SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: _WavePainter(
              color: color,
              secondaryColor: secondaryColor,
              amplitude: amplitude,
              frequency: frequency,
              phase: value,
              shadow: shadow,
            ),
            child: Padding(
              padding: padding,
              child: Align(
                alignment: alignment,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final Color? secondaryColor;
  final double amplitude;
  final double frequency;
  final double phase;
  final BoxShadow? shadow;

  _WavePainter({
    required this.color,
    this.secondaryColor,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    // رسم الموجة
    for (double x = 0; x < size.width; x++) {
      final y = size.height * 0.5 +
          amplitude * sin((x * frequency) + phase);
      path.lineTo(x, y);
    }

    // إكمال المسار
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // رسم الظل إذا كان موجودًا
    if (shadow != null) {
      canvas.drawShadow(path, shadow!.color, shadow!.blurRadius, true);
    }

    // رسم التدرج إذا كان هناك لون ثانوي
    if (secondaryColor != null) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, secondaryColor!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.frequency != frequency;
  }
}
