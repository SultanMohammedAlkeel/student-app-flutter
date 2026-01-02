import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

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
          'شروط الاستخدام',
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

            // قبول الشروط
            _buildAcceptanceSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // استخدام التطبيق
            _buildUsageSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // حقوق المستخدم وواجباته
            _buildUserRightsSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // الخصوصية وحماية البيانات
            _buildPrivacySection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // المحتوى والملكية الفكرية
            _buildContentSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // المسؤولية والضمانات
            _buildLiabilitySection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // التعديلات والتحديثات
            _buildModificationsSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // إنهاء الخدمة
            _buildTerminationSection(
                cardColor, textColor, secondaryTextColor, accentColor),
            const SizedBox(height: 20),

            // القانون المطبق
            _buildLegalSection(
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
                  Icons.description,
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
              'مرحباً بكم في تطبيق الخدمات الطلابية المطور من قبل طلاب قسم تكنولوجيا المعلومات بكلية الحاسبات والمعلوماتية في جامعة ذمار. هذه الشروط والأحكام تحكم استخدامكم لهذا التطبيق وجميع الخدمات المقدمة من خلاله.',
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
                'يرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق. استخدامكم للتطبيق يعني موافقتكم على جميع الشروط والأحكام المذكورة أدناه.',
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

  Widget _buildAcceptanceSection(Color cardColor, Color textColor,
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
                  Icons.check_circle_outline,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '1. قبول الشروط',
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
              'بتحميل التطبيق أو استخدامه أو الوصول إليه، فإنكم توافقون على الالتزام بهذه الشروط والأحكام. إذا كنتم لا توافقون على أي من هذه الشروط، يرجى عدم استخدام التطبيق.',
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
              'هذا التطبيق مخصص للاستخدام الأكاديمي والتعليمي فقط، وهو جزء من مشروع تخرج أكاديمي تحت إشراف جامعة ذمار.',
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

  Widget _buildUsageSection(Color cardColor, Color textColor,
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
                  Icons.phone_android,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '2. استخدام التطبيق',
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
            _buildBulletPoint(
                'يحق لكم استخدام التطبيق للأغراض التعليمية والأكاديمية المشروعة فقط.',
                secondaryTextColor),
            _buildBulletPoint(
                'يجب أن تكونوا طلاباً أو أعضاء هيئة تدريس أو موظفين في الجامعة للاستفادة من الخدمات.',
                secondaryTextColor),
            _buildBulletPoint(
                'يُمنع استخدام التطبيق لأي أغراض تجارية أو غير قانونية.',
                secondaryTextColor),
            _buildBulletPoint(
                'يجب الحفاظ على سرية بيانات تسجيل الدخول الخاصة بكم.',
                secondaryTextColor),
            _buildBulletPoint(
                'يُمنع مشاركة حسابكم مع أشخاص آخرين أو السماح لهم بالوصول إليه.',
                secondaryTextColor),
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
                  Icons.account_balance,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '3. حقوق المستخدم وواجباته',
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
              'حقوقكم:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('الوصول إلى جميع الخدمات المتاحة في التطبيق.',
                secondaryTextColor),
            _buildBulletPoint(
                'الحصول على الدعم التقني عند الحاجة.', secondaryTextColor),
            _buildBulletPoint('حماية بياناتكم الشخصية وفقاً لسياسة الخصوصية.',
                secondaryTextColor),
            const SizedBox(height: 15),
            Text(
              'واجباتكم:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
                'استخدام التطبيق بطريقة مسؤولة ومناسبة.', secondaryTextColor),
            _buildBulletPoint(
                'عدم محاولة اختراق النظام أو الوصول غير المصرح به.',
                secondaryTextColor),
            _buildBulletPoint(
                'الإبلاغ عن أي مشاكل تقنية أو أمنية فور اكتشافها.',
                secondaryTextColor),
            _buildBulletPoint(
                'احترام حقوق المستخدمين الآخرين.', secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(Color cardColor, Color textColor,
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
                  '4. الخصوصية وحماية البيانات',
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
              'نحن ملتزمون بحماية خصوصيتكم وبياناتكم الشخصية. جميع المعلومات التي تقدمونها تُستخدم فقط لأغراض تشغيل التطبيق وتحسين الخدمات المقدمة.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            _buildBulletPoint('لا نشارك بياناتكم مع أطراف ثالثة دون موافقتكم.',
                secondaryTextColor),
            _buildBulletPoint('نستخدم تقنيات التشفير لحماية البيانات الحساسة.',
                secondaryTextColor),
            _buildBulletPoint(
                'يمكنكم طلب حذف بياناتكم في أي وقت.', secondaryTextColor),
            _buildBulletPoint('للمزيد من التفاصيل، يرجى مراجعة سياسة الخصوصية.',
                secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(Color cardColor, Color textColor,
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
                  Icons.copyright,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '5. المحتوى والملكية الفكرية',
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
              'جميع حقوق الملكية الفكرية للتطبيق محفوظة لجامعة ذمار وفريق التطوير. هذا يشمل التصميم، الكود، والمحتوى.',
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
                'يُمنع نسخ أو توزيع أو تعديل التطبيق دون إذن مسبق.',
                secondaryTextColor),
            _buildBulletPoint('المحتوى المقدم من المستخدمين يبقى ملكاً لهم.',
                secondaryTextColor),
            _buildBulletPoint(
                'نحتفظ بالحق في إزالة أي محتوى غير مناسب.', secondaryTextColor),
            _buildBulletPoint(
                'يُمنع استخدام التطبيق لنشر محتوى مخالف للقوانين أو الآداب العامة.',
                secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLiabilitySection(Color cardColor, Color textColor,
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
                  Icons.warning_amber,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '6. المسؤولية والضمانات',
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
              'التطبيق مقدم "كما هو" دون أي ضمانات صريحة أو ضمنية. نحن نبذل قصارى جهدنا لضمان دقة المعلومات وموثوقية الخدمة، لكننا لا نضمن عدم وجود أخطاء أو انقطاع في الخدمة.',
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
                'لا نتحمل المسؤولية عن أي أضرار مباشرة أو غير مباشرة.',
                secondaryTextColor),
            _buildBulletPoint(
                'المستخدم مسؤول عن استخدام التطبيق على مسؤوليته الخاصة.',
                secondaryTextColor),
            _buildBulletPoint('نحتفظ بالحق في تعديل أو إيقاف الخدمة في أي وقت.',
                secondaryTextColor),
            _buildBulletPoint('يُنصح بعمل نسخ احتياطية من البيانات المهمة.',
                secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildModificationsSection(Color cardColor, Color textColor,
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
                  '7. التعديلات والتحديثات',
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
              'نحتفظ بالحق في تعديل هذه الشروط والأحكام في أي وقت. سيتم إشعاركم بأي تغييرات جوهرية من خلال التطبيق أو وسائل التواصل المناسبة.',
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
                'التحديثات قد تتضمن ميزات جديدة أو تحسينات أمنية.',
                secondaryTextColor),
            _buildBulletPoint(
                'استمرار استخدام التطبيق يعني موافقتكم على الشروط المحدثة.',
                secondaryTextColor),
            _buildBulletPoint(
                'يُنصح بمراجعة الشروط بشكل دوري.', secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminationSection(Color cardColor, Color textColor,
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
                  Icons.exit_to_app,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '8. إنهاء الخدمة',
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
              'يمكنكم إنهاء استخدام التطبيق في أي وقت بحذفه من جهازكم. كما نحتفظ بالحق في إنهاء وصولكم للتطبيق في حالة انتهاك هذه الشروط.',
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
                'عند إنهاء الخدمة، قد يتم حذف بياناتكم من الخوادم.',
                secondaryTextColor),
            _buildBulletPoint(
                'الأقسام المتعلقة بالمسؤولية والملكية الفكرية تبقى سارية.',
                secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection(Color cardColor, Color textColor,
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
                  Icons.gavel,
                  color: accentColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  '9. القانون المطبق',
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
              'تخضع هذه الشروط والأحكام لقوانين الجمهورية اليمنية ولوائح جامعة ذمار. أي نزاع ينشأ عن استخدام التطبيق يُحل وفقاً للقوانين المعمول بها في اليمن.',
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
                  '10. التواصل والاستفسارات',
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
              'إذا كان لديكم أي استفسارات حول هذه الشروط والأحكام أو حول التطبيق بشكل عام، يرجى التواصل معنا من خلال:',
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
                'جامعة ذمار - كلية الحاسبات والمعلوماتية', secondaryTextColor),
            _buildBulletPoint('قسم تكنولوجيا المعلومات', secondaryTextColor),
            _buildBulletPoint(
                'المشرف: د. العباس منذر الألوسي', secondaryTextColor),
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
                    'شكراً لكم على استخدام تطبيق الخدمات الطلابية',
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
}
