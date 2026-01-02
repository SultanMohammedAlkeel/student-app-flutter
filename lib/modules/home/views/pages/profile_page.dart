import 'dart:typed_data';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/profile_controller.dart';

import '../../../../core/themes/app_theme.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        final isDarkMode = Get.isDarkMode;
        final bgColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
        final cardColor =
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
        final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
        final secondaryTextColor =
            isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;
        final iconColor = controller.getPrimaryColor();
        final highlightColor = controller.getSecondaryColor().withOpacity(0.1);

        return Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              color: bgColor,
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(controller, isDarkMode, textColor),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            _buildStudentInfoCard(
                              controller,
                              isDarkMode,
                              cardColor,
                              textColor,
                              secondaryTextColor,
                              iconColor,
                              highlightColor,
                            ),
                            const SizedBox(height: 20),
                            _buildContactInfoCard(
                              controller,
                              isDarkMode,
                              cardColor,
                              textColor,
                              secondaryTextColor,
                              iconColor,
                              highlightColor,
                            ),
                            const SizedBox(height: 20),
                            _buildAccountSettingsCard(
                              controller,
                              isDarkMode,
                              cardColor,
                              textColor,
                              secondaryTextColor,
                              iconColor,
                              highlightColor,
                            ),
                            const SizedBox(height: 20),
                            _buildFooter(
                                isDarkMode, textColor, secondaryTextColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
      ProfileController controller, bool isDarkMode, Color textColor) {
    return SliverAppBar(
      expandedHeight: 250.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                controller.getSecondaryColor(),
                controller.getPrimaryColor()
              ],
            ),
          ),
          child: Center(
            child: _buildProfileHeader(controller, textColor),
          ),
        ),
      ),
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: controller.refreshData,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ProfileController controller, Color textColor) {
    return Obx(() => Hero(
          tag: 'profileImage',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: controller.showFullScreenImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: controller.cachedImage.value != null
                            ? Image.memory(
                                controller.cachedImage.value!,
                                fit: BoxFit.cover,
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.changeProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: controller.getPrimaryColor(),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: controller.isImageUploading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                controller.userData['name'] ?? 'اسم المستخدم',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                controller.userData['email'] ?? 'البريد الإلكتروني',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.account_circle,
        size: 120,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildStudentInfoCard(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color highlightColor,
  ) {
    return Obx(() => Neumorphic(
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
                    Icon(Icons.school, color: iconColor, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'معلومات الطالب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.studentData.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'الاسم الكامل',
                    value: controller.studentData['name'] ?? 'غير معروف',
                    highlightColor: highlightColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.merge_type,
                    label: 'القسم والمستوى',
                    value:
                        '${controller.studentData['department'] ?? 'غير محدد'} - ${controller.studentData['level'] ?? 'غير محدد'}\n',
                    highlightColor: highlightColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'سنة التسجيل',
                    value:
                        controller.studentData['enrollment_year']?.toString() ??
                            'غير معروف',
                    highlightColor: highlightColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.stairs_rounded,
                    label: 'الدرجة العلمية',
                    value:
                        controller.studentData['qualification'] ?? 'غير معروف',
                    highlightColor: highlightColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.perm_identity_rounded,
                    label: 'الرقم الجامعي',
                    value: controller.studentData['card'] ?? 'غير معروف',
                    highlightColor: highlightColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildContactInfoCard(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color highlightColor,
  ) {
    return Obx(() => Stack(
          children: [
            Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
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
                        Icon(Icons.contact_mail, color: iconColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'معلومات التواصل',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'البريد الإلكتروني',
                      value: controller.userData['email'] ?? 'غير متوفر',
                      highlightColor: highlightColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'رقم الهاتف',
                      value: controller.userData['phone_number']?.toString() ??
                          'غير متوفر',
                      highlightColor: highlightColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'العنوان',
                      value: controller.userData['address'] ?? 'غير محدد',
                      highlightColor: highlightColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: NeumorphicButton(
                onPressed: () => _showEditContactDialog(controller, isDarkMode,
                    cardColor, textColor, secondaryTextColor, iconColor),
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: const NeumorphicBoxShape.circle(),
                  depth: 2,
                  intensity: 0.8,
                  color: cardColor,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.edit, color: iconColor, size: 18),
              ),
            ),
          ],
        ));
  }

  Widget _buildAccountSettingsCard(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
    Color highlightColor,
  ) {
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
                Icon(Icons.settings, color: iconColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'إعدادات الحساب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              icon: Icons.person,
              title: 'تعديل البيانات الأساسية',
              subtitle: 'تحديث الاسم والبريد الإلكتروني',
              onTap: () => _showEditBasicInfoDialog(controller, isDarkMode,
                  cardColor, textColor, secondaryTextColor, iconColor),
              iconColor: iconColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
            const SizedBox(height: 15),
            _buildSettingItem(
              icon: Icons.lock,
              title: 'تغيير كلمة المرور',
              subtitle: 'تحديث كلمة المرور الخاصة بك',
              onTap: () => _showChangePasswordDialog(controller, isDarkMode,
                  cardColor, textColor, secondaryTextColor, iconColor),
              iconColor: iconColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: isDarkMode ? -2 : 4,
        intensity: 0.8,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          children: [
            // Replace with your app logo
            Image.asset(
              'assets/images/app_logo.png', // تأكد من وجود هذا المسار في مشروعك
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 15),
            Text(
              'تطبيق الخدمات الطلابية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'نسخة 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'تم التطوير بواسطة: Yotta Soft Team',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '© 2025 جميع الحقوق محفوظة',
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor.withOpacity(0.7),
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color highlightColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    ProfileController proController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: proController.getPrimaryColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
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
    );
  }

  // Dialog functions
  void _showEditBasicInfoDialog(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    Get.dialog(
      NeumorphicAlertDialog(
        title:
            Text('تعديل البيانات الأساسية', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNeumorphicTextField(
                controller: controller.nameController,
                labelText: 'الاسم',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.emailController,
                labelText: 'البريد الإلكتروني',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.phoneController,
                labelText: 'رقم الهاتف',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Get.back(),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: cardColor,
            ),
            child: Text('إلغاء', style: TextStyle(color: textColor)),
          ),
          NeumorphicButton(
            onPressed: () {
              Get.back();
              controller.updateBasicInfo();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: controller.getPrimaryColor(),
            ),
            child: Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    Get.dialog(
      NeumorphicAlertDialog(
        title:
            Text('تعديل معلومات التواصل', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNeumorphicTextField(
                controller: controller.emailController,
                labelText: 'البريد الإلكتروني',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.phoneController,
                labelText: 'رقم الهاتف',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.addressController,
                labelText: 'العنوان',
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Get.back(),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: cardColor,
            ),
            child: Text('إلغاء', style: TextStyle(color: textColor)),
          ),
          NeumorphicButton(
            onPressed: () {
              Get.back();
              controller.updateContactInfo();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: controller.getPrimaryColor(),
            ),
            child: Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
    ProfileController controller,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color iconColor,
  ) {
    Get.dialog(
      NeumorphicAlertDialog(
        title: Text('تغيير كلمة المرور', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNeumorphicTextField(
                controller: controller.currentPasswordController,
                labelText: 'كلمة المرور الحالية',
                obscureText: true,
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.newPasswordController,
                labelText: 'كلمة المرور الجديدة',
                obscureText: true,
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(
                controller: controller.confirmPasswordController,
                labelText: 'تأكيد كلمة المرور الجديدة',
                obscureText: true,
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Get.back(),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: cardColor,
            ),
            child: Text('إلغاء', style: TextStyle(color: textColor)),
          ),
          NeumorphicButton(
            onPressed: () {
              Get.back();
              controller.changePassword();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: controller.getPrimaryColor(),
            ),
            child: Text('تغيير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: -2,
        intensity: 0.8,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: textColor, fontFamily: 'Tajawal'),
        decoration: InputDecoration(
          fillColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          labelText: labelText,
          labelStyle:
              TextStyle(color: secondaryTextColor, fontFamily: 'Tajawal'),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  void _showLogoutDialog(ProfileController controller) {
    Get.dialog(
      NeumorphicAlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          NeumorphicButton(
            onPressed: () => Get.back(),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: Get.theme.cardColor,
            ),
            child: Text('إلغاء',
                style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color)),
          ),
          NeumorphicButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
              depth: 2,
              intensity: 0.8,
              color: Colors.red,
            ),
            child: const Text('تسجيل الخروج',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Custom NeumorphicAlertDialog to apply Neumorphic style to the dialog itself
class NeumorphicAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  const NeumorphicAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final bgColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          depth: 4,
          intensity: 0.8,
          color: bgColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Tajawal',
                  ),
                  child: title!,
                ),
                const SizedBox(height: 15),
              ],
              if (content != null) ...[
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDarkMode ? Colors.grey[300] : AppColors.textSecondary,
                    fontFamily: 'Tajawal',
                  ),
                  child: content!,
                ),
                const SizedBox(height: 20),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
