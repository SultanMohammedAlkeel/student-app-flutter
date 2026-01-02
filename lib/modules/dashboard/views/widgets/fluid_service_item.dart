import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/dashboard/models/service_model.dart';

import 'wave_shape.dart';

/// ويدجت خدمة متدفقة
/// يستخدم لعرض الخدمات بشكل متدفق وعضوي بدلاً من البطاقات التقليدية
class FluidServiceItem extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;
  final bool isExpanded;
  final double baseSize;
  final double expandedSize;
  final bool isDarkMode;

  const FluidServiceItem({
    Key? key,
    required this.service,
    required this.onTap,
    this.isExpanded = false,
    this.baseSize = 120,
    this.expandedSize = 180,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = isExpanded ? expandedSize : baseSize;
    final shadowColor = isDarkMode ? Colors.black54 : Colors.black26;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        child: Stack(
          children: [
            // الشكل المتموج
            WaveShape(
              height: size,
              width: size,
              color: service.color.withOpacity(isDarkMode ? 0.7 : 0.9),
              secondaryColor: service.secondaryColor.withOpacity(isDarkMode ? 0.5 : 0.7),
              amplitude: 15,
              frequency: 0.08,
              isAnimated: service.isAnimated,
              shadow: BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
              padding: const EdgeInsets.all(12),
              child: _buildContent(),
            ),
            
            // عدد الإشعارات
            if (service.notificationsCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    '${service.notificationsCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (service.lottieAsset != null && service.isAnimated)
          Lottie.asset(
            service.lottieAsset!,
            height: isExpanded ? 60 : 40,
            width: isExpanded ? 60 : 40,
          )
        else
          Icon(
            service.icon,
            size: isExpanded ? 50 : 35,
            color: Colors.white,
          ),
        const SizedBox(height: 8),
        Text(
          service.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isExpanded ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (isExpanded && service.description!=null) ...[
          const SizedBox(height: 8),
          Text(
            service.description?? 'default description',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}
