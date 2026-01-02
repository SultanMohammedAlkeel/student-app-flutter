import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/services_dashboard_controller.dart';
import '../widgets/notification_card.dart';
import '../widgets/service_card.dart';
import 'student_schedule_service/next_day_lectures_card.dart';
import 'student_schedule_service/schedule_controller.dart';

class ServicesDashboardView extends GetView<ServicesDashboardController> {
  const ServicesDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    // تهيئة بيانات اللغة العربية
    Intl.defaultLocale = 'ar';

    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final cardColor =
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
      final textColor = isDarkMode ? Colors.white : const Color(0xFF333333);
      final secondaryTextColor =
          isDarkMode ? Colors.grey[400]! : const Color(0xFF666666);
      final primaryColor = homeController.getPrimaryColor();

      return Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            SafeArea(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: controller.refreshData,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // رأس الصفحة المعدل
                    _buildAppBar(context, isDarkMode, textColor, primaryColor,
                        cardColor),

                    // معلومات الطالب المعدلة
                    _buildStudentInfo(context, isDarkMode, textColor,
                        secondaryTextColor, primaryColor, cardColor),

                    // قسم التنويهات المعدل
                    _buildNotificationsSection(context, isDarkMode, textColor,
                        secondaryTextColor, primaryColor, cardColor),

                    // قسم محاضرات الغد المعدل
                    _buildTomorrowLecturesSection(context, isDarkMode,
                        textColor, secondaryTextColor, primaryColor, cardColor),

                    // الخدمات الرئيسية المعدلة
                    _buildPrimaryServicesSection(context, isDarkMode, textColor,
                        secondaryTextColor, primaryColor, cardColor),

                    // الخدمات الثانوية المعدلة
                    _buildSecondaryServicesSection(context, isDarkMode,
                        textColor, secondaryTextColor, primaryColor, cardColor),

                    // مساحة إضافية في الأسفل
                    SliverToBoxAdapter(
                      child: SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, bool isDarkMode, Color textColor,
      Color primaryColor, Color cardColor) {
    HomeController homeController = Get.find<HomeController>();

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              homeController.getSecondaryColor(),
              homeController.getPrimaryColor(),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: NeumorphicText(
            'الخدمات الجامعية',
            textStyle: NeumorphicTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            style: NeumorphicStyle(
                color: AppColors.lightSurface, depth: 1, intensity: 0.8),
          ),
          centerTitle: true,
        ),
      ),
      // // actions: [
      // //   Padding(
      // //     padding: const EdgeInsets.symmetric(horizontal: 16),
      // //     child: NeumorphicButton(
      // //       style: NeumorphicStyle(
      // //         shape: NeumorphicShape.flat,
      // //         boxShape: NeumorphicBoxShape.circle(),
      // //         depth:
      // //             isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
      // //         intensity: AppConstants.darkDepth,
      // //         color: cardColor,
      // //       ),
      // //       padding: const EdgeInsets.all(12),
      // //       child: Icon(
      // //         isDarkMode ? Icons.light_mode : Icons.dark_mode,
      // //         color: isDarkMode ? Colors.amber : primaryColor,
      // //         size: 18,
      // //       ),
      // //       onPressed: () {}, //controller.toggleDarkMode,
      // //     ),
      // //   ),
      // // ],
      // leading: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16),
      //   child: NeumorphicButton(
      //     style: NeumorphicStyle(
      //       shape: NeumorphicShape.flat,
      //       boxShape: NeumorphicBoxShape.circle(),
      //       depth:
      //           isDarkMode ? AppConstants.darkDepth : AppConstants.lightDepth,
      //       intensity: AppConstants.darkDepth,
      //       color: cardColor,
      //     ),
      //     padding: const EdgeInsets.all(12),
      //     child: Icon(
      //       Icons.arrow_back_ios_new,
      //       color: primaryColor,
      //       size: 18,
      //     ),
      //     onPressed: () => Get.back(),
      //   ),
      // ),
    );
  }

  Widget _buildStudentInfo(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    HomeController homeController = Get.find<HomeController>();
    final imageBytes = homeController.cachedImage.value;
    final storage = Get.find<StorageService>();

    final student = storage.read<Map<String, dynamic>>('student_data');

    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: isDarkMode
                        ? AppConstants.darkDepth
                        : AppConstants.lightDepth,
                    intensity: AppConstants.darkDepth,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: cardColor,
                    ),
                    child: Row(
                      children: [
                        // صورة الطالب
                        Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: isDarkMode
                                ? AppConstants.darkDepth
                                : AppConstants.lightDepth,
                            intensity: AppConstants.darkDepth,
                            color: cardColor,
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: imageBytes != null
                                  ? Image.memory(
                                      imageBytes,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/user_profile.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // معلومات الطالب
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${student?['name'] ?? 'غير معروف'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الرقم الجامعي: ${student?['card'] ?? 'غير معروف'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'القسم: ${student?['department'] ?? 'غير معروف'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // مؤشر الحضور
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getAttendanceColor(
                                        controller.student.value.attendanceRate)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.student.value.attendanceRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getAttendanceColor(
                                      controller.student.value.attendanceRate),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الحضور',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationsSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.notifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 700),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: isDarkMode
                        ? AppConstants.darkDepth
                        : AppConstants.lightDepth,
                    intensity: AppConstants.darkDepth,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                    color: cardColor,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notifications,
                                    color: primaryColor, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'التنويهات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // التوجه إلى صفحة جميع التنويهات
                              },
                              child: Text(
                                'عرض الكل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimationLimiter(
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: controller.notifications.length > 3
                                ? 3
                                : controller.notifications.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final notification =
                                  controller.notifications[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  horizontalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: NotificationCard(
                                      notification: notification,
                                      isDarkMode: isDarkMode,
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      primaryColor: primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTomorrowLecturesSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return SliverToBoxAdapter(
      child: GetBuilder<ScheduleController>(builder: (controller) {
        if (controller.getTomorrowLectures().isEmpty) {
          return const SizedBox.shrink();
        }
        return AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: isDarkMode
                        ? AppConstants.darkDepth
                        : AppConstants.lightDepth,
                    intensity: AppConstants.darkDepth,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    color: primaryColor, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  ' الغد',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                controller.navigateToSchedule();
                              },
                              child: Text(
                                'الجدول الكامل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryColor,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // هنا بدل SizedBox بعلو ثابت خليها فقط عادية
                        AnimationLimiter(
                          child: NextDayLecturesCard(controller: controller),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryServicesSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return SliverToBoxAdapter(
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 900),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  depth: isDarkMode
                      ? AppConstants.darkDepth
                      : AppConstants.lightDepth,
                  intensity: AppConstants.darkDepth,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.apps, color: primaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'الخدمات الرئيسية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimationLimiter(
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.primaryServices.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final service = controller.primaryServices[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: ServiceCard(
                                    service: service,
                                    isDarkMode: isDarkMode,
                                    onTap: () =>
                                        controller.navigateToService(service),
                                    isPriority: true,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryServicesSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      Color cardColor) {
    return SliverToBoxAdapter(
      child: AnimationConfiguration.synchronized(
        duration: const Duration(milliseconds: 1000),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  depth: isDarkMode
                      ? AppConstants.darkDepth
                      : AppConstants.lightDepth,
                  intensity: AppConstants.darkDepth,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.more_horiz, color: primaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'خدمات أخرى',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: controller.secondaryServices.length,
                        itemBuilder: (context, index) {
                          final service = controller.secondaryServices[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: ServiceCard(
                                  service: service,
                                  isDarkMode: isDarkMode,
                                  onTap: () =>
                                      controller.navigateToService(service),
                                  isPriority: false,
                                  textColor: textColor,
                                  secondaryTextColor: secondaryTextColor,
                                  // cardColor: cardColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) {
      return Colors.green;
    } else if (rate >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
