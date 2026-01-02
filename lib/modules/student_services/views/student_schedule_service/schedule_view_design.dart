import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ScheduleViewDesign {
  // ألوان الخلفية والبطاقات
  static Color getBackgroundColor(bool isDarkMode) {
    return Get.isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  static Color getCardColor(bool isDarkMode) {
    return Get.isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  // ألوان النصوص
  static Color getTextColor(bool isDarkMode) {
    return Get.isDarkMode ? Colors.white : const Color(0xFF333333);
  }

  static Color getSecondaryTextColor(bool isDarkMode) {
    return Get.isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);
  }

  // أنماط النصوص
  static TextStyle getTitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  static TextStyle getSubtitleStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  static TextStyle getBodyStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 14,
      color: getTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  static TextStyle getSmallStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 12,
      color: getSecondaryTextColor(isDarkMode),
      fontFamily: 'Tajawal',
    );
  }

  // أنماط Neumorphic محسنة
  static NeumorphicStyle getNeumorphicStyle(bool isDarkMode,
      {BorderRadius? borderRadius}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      depth: 1, // زيادة العمق إلى 3 كما طلب المستخدم
      intensity: 1, // تعديل الكثافة إلى 1 كما طلب المستخدم
      //  surfaceIntensity: 0.2,
      boxShape: NeumorphicBoxShape.roundRect(
          borderRadius ?? BorderRadius.circular(20)),
      color: getCardColor(isDarkMode),
      lightSource: LightSource.topLeft,
    );
  }

  static NeumorphicStyle getButtonStyle(bool isDarkMode,
      {bool isPressed = false}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      depth: isPressed ? -3 : 3, // تعديل العمق إلى 3 كما طلب المستخدم
      intensity: 1, // تعديل الكثافة إلى 1 كما طلب المستخدم
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      color: getCardColor(isDarkMode),
      lightSource: LightSource.topLeft,
    );
  }

  // أنماط محسنة للجدول الدراسي
  static NeumorphicStyle getTableCellStyle(bool isDarkMode,
      {Color? color, bool isHeader = false}) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      depth: isDarkMode ? -3 : 1, // تعديل العمق إلى 3 كما طلب المستخدم
      intensity: 1, // تعديل الكثافة إلى 1 كما طلب المستخدم
      surfaceIntensity: 0.3,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      color: color != null
          ? color.withOpacity(isDarkMode ? 0.25 : 0.15)
          : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
      lightSource: LightSource.topLeft,
    );
  }

  static NeumorphicStyle getEmptyCellStyle(bool isDarkMode) {
    return NeumorphicStyle(
      shape: NeumorphicShape.flat,
      depth: isDarkMode ? -1 : 1,
      intensity: 0.5,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
      color: isDarkMode ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
      lightSource: LightSource.topLeft,
    );
  }

  // ألوان الفترات الزمنية
  static Color getPeriodColor(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return Colors.blue.withOpacity(0.7);
      case 1:
        return Colors.green.withOpacity(0.7);
      case 2:
        return Colors.orange.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  // ألوان الأيام
  static Color getDayColor(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return Colors.purple.withOpacity(0.7);
      case 1:
        return Colors.indigo.withOpacity(0.7);
      case 2:
        return Colors.blue.withOpacity(0.7);
      case 3:
        return Colors.teal.withOpacity(0.7);
      case 4:
        return Colors.amber.withOpacity(0.7);
      case 5:
        return Colors.deepOrange.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  // أنماط البطاقات المحسنة
  static Widget buildCardHeader(String title, bool isDarkMode,
      {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: getTitleStyle(isDarkMode),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  static Widget buildDivider(bool isDarkMode) {
    return Divider(
      color: getSecondaryTextColor(isDarkMode).withOpacity(0.3),
      thickness: 1,
    );
  }

  static Widget buildEmptyState(String message, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: getSecondaryTextColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: getSubtitleStyle(isDarkMode),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildLoadingState(bool isDarkMode) {
    Rx<double> value = 0.8.obs;
      HomeController homeController = Get.find<HomeController>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicProgress(
            height: 10.0,
            percent: value.value,
            style: ProgressStyle(
              accent: homeController.getPrimaryColor(),
              variant: homeController.getPrimaryColor().withOpacity(0.5),
              depth: 3, // تعديل العمق إلى 3 كما طلب المستخدم
              lightSource: LightSource.topLeft,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الجدول الدراسي...',
            style: getSubtitleStyle(isDarkMode),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildErrorState(
      String message, bool isDarkMode, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: getSubtitleStyle(isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          NeumorphicButton(
            style: getButtonStyle(isDarkMode),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'إعادة المحاولة',
              style: getBodyStyle(isDarkMode),
            ),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  // أزرار التحكم المحسنة
  static Widget buildRefreshButton(bool isDarkMode, VoidCallback onPressed) {
          HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      style: getButtonStyle(isDarkMode),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.refresh,
        color: homeController.getPrimaryColor(),
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  static Widget buildBackButton(bool isDarkMode, VoidCallback onPressed) {
          HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      style: getButtonStyle(isDarkMode),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: homeController.getPrimaryColor(),
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  // مؤشرات الحالة المحسنة
  static Widget buildStatusIndicator(
      String status, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  // واجهة متجاوبة - إضافة دعم للشاشات المختلفة
  static double getResponsiveFontSize(BuildContext context, double size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return size * 0.8; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return size * 0.9; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return size; // للشاشات المتوسطة
    } else {
      return size * 1.1; // للشاشات الكبيرة
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return const EdgeInsets.all(8); // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(12); // للشاشات الصغيرة
    } else {
      return const EdgeInsets.all(16); // للشاشات المتوسطة والكبيرة
    }
  }

  // تحسين عرض الجدول للشاشات المختلفة
  static double getResponsiveCardWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return screenWidth * 0.9; // للشاشات الصغيرة جداً
    } else if (screenWidth < 600) {
      return screenWidth * 0.95; // للشاشات الصغيرة
    } else if (screenWidth < 900) {
      return screenWidth * 0.8; // للشاشات المتوسطة
    } else {
      return screenWidth * 0.7; // للشاشات الكبيرة
    }
  }
}
