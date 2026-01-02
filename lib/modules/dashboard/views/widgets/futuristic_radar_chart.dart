import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/// ويدجت مخطط الرادار المستقبلي
/// يعرض البيانات متعددة الأبعاد بطريقة مبتكرة مع تأثيرات متقدمة
class FuturisticRadarChart extends StatefulWidget {
  final List<RadarDataSet> dataSets;
  final List<String> categories;
  final double size;
  final bool isDarkMode;
  final bool animate;

  const FuturisticRadarChart({
    Key? key,
    required this.dataSets,
    required this.categories,
    this.size = 300,
    required this.isDarkMode,
    this.animate = true,
  }) : super(key: key);

  @override
  State<FuturisticRadarChart> createState() => _FuturisticRadarChartState();
}

class _FuturisticRadarChartState extends State<FuturisticRadarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarChartPainter(
                  dataSets: widget.dataSets,
                  categories: widget.categories,
                  animation: _animation.value,
                  isDarkMode: widget.isDarkMode,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarDataSet> dataSets;
  final List<String> categories;
  final double animation;
  final bool isDarkMode;

  _RadarChartPainter({
    required this.dataSets,
    required this.categories,
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final categoryCount = categories.length;
    
    // رسم الشبكة الخلفية
    _drawGrid(canvas, center, radius, categoryCount);
    
    // رسم الفئات
    _drawCategories(canvas, center, radius, categoryCount);
    
    // رسم البيانات
    for (final dataSet in dataSets) {
      _drawDataSet(canvas, center, radius, categoryCount, dataSet);
    }
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, int categoryCount) {
    final gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // رسم الدوائر المتحدة المركز
    final int rings = 5;
    for (int i = 1; i <= rings; i++) {
      final ringRadius = radius * i / rings;
      canvas.drawCircle(center, ringRadius, gridPaint);
    }
    
    // رسم الخطوط من المركز إلى كل فئة
    for (int i = 0; i < categoryCount; i++) {
      final angle = 2 * math.pi * i / categoryCount - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }
  }

  void _drawCategories(Canvas canvas, Offset center, double radius, int categoryCount) {
    final textColor = isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black87;
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    
    for (int i = 0; i < categoryCount; i++) {
      final angle = 2 * math.pi * i / categoryCount - math.pi / 2;
      final x = center.dx + (radius + 20) * math.cos(angle);
      final y = center.dy + (radius + 20) * math.sin(angle);
      
      final textSpan = TextSpan(
        text: categories[i],
        style: textStyle,
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawDataSet(Canvas canvas, Offset center, double radius, int categoryCount, RadarDataSet dataSet) {
    final path = Path();
    final points = <Offset>[];
    
    // إنشاء مسار البيانات
    for (int i = 0; i < categoryCount; i++) {
      final angle = 2 * math.pi * i / categoryCount - math.pi / 2;
      final value = dataSet.values[i] * animation;
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      points.add(Offset(x, y));
    }
    
    path.close();
    
    // رسم المنطقة المملوءة
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0),
        radius: 1.0,
        colors: [
          dataSet.color.withOpacity(0.7),
          dataSet.color.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, fillPaint);
    
    // رسم الحدود
    final strokePaint = Paint()
      ..color = dataSet.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(path, strokePaint);
    
    // رسم النقاط
    final dotPaint = Paint()
      ..color = dataSet.color
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      // رسم توهج خلف النقطة
      final glowPaint = Paint()
        ..color = dataSet.color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(point, 6 * animation, glowPaint);
      
      // رسم النقطة
      canvas.drawCircle(point, 4, dotPaint);
      
      // رسم حلقة بيضاء حول النقطة
      final ringPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawCircle(point, 4, ringPaint);
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

/// نموذج مجموعة بيانات الرادار
class RadarDataSet {
  final String name;
  final List<double> values; // قيم من 0 إلى 1
  final Color color;

  RadarDataSet({
    required this.name,
    required this.values,
    required this.color,
  });
}

// استيراد dart:ui للتأثيرات المرئية
