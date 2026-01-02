import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
          'سياسة الخصوصية',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        //     backgroundColor: bgColor,
        leading: NeumorphicButton(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: const NeumorphicBoxShape.circle(),
            depth: 2,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقدمة
            _buildIntroduction(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // المعلومات التي نجمعها
            _buildDataCollectionSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // كيفية استخدام المعلومات
            _buildDataUsageSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // مشاركة المعلومات
            _buildDataSharingSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // حماية البيانات
            _buildDataProtectionSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // حقوق المستخدم
            _buildUserRightsSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // ملفات تعريف الارتباط
            _buildCookiesSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // الخدمات الخارجية
            _buildThirdPartySection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // الاحتفاظ بالبيانات
            _buildDataRetentionSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // حقوق الأطفال
            _buildChildrenPrivacySection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // التغييرات على السياسة
            _buildPolicyChangesSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // التواصل
            _buildContactSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(Color cardColor, Color textColor,
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
                  Icons.privacy_tip,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'مقدمة',
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
              'نحن في فريق تطوير تطبيق الخدمات الطلابية نقدر خصوصيتكم ونلتزم بحماية معلوماتكم الشخصية. هذه السياسة توضح كيفية جمع واستخدام وحماية البيانات التي تقدمونها عند استخدام تطبيقنا.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                'التطبيق مطور كمشروع أكاديمي تحت إشراف جامعة ذمار، ونحن ملتزمون بأعلى معايير الخصوصية والأمان.',
                style: TextStyle(
                  fontSize: 13,
                  color: accentColor,
                  fontFamily: 'Tajawal',
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCollectionSection(Color cardColor, Color textColor,
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
                  Icons.data_usage,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '1. المعلومات التي نجمعها',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'المعلومات الشخصية:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
                'الاسم الكامل والرقم الجامعي', secondaryTextColor),
            _buildBulletPoint(
                'عنوان البريد الإلكتروني الجامعي', secondaryTextColor),
            _buildBulletPoint('رقم الهاتف (اختياري)', secondaryTextColor),
            _buildBulletPoint('الصورة الشخصية (اختياري)', secondaryTextColor),
            _buildBulletPoint(
                'معلومات الكلية والقسم والمستوى الدراسي', secondaryTextColor),
            const SizedBox(height: 15),
            Text(
              'المعلومات الأكاديمية:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
                'الجداول الدراسية والمقررات المسجلة', secondaryTextColor),
            _buildBulletPoint('الدرجات والتقديرات', secondaryTextColor),
            _buildBulletPoint('سجل الحضور والغياب', secondaryTextColor),
            _buildBulletPoint('الواجبات والمشاريع المرسلة', secondaryTextColor),
            const SizedBox(height: 15),
            Text(
              'معلومات الاستخدام:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('أوقات تسجيل الدخول والخروج', secondaryTextColor),
            _buildBulletPoint('الصفحات والميزات المستخدمة', secondaryTextColor),
            _buildBulletPoint(
                'معلومات الجهاز ونظام التشغيل', secondaryTextColor),
            _buildBulletPoint(
                'عنوان IP (لأغراض الأمان فقط)', secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUsageSection(Color cardColor, Color textColor,
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
                  Icons.settings_applications,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '2. كيفية استخدام المعلومات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'نستخدم المعلومات التي نجمعها للأغراض التالية:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint('توفير وتشغيل خدمات التطبيق', secondaryTextColor),
            _buildBulletPoint(
                'عرض المعلومات الأكاديمية الشخصية', secondaryTextColor),
            _buildBulletPoint(
                'إرسال الإشعارات والتنبيهات المهمة', secondaryTextColor),
            _buildBulletPoint(
                'تحسين أداء التطبيق وتجربة المستخدم', secondaryTextColor),
            _buildBulletPoint('ضمان أمان النظام ومنع الاستخدام غير المصرح به',
                secondaryTextColor),
            _buildBulletPoint(
                'تقديم الدعم التقني عند الحاجة', secondaryTextColor),
            _buildBulletPoint(
                'إجراء تحليلات إحصائية لتطوير الخدمات (بيانات مجهولة الهوية)',
                secondaryTextColor),
            _buildBulletPoint(
                'الامتثال للمتطلبات القانونية والأكاديمية', secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSharingSection(Color cardColor, Color textColor,
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
                  Icons.share,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '3. مشاركة المعلومات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'نحن لا نبيع أو نؤجر أو نشارك معلوماتكم الشخصية مع أطراف ثالثة، باستثناء الحالات التالية:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'مع أعضاء هيئة التدريس المعنيين (للمعلومات الأكاديمية ذات الصلة)',
                secondaryTextColor),
            _buildBulletPoint('مع الإدارة الأكاديمية (عند الضرورة الإدارية)',
                secondaryTextColor),
            _buildBulletPoint('عند وجود موافقة صريحة منكم', secondaryTextColor),
            _buildBulletPoint(
                'عند الحاجة للامتثال للقوانين أو الأوامر القضائية',
                secondaryTextColor),
            _buildBulletPoint(
                'لحماية حقوق وأمان المستخدمين الآخرين', secondaryTextColor),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                'جميع المشاركات تتم وفقاً لسياسات الجامعة ولوائح حماية البيانات المعمول بها.',
                style: TextStyle(
                  fontSize: 13,
                  color: accentColor,
                  fontFamily: 'Tajawal',
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataProtectionSection(Color cardColor, Color textColor,
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
                  Icons.security,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '4. حماية البيانات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'نتخذ إجراءات أمنية صارمة لحماية معلوماتكم:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'تشفير البيانات الحساسة باستخدام معايير الأمان المتقدمة',
                secondaryTextColor),
            _buildBulletPoint('استخدام بروتوكولات HTTPS لجميع عمليات النقل',
                secondaryTextColor),
            _buildBulletPoint('تقييد الوصول للبيانات على الموظفين المخولين فقط',
                secondaryTextColor),
            _buildBulletPoint(
                'مراقبة مستمرة للأنشطة المشبوهة', secondaryTextColor),
            _buildBulletPoint(
                'نسخ احتياطية منتظمة مع تشفير كامل', secondaryTextColor),
            _buildBulletPoint('تحديثات أمنية دورية للنظام', secondaryTextColor),
            _buildBulletPoint(
                'اختبارات اختراق دورية لضمان الأمان', secondaryTextColor),
            const SizedBox(height: 15),
            Text(
              'رغم هذه الإجراءات، لا يمكن ضمان الأمان المطلق لأي نظام إلكتروني. نحن نبذل قصارى جهدنا لحماية بياناتكم ونوصي باتخاذ احتياطات إضافية مثل استخدام كلمات مرور قوية.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRightsSection(Color cardColor, Color textColor,
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
                  Icons.account_circle,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '5. حقوق المستخدم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'لديكم الحقوق التالية فيما يتعلق ببياناتكم الشخصية:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'الحق في الوصول: طلب نسخة من البيانات المحفوظة عنكم',
                secondaryTextColor),
            _buildBulletPoint('الحق في التصحيح: طلب تعديل البيانات غير الصحيحة',
                secondaryTextColor),
            _buildBulletPoint(
                'الحق في الحذف: طلب حذف بياناتكم (مع مراعاة المتطلبات الأكاديمية)',
                secondaryTextColor),
            _buildBulletPoint('الحق في التقييد: طلب تقييد معالجة بياناتكم',
                secondaryTextColor),
            _buildBulletPoint(
                'الحق في النقل: الحصول على بياناتكم بصيغة قابلة للقراءة',
                secondaryTextColor),
            _buildBulletPoint(
                'الحق في الاعتراض: الاعتراض على معالجة بياناتكم لأغراض معينة',
                secondaryTextColor),
            _buildBulletPoint('الحق في سحب الموافقة: سحب موافقتكم في أي وقت',
                secondaryTextColor),
            const SizedBox(height: 15),
            Text(
              'لممارسة أي من هذه الحقوق، يرجى التواصل معنا من خلال القنوات المحددة في نهاية هذه السياسة.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookiesSection(Color cardColor, Color textColor,
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
                  Icons.cookie,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '6. ملفات تعريف الارتباط والتقنيات المشابهة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'نستخدم تقنيات التخزين المحلي لتحسين تجربة الاستخدام:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'حفظ تفضيلات المستخدم (مثل اللغة والثيم)', secondaryTextColor),
            _buildBulletPoint('تذكر حالة تسجيل الدخول', secondaryTextColor),
            _buildBulletPoint('تحسين أداء التطبيق', secondaryTextColor),
            _buildBulletPoint(
                'جمع إحصائيات الاستخدام (مجهولة الهوية)', secondaryTextColor),
            const SizedBox(height: 10),
            Text(
              'يمكنكم إدارة هذه الإعدادات من خلال إعدادات التطبيق أو إعدادات جهازكم.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThirdPartySection(Color cardColor, Color textColor,
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
                  Icons.link,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '7. الخدمات الخارجية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'قد يحتوي التطبيق على روابط لخدمات خارجية أو يستخدم خدمات طرف ثالث:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'خدمات التخزين السحابي (للنسخ الاحتياطية)', secondaryTextColor),
            _buildBulletPoint('خدمات الإشعارات (Firebase Cloud Messaging)',
                secondaryTextColor),
            _buildBulletPoint(
                'خدمات التحليلات (مجهولة الهوية)', secondaryTextColor),
            _buildBulletPoint(
                'روابط لمواقع الجامعة الرسمية', secondaryTextColor),
            const SizedBox(height: 10),
            Text(
              'هذه الخدمات لها سياسات خصوصية منفصلة، ونحن لسنا مسؤولين عن ممارساتها. ننصح بمراجعة سياسات الخصوصية الخاصة بها.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRetentionSection(Color cardColor, Color textColor,
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
                  Icons.schedule,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '8. الاحتفاظ بالبيانات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'نحتفظ ببياناتكم للفترات التالية:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'البيانات الأكاديمية: طوال فترة الدراسة + 5 سنوات (وفقاً للوائح الجامعة)',
                secondaryTextColor),
            _buildBulletPoint('بيانات تسجيل الدخول: 2 سنة من آخر استخدام',
                secondaryTextColor),
            _buildBulletPoint(
                'الرسائل والمحادثات: سنة واحدة', secondaryTextColor),
            _buildBulletPoint(
                'سجلات النظام: 6 أشهر (لأغراض الأمان)', secondaryTextColor),
            const SizedBox(height: 10),
            Text(
              'بعد انتهاء هذه الفترات، يتم حذف البيانات بشكل آمن ونهائي، ما لم تكن هناك التزامات قانونية تتطلب الاحتفاظ بها لفترة أطول.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenPrivacySection(Color cardColor, Color textColor,
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
                  Icons.child_care,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '9. خصوصية القُصَّر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'التطبيق مخصص للطلاب الجامعيين والموظفين البالغين. إذا كان المستخدم تحت سن 18 عاماً، يجب الحصول على موافقة ولي الأمر قبل استخدام التطبيق.',
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
              'إذا علمنا أننا جمعنا معلومات شخصية من قاصر دون موافقة مناسبة، سنتخذ خطوات لحذف هذه المعلومات في أسرع وقت ممكن.',
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

  Widget _buildPolicyChangesSection(Color cardColor, Color textColor,
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
                  Icons.update,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '10. التغييرات على سياسة الخصوصية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإشعاركم بأي تغييرات جوهرية من خلال:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint('إشعار داخل التطبيق', secondaryTextColor),
            _buildBulletPoint('رسالة بريد إلكتروني', secondaryTextColor),
            _buildBulletPoint('إعلان على موقع الجامعة', secondaryTextColor),
            const SizedBox(height: 10),
            Text(
              'ننصح بمراجعة هذه السياسة بشكل دوري للبقاء على اطلاع بكيفية حماية معلوماتكم.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(Color cardColor, Color textColor,
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
                  Icons.contact_support,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '11. التواصل معنا',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'إذا كان لديكم أي أسئلة أو استفسارات حول سياسة الخصوصية هذه أو ممارسات حماية البيانات، يرجى التواصل معنا:',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 15),
            _buildContactInfo(
                'الجهة:',
                'جامعة ذمار - كلية الحاسبات والمعلوماتية',
                textColor,
                secondaryTextColor),
            _buildContactInfo('القسم:', 'قسم تكنولوجيا المعلومات', textColor,
                secondaryTextColor),
            _buildContactInfo('المشرف:', 'د. العباس منذر الألوسي', textColor,
                secondaryTextColor),
            _buildContactInfo('فريق التطوير:', 'طلاب مشروع التخرج', textColor,
                secondaryTextColor),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'تاريخ آخر تحديث: 2024',
                    style: TextStyle(
                      fontSize: 13,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'نحن ملتزمون بحماية خصوصيتكم وضمان أمان بياناتكم',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                height: 1.5,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
      String label, String value, Color textColor, Color? secondaryTextColor) {
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
