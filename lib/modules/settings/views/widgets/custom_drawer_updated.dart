import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  HomeController homeController = Get.find<HomeController>();

  bool isSettingsExpanded = false;
  bool isHelpExpanded = false;
  bool isInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
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

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Drawer(
            backgroundColor: bgColor,
            child: Column(
              children: [
                _buildDrawerHeader(controller, isDarkMode, textColor),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 10),
                      _buildMainSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 10),
                      _buildSettingsSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 10),
                      _buildHelpSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 20),
                      _buildApiSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                        controller: controller,
                      ),
                      const SizedBox(height: 20),
                      _buildLogoutSection(
                        cardColor: cardColor,
                        textColor: textColor,
                        iconColor: iconColor,
                        isDarkMode: isDarkMode,
                        controller: controller,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(
      HomeController controller, bool isDarkMode, Color textColor) {
    return Container(
      height: 200,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: controller.cachedImage.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.memory(
                          controller.cachedImage.value!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.userData['name'] ?? 'اسم المستخدم',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                controller.userData['email'] ?? 'البريد الإلكتروني',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSection({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    HomeController homecontroller = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: Column(
          children: [
            _buildDrawerItem(
              icon: Icons.home,
              title: 'الصفحة الرئيسية',
              onTap: () {
                Get.back();
                // Get.toNamed('/home');
                homecontroller.changePage(0);
              },
              textColor: textColor,
              iconColor: iconColor,
            ),
            _buildDivider(isDarkMode),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () {
                Get.back();
                Get.toNamed('/profile');
              },
              textColor: textColor,
              iconColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: Column(
          children: [
            _buildExpandableHeader(
              icon: Icons.settings,
              title: 'الإعدادات',
              isExpanded: isSettingsExpanded,
              onTap: () {
                setState(() {
                  isSettingsExpanded = !isSettingsExpanded;
                });
              },
              textColor: textColor,
              iconColor: iconColor,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isSettingsExpanded ? null : 0,
              child: isSettingsExpanded
                  ? Column(
                      children: [
                        _buildDivider(isDarkMode),
                        // إعدادات المظهر واللغة - متاحة
                        _buildSubDrawerItem(
                          icon: Icons.palette,
                          title: 'المظهر والثيم',
                          subtitle: 'الألوان والثيمات والخطوط',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/settings/appearance');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.language,
                          title: 'اللغة والمنطقة',
                          subtitle: 'إعدادات اللغة والمنطقة الزمنية',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/settings/language');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        // الإعدادات الأخرى - غير متاحة حالياً
                        _buildDisabledSubDrawerItem(
                          icon: Icons.security,
                          title: 'الحساب والأمان',
                          subtitle: 'إدارة الحساب وكلمات المرور',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDivider(isDarkMode),
                        _buildDisabledSubDrawerItem(
                          icon: Icons.notifications,
                          title: 'الإشعارات',
                          subtitle: 'إدارة التنبيهات والإشعارات',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDivider(isDarkMode),
                        _buildDisabledSubDrawerItem(
                          icon: Icons.privacy_tip,
                          title: 'الخصوصية',
                          subtitle: 'إعدادات الخصوصية والبيانات',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDivider(isDarkMode),
                        _buildDisabledSubDrawerItem(
                          icon: Icons.accessibility,
                          title: 'إمكانية الوصول',
                          subtitle: 'المساعدات البصرية والحركية',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDarkMode: isDarkMode,
                        ),
                        _buildDivider(isDarkMode),
                        _buildDisabledSubDrawerItem(
                          icon: Icons.school,
                          title: 'التعلم والدراسة',
                          subtitle: 'تفضيلات التعلم والأدوات',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: Column(
          children: [
            _buildExpandableHeader(
              icon: Icons.help,
              title: 'المساعدة والدعم',
              isExpanded: isHelpExpanded,
              onTap: () {
                setState(() {
                  isHelpExpanded = !isHelpExpanded;
                });
              },
              textColor: textColor,
              iconColor: iconColor,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isHelpExpanded ? null : 0,
              child: isHelpExpanded
                  ? Column(
                      children: [
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.help_center,
                          title: 'مركز المساعدة',
                          subtitle: 'دليل شامل لاستخدام التطبيق',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/help-support');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.book,
                          title: 'دليل الاستخدام',
                          subtitle: 'تعلم كيفية استخدام التطبيق',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/user-guide');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.quiz,
                          title: 'الأسئلة الشائعة',
                          subtitle: 'إجابات للأسئلة المتكررة',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/faq');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.contact_mail,
                          title: 'معلومات التواصل',
                          subtitle: 'طرق التواصل مع فريق الدعم',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/contact-info');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.feedback,
                          title: 'إرسال شكوى/مقترح',
                          subtitle: 'شاركنا رأيك أو مشكلتك',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/send-complaint-feedback');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: Column(
          children: [
            _buildExpandableHeader(
              icon: Icons.info,
              title: 'معلومات التطبيق',
              isExpanded: isInfoExpanded,
              onTap: () {
                setState(() {
                  isInfoExpanded = !isInfoExpanded;
                });
              },
              textColor: textColor,
              iconColor: iconColor,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isInfoExpanded ? null : 0,
              child: isInfoExpanded
                  ? Column(
                      children: [
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.info_outline,
                          title: 'حول التطبيق',
                          subtitle: 'معلومات عن التطبيق والإصدار',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/about');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.description,
                          title: 'الشروط والأحكام',
                          subtitle: 'شروط استخدام التطبيق',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/terms-conditions');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                        _buildDivider(isDarkMode),
                        _buildSubDrawerItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'سياسة الخصوصية',
                          subtitle: 'كيف نحمي بياناتك الشخصية',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/privacy-policy');
                          },
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          iconColor: iconColor,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection({
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
    required bool isDarkMode,
    required HomeController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: _buildDrawerItem(
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          onTap: () {
            Get.back();
            controller.logout();
          },
          textColor: Colors.red,
          iconColor: Colors.red,
        ),
      ),
    );
  }

  Widget _buildApiSection({
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
    required bool isDarkMode,
    required HomeController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          depth: isDarkMode ? -2 : 3,
          intensity: 0.8,
          color: cardColor,
        ),
        child: _buildDrawerItem(
          icon: Icons.api,
          title: 'أعداد API',
          onTap: () {
            Get.back();
            Get.toNamed('/api-settings');
          },
          textColor: Get.isDarkMode ? Colors.white : AppColors.textPrimary,
          iconColor: controller.getPrimaryColor(),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableHeader({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
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
              Icon(
                Icons.arrow_forward_ios,
                color: textColor.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledSubDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            icon,
            color: textColor.withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.5),
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor.withOpacity(0.5),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'قريباً',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
      indent: 16,
      endIndent: 16,
    );
  }
}
