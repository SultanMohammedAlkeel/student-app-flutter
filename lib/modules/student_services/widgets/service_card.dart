import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

class ServiceCard extends StatelessWidget {
  final dynamic service;
  final bool isDarkMode;
  final VoidCallback onTap;
  final bool isPriority;
  final Color textColor;
  final Color secondaryTextColor;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.isDarkMode,
    required this.onTap,
    required this.isPriority,
    required this.textColor,
    required this.secondaryTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isPriority
        ? _buildPriorityServiceCard()
        : _buildSecondaryServiceCard();
  }

  Widget _buildPriorityServiceCard() {
    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: AppConstants.getDepth(isDarkMode),
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          color: isDarkMode ? const Color(0xFF3E3F58) : const Color(0xFFE4E6F1),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            // gradient: LinearGradient(
            //   begin: Alignment.topRight,
            //   end: Alignment.bottomLeft,
            //   colors: [
            //     AppColors.darkBackground.withOpacity(isDarkMode ? 0.15 : 0.1),
            //     service.color.withOpacity(isDarkMode ? 0.15 : 0.1),
            //   ],
            // ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  service.iconData,
                  size: 28,
                  color: service.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryServiceCard() {
    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: AppConstants.getDepth(isDarkMode),
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          color:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     service.color.withOpacity(isDarkMode ? 0.15 : 0.1),
            //     service.color.withOpacity(isDarkMode ? 0.15 : 0.1),
            //   ],
            // ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service.iconData,
                  size: 40,
                  color: service.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
