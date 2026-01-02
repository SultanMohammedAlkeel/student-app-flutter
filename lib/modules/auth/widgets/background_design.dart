import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

class BackgroundDesign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // إضافة Directionality للتصميم RTL
      child: Stack(
        children: [
          // الخلفية الأساسية
          Container(
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground, // استخدام لون الخلفية من الثيم
            height: 0.4.sh,
          ),

          // الدوائر الكبيرة في الأعلى اليسار (بعد عكس التصميم)
          _buildCircleGroup(
            left: 0, // تغيير من right إلى left
            top: -0.05.sh,
            circles: [
              {'size': 200, 'depth': -3, 'convex': true},
              {'size': 160, 'depth': 3, 'convex': false},
              {'size': 120, 'depth': -3, 'convex': true},
              {'size': 80, 'depth': 3, 'convex': false},
            ],
          ),

          // الدوائر المتوسطة في اليمين (بعد عكس التصميم)
          _buildCircleGroup(
            right: 0.01.sw, // تغيير من left إلى right
            top: 0.05.sh,
            circles: [
              {'size': 150, 'depth': 3, 'convex': true},
              {'size': 130, 'depth': -3, 'convex': true},
              {'size': 60, 'depth': 3, 'convex': false},
              //   {'size': 30, 'depth': 3, 'convex': false},
            ],
          ),

          // الدوائر الصغيرة في المنتصف السفلي
          _buildCircleGroup(
            right: 0.35.sw, // تغيير من left إلى right
            bottom: 0.07.sh,
            circles: [
              {'size': 80, 'depth': 3, 'convex': true},
              {'size': 60, 'depth': -3, 'convex': true},
              {'size': 40, 'depth': 3, 'convex': true},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleGroup({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required List<Map<String, dynamic>> circles,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Stack(
        alignment: Alignment.center,
        children: circles.map((circle) {
          return _buildCircle(
            circle['size'].toDouble(),
            circle['depth'].toDouble(),
            convex: circle['convex'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCircle(double size, double depth, {bool convex = false}) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: convex ? NeumorphicShape.convex : NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.circle(),
        depth: -1 * depth, // تعديل العمق لجعل الدوائر أكثر بروزاً
        intensity: 0.8,
        color: Get.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        lightSource: LightSource.topRight, // تغيير مصدر الضوء ليتناسب مع RTL
      ),
      child: SizedBox(
        width: size.w,
        height: size.w,
      ),
    );
  }
}
