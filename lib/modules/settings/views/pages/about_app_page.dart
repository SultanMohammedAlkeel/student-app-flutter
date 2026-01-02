import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final bgColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[600];
    final accentColor =
        isDarkMode ? const Color(0xFF4A90E2) : const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'حول التطبيق',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        //  backgroundColor: bgColor,
        leading: NeumorphicButton(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: const NeumorphicBoxShape.circle(),
            depth: 2,
            intensity: 0.5,
            color: bgColor,
          ),
          onPressed: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: textColor,
            size: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // شعار التطبيق
            _buildAppLogo(bgColor, cardColor),
            const SizedBox(height: 30),

            // معلومات التطبيق الأساسية
            _buildAppInfo(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 25),

            // وصف التطبيق
            _buildAppDescription(cardColor, textColor, secondaryTextColor),
            const SizedBox(height: 25),

            // الميزات الرئيسية
            _buildMainFeatures(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 25),

            // فريق التطوير
            _buildDevelopmentTeam(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 25),

            // معلومات الجامعة والإشراف
            _buildUniversityInfo(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 25),

            // التقنيات المستخدمة
            _buildTechnologies(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 25),

            // معلومات الإصدار والتواصل
            _buildVersionAndContact(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo(Color bgColor, Color cardColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: 2,
        color: cardColor,
      ),
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(20),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAppInfo(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'تطبيق الخدمات الطلابية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Student Services App',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDescription(
      Color cardColor, Color textColor, Color? secondaryTextColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'نبذة عن التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'تطبيق الخدمات الطلابية هو نظام متكامل مصمم خصيصاً لتسهيل الحياة الأكاديمية للطلاب وأعضاء هيئة التدريس. يوفر التطبيق منصة موحدة للوصول إلى جميع الخدمات الجامعية الأساسية بسهولة وكفاءة عالية.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            Text(
              'يهدف التطبيق إلى حل التحديات التي تواجه المجتمع الجامعي في الوصول إلى المعلومات والخدمات، مع التركيز على توفير تجربة مستخدم متميزة وواجهة عصرية تتماشى مع التطورات التقنية الحديثة.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFeatures(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    final features = [
      {
        'icon': Icons.schedule,
        'title': 'الجداول الدراسية',
        'desc': 'عرض وإدارة الجداول الأكاديمية'
      },
      {
        'icon': Icons.grade,
        'title': 'الدرجات والتقديرات',
        'desc': 'متابعة الأداء الأكاديمي'
      },
      {
        'icon': Icons.library_books,
        'title': 'المكتبة الإلكترونية',
        'desc': 'الوصول للموارد التعليمية'
      },
      {
        'icon': Icons.notifications,
        'title': 'الإشعارات الذكية',
        'desc': 'تنبيهات فورية للأحداث المهمة'
      },
      {
        'icon': Icons.chat,
        'title': 'التواصل المباشر',
        'desc': 'منصة تواصل مع الأساتذة والزملاء'
      },
      {
        'icon': Icons.assignment,
        'title': 'إدارة المهام',
        'desc': 'تنظيم الواجبات والمشاريع'
      },
    ];

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'الميزات الرئيسية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...features
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              feature['icon'] as IconData,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feature['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                Text(
                                  feature['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentTeam(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    final teamMembers = [
      'سلطان محمد صالح عبدالله الخيل',
      'عرفات عارف عبدالله حوشبه',
      'اشرف غانم احمد مثنى',
      'محمد عبد الرحمن حزام العماري',
      'ايمن فؤاد احمد القاسمي',
      'نايف محمد مصلح منيف',
      'عماد الدين رياض صالح مهدي المنصوب',
    ];

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'فريق التطوير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'تم تطوير هذا التطبيق بجهود مشتركة من فريق متميز من طلاب تكنولوجيا المعلومات:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            ...teamMembers.asMap().entries.map((entry) {
              int index = entry.key;
              String member = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityInfo(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'الجهة الأكاديمية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow('الجامعة:', 'جامعة ذمار', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('الكلية:', 'كلية الحاسبات والمعلوماتية', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('القسم:', 'قسم تكنولوجيا المعلومات', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('المشرف:', 'د. العباس منذر الألوسي', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('عميد الكلية:', 'د. بشير المقالح', textColor,
                secondaryTextColor, accentColor),
            const SizedBox(height: 10),
            Text(
              'مشروع تخرج لنيل درجة البكالوريوس في تكنولوجيا المعلومات',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                fontStyle: FontStyle.italic,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologies(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    final technologies = [
      {'name': 'Flutter', 'desc': 'إطار العمل للتطبيق المحمول'},
      {'name': 'Dart', 'desc': 'لغة البرمجة الأساسية'},
      {'name': 'Laravel', 'desc': 'إطار العمل للواجهة الخلفية'},
      {'name': 'MySQL', 'desc': 'قاعدة البيانات'},
      {'name': 'GetX', 'desc': 'إدارة الحالة والتنقل'},
      {'name': 'Neumorphic Design', 'desc': 'نمط التصميم المستخدم'},
    ];

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'التقنيات المستخدمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: technologies
                  .map((tech) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tech['name']!,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            Text(
                              tech['desc']!,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionAndContact(Color cardColor, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
        depth: 2,
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_mail,
                  color: textColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'معلومات الإصدار والتواصل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow('رقم الإصدار:', '1.0.0', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('تاريخ الإصدار:', '2024', textColor,
                secondaryTextColor, accentColor),
            _buildInfoRow('نوع الترخيص:', 'مشروع أكاديمي', textColor,
                secondaryTextColor, accentColor),
            const SizedBox(height: 15),
            Text(
              'للاستفسارات والدعم التقني، يرجى التواصل مع فريق التطوير عبر الجامعة.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                '© 2024 جامعة ذمار - كلية الحاسبات والمعلوماتية',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor,
      Color? secondaryTextColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
