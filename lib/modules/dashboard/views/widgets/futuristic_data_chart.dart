import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ويدجت مخطط البيانات المستقبلي
/// يعرض البيانات بطريقة مبتكرة مع تأثيرات ثلاثية الأبعاد
class FuturisticDataChart extends StatefulWidget {
  final List<DataPoint> dataPoints;
  final String title;
  final double height;
  final bool isDarkMode;
  final Color accentColor;
  final bool showLabels;
  final bool animate;

  const FuturisticDataChart({
    Key? key,
    required this.dataPoints,
    required this.title,
    this.height = 200,
    required this.isDarkMode,
    required this.accentColor,
    this.showLabels = true,
    this.animate = true,
  }) : super(key: key);

  @override
  State<FuturisticDataChart> createState() => _FuturisticDataChartState();
}

class _FuturisticDataChartState extends State<FuturisticDataChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = widget.isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    
    // إيجاد القيمة القصوى للبيانات
    final maxValue = widget.dataPoints.map((point) => point.value).reduce(math.max);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.accentColor.withOpacity(0.05),
                  widget.accentColor.withOpacity(0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _DataChartPainter(
                      dataPoints: widget.dataPoints,
                      maxValue: maxValue,
                      animation: _animation.value,
                      accentColor: widget.accentColor,
                      isDarkMode: widget.isDarkMode,
                    ),
                    child: child,
                  );
                },
                child: widget.showLabels
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: widget.dataPoints.map((point) {
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    point.value.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    point.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: secondaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataChartPainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final double maxValue;
  final double animation;
  final Color accentColor;
  final bool isDarkMode;

  _DataChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.animation,
    required this.accentColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final itemWidth = width / dataPoints.length;
    
    // رسم خطوط الشبكة الأفقية
    final gridPaint = Paint()
      ..color = accentColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final int gridLines = 5;
    for (int i = 1; i <= gridLines; i++) {
      final y = height - (height * i / gridLines);
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );
    }
    
    // رسم الأعمدة
    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final normalizedValue = point.value / maxValue;
      final columnHeight = height * normalizedValue * animation;
      final columnWidth = itemWidth * 0.6;
      
      final x = i * itemWidth + (itemWidth - columnWidth) / 2;
      final y = height - columnHeight;
      
      // رسم العمود الرئيسي
      final columnPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor,
            accentColor.withOpacity(0.7),
          ],
        ).createShader(Rect.fromLTWH(x, y, columnWidth, columnHeight));
      
      final columnRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, columnWidth, columnHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      
      canvas.drawRRect(columnRect, columnPaint);
      
      // رسم انعكاس على العمود
      final reflectionPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(x, y, columnWidth / 2, columnHeight));
      
      final reflectionRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, columnWidth / 2, columnHeight),
        topLeft: const Radius.circular(8),
      );
      
      canvas.drawRRect(reflectionRect, reflectionPaint);
      
      // رسم توهج في الأعلى
      final glowPaint = Paint()
        ..color = accentColor.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        Offset(x + columnWidth / 2, y),
        4 * animation,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DataChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

/// نموذج نقطة البيانات
class DataPoint {
  final String label;
  final double value;
  final Color? color;

  DataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}
