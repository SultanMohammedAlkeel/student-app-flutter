import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import 'package:student_app/modules/settings/controllers/settings_controller.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) {
        final isDarkMode = Get.isDarkMode;
        final bgColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
        final cardColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
        final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
        final secondaryTextColor =
            isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;
        final iconColor = homeController.getPrimaryColor();

        return Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              color: bgColor,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDarkMode, textColor),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildSettingsSection(
                            title: 'الحساب والأمان',
                            icon: Icons.security,
                            items: [
                              _buildSettingItem(
                                icon: Icons.person_outline,
                                title: 'إدارة الحساب',
                                subtitle: 'تعديل البيانات الشخصية والأكاديمية',
                                onTap: () =>
                                    Get.toNamed('/settings/account-security'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.lock_outline,
                                title: 'الأمان وكلمات المرور',
                                subtitle:
                                    'تغيير كلمة المرور والمصادقة الثنائية',
                                onTap: () => Get.toNamed('/settings/security'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.history,
                                title: 'سجل تسجيل الدخول',
                                subtitle: 'عرض الجلسات النشطة ومحاولات الدخول',
                                onTap: () =>
                                    Get.toNamed('/settings/login-history'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'الإشعارات والتنبيهات',
                            icon: Icons.notifications,
                            items: [
                              _buildSettingItem(
                                icon: Icons.school,
                                title: 'الإشعارات الأكاديمية',
                                subtitle: 'الدرجات، المواعيد، التكليفات',
                                onTap: () => Get.toNamed(
                                    '/settings/academic-notifications'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.admin_panel_settings,
                                title: 'الإشعارات الإدارية',
                                subtitle: 'الإعلانات والأخبار المهمة',
                                onTap: () => Get.toNamed(
                                    '/settings/admin-notifications'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.schedule,
                                title: 'التذكيرات',
                                subtitle: 'المواعيد والمهام والأحداث',
                                onTap: () => Get.toNamed('/settings/reminders'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'المظهر واللغة',
                            icon: Icons.palette,
                            items: [
                              _buildSettingItem(
                                icon: Icons.dark_mode,
                                title: 'المظهر',
                                subtitle: 'الوضع الفاتح أو الداكن',
                                onTap: () =>
                                    Get.toNamed('/settings/appearance'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.language,
                                title: 'اللغة والمنطقة',
                                subtitle: 'تغيير لغة التطبيق والمنطقة الزمنية',
                                onTap: () =>
                                    Get.toNamed('/settings/language-region'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.text_fields,
                                title: 'حجم الخط',
                                subtitle: 'تخصيص حجم النصوص',
                                onTap: () => Get.toNamed('/settings/font-size'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'الخصوصية والبيانات',
                            icon: Icons.privacy_tip,
                            items: [
                              _buildSettingItem(
                                icon: Icons.visibility,
                                title: 'إعدادات الخصوصية',
                                subtitle: 'التحكم في مشاركة البيانات والظهور',
                                onTap: () => Get.toNamed('/settings/privacy'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.storage,
                                title: 'التخزين والبيانات',
                                subtitle: 'إدارة المساحة واستهلاك البيانات',
                                onTap: () =>
                                    Get.toNamed('/settings/storage-data'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.backup,
                                title: 'النسخ الاحتياطي',
                                subtitle: 'نسخ احتياطي واستعادة البيانات',
                                onTap: () => Get.toNamed('/settings/backup'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'إمكانية الوصول',
                            icon: Icons.accessibility,
                            items: [
                              _buildSettingItem(
                                icon: Icons.zoom_in,
                                title: 'المساعدات البصرية',
                                subtitle: 'حجم الخط والتباين العالي',
                                onTap: () =>
                                    Get.toNamed('/settings/visual-aids'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.hearing,
                                title: 'المساعدات السمعية',
                                subtitle: 'الترجمة المرئية والتحكم الصوتي',
                                onTap: () =>
                                    Get.toNamed('/settings/audio-aids'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.touch_app,
                                title: 'المساعدات الحركية',
                                subtitle: 'إيماءات مخصصة ووقت الاستجابة',
                                onTap: () =>
                                    Get.toNamed('/settings/motor-aids'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'التعلم والدراسة',
                            icon: Icons.school,
                            items: [
                              _buildSettingItem(
                                icon: Icons.psychology,
                                title: 'تفضيلات التعلم',
                                subtitle: 'أسلوب التعلم وأوقات الدراسة المفضلة',
                                onTap: () => Get.toNamed(
                                    '/settings/learning-preferences'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.timer,
                                title: 'أدوات التعلم',
                                subtitle: 'تذكيرات الدراسة وتتبع التقدم',
                                onTap: () =>
                                    Get.toNamed('/settings/learning-tools'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.emoji_events,
                                title: 'الإنجازات والمكافآت',
                                subtitle: 'نظام النقاط والشارات',
                                onTap: () =>
                                    Get.toNamed('/settings/achievements'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 20),
                          _buildSettingsSection(
                            title: 'الشبكات الاجتماعية',
                            icon: Icons.people,
                            items: [
                              _buildSettingItem(
                                icon: Icons.group,
                                title: 'الأصدقاء والزملاء',
                                subtitle: 'إدارة قائمة الأصدقاء والتفاعل',
                                onTap: () => Get.toNamed('/settings/friends'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.groups,
                                title: 'مجموعات الدراسة',
                                subtitle: 'إنشاء والانضمام للمجموعات',
                                onTap: () =>
                                    Get.toNamed('/settings/study-groups'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                              _buildSettingItem(
                                icon: Icons.share,
                                title: 'مشاركة الإنجازات',
                                subtitle: 'عرض الدرجات والإنجازات للآخرين',
                                onTap: () => Get.toNamed(
                                    '/settings/achievement-sharing'),
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                iconColor: iconColor,
                              ),
                            ],
                            cardColor: cardColor,
                            textColor: textColor,
                            iconColor: iconColor,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDarkMode, Color textColor) {
    HomeController homeController = Get.find<HomeController>();

    return SliverAppBar(
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                homeController.getPrimaryColor().withOpacity(0.8),
                homeController.getSecondaryColor().withOpacity(0.6),
              ],
            ),
          ),
          child: const Center(
            child: Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ),
      ),
      pinned: true,
      backgroundColor: homeController.getPrimaryColor(),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: isDarkMode ? -2 : 4,
        intensity: 0.8,
        color: cardColor,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
