import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ويدجت مخطط الأداء الدائري المستقبلي
/// يعرض نسبة الإنجاز بطريقة مبتكرة مع تأثيرات متقدمة
class FuturisticCircularProgress extends StatefulWidget {
  final double value; // قيمة من 0 إلى 1
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDarkMode;
  final String label;
  final String? sublabel;

  const FuturisticCircularProgress({
    Key? key,
    required this.value,
    this.size = 150,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDarkMode,
    required this.label,
    this.sublabel,
  }) : super(key: key);

  @override
  State<FuturisticCircularProgress> createState() => _FuturisticCircularProgressState();
}

class _FuturisticCircularProgressState extends State<FuturisticCircularProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(FuturisticCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // طبقة الخلفية
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: widget.primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              
              // طبقة التقدم
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  value: _animation.value,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,
                  strokeWidth: 8,
                ),
              ),
              
              // طبقة النص
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.size * 0.1,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryColor,
                    ),
                  ),
                  if (widget.sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.sublabel!,
                      style: TextStyle(
                        fontSize: widget.size * 0.07,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
              
              // تأثير توهج على حافة التقدم
              Positioned(
                top: widget.size * 0.5 - widget.size * 0.5 * math.sin(2 * math.pi * (1 - _animation.value)),
                left: widget.size * 0.5 - widget.size * 0.5 * math.cos(2 * math.pi * (1 - _animation.value)),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.secondaryColor,
                        widget.secondaryColor.withOpacity(0),
                      ],
                      stops: const [0.1, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.secondaryColor.withOpacity(0.7),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    
    // رسم الدائرة الخلفية
    final backgroundPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // رسم التقدم
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // إنشاء تدرج لوني للتقدم
    final rect = Rect.fromCircle(center: center, radius: radius);
    progressPaint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      tileMode: TileMode.clamp,
      colors: [
        primaryColor,
        secondaryColor,
      ],
    ).createShader(rect);
    
    // رسم قوس التقدم
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // بدء من الأعلى
      2 * math.pi * value, // زاوية التقدم
      false,
      progressPaint,
    );
    
    // رسم نقاط صغيرة على طول المسار
    final int totalDots = 36; // عدد النقاط
    final double dotRadius = strokeWidth / 4;
    final Paint dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < totalDots; i++) {
      final double angle = i * (2 * math.pi / totalDots) - math.pi / 2;
      if (i / totalDots <= value) {
        final double x = center.dx + radius * math.cos(angle);
        final double y = center.dy + radius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
