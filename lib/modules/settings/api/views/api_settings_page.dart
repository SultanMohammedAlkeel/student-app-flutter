import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/settings/api/controllers/api_settings_controller.dart';

class ApiSettingsPage extends StatelessWidget {
  const ApiSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApiSettingsController());

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: const Text(
          'إعدادات الـ API',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: NeumorphicButton(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          onPressed: () => Get.back(),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildCurrentUrlCard(controller),
            const SizedBox(height: 20),
            _buildUrlInputCard(controller),
            const SizedBox(height: 20),
            _buildActionButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        surfaceIntensity: 0.15,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'معلومات مهمة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'يمكنك تغيير عنوان الخادم (API) المستخدم في التطبيق. هذا مفيد أثناء التطوير عندما يتغير عنوان الخادم باستمرار.',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '⚠️ تأكد من صحة العنوان قبل الحفظ لتجنب مشاكل الاتصال.',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUrlCard(ApiSettingsController controller) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        surfaceIntensity: 0.15,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.link,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'العنوان الحالي',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: controller.isDefaultUrl
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentUrl.value,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        controller.isDefaultUrl
                            ? 'العنوان الافتراضي'
                            : 'عنوان مخصص',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: controller.isDefaultUrl
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInputCard(ApiSettingsController controller) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        surfaceIntensity: 0.15,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: -4,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'تغيير العنوان',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'لا داعي لحذف العنوان بالكامل فقط قم بتغيير الجزء الذي تريد تعديله. وبعد ذلك اضغط على زر "حفظ العنوان الجديد".',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Neumorphic(
              style: NeumorphicStyle(
                depth: -8,
                intensity: 0.65,
                surfaceIntensity: 0.15,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              ),
              child: TextField(
                controller: controller.urlController,
                onChanged: controller.onUrlChanged,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل عنوان الخادم الجديد',
                  hintStyle: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                  prefixIcon: const Icon(Icons.http),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => !controller.isValidUrl.value
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'الرجاء إدخال رابط صحيح',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أمثلة على العناوين الصحيحة:',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '• http://192.168.1.9:8000\n• https://api.example.com\n• http://localhost:3000',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ApiSettingsController controller) {
    return Column(
      children: [
        // زر الحفظ
        Obx(() => NeumorphicButton(
              onPressed:
                  controller.isLoading.value ? null : controller.saveApiUrl,
              style: NeumorphicStyle(
                depth: 8,
                intensity: 0.65,
                surfaceIntensity: 0.15,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                color: Colors.green.shade50,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: controller.isLoading.value
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'حفظ العنوان الجديد',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
              ),
            )),

        const SizedBox(height: 15),

        // زر إعادة التعيين
        Obx(() => NeumorphicButton(
              onPressed: controller.isLoading.value || controller.isDefaultUrl
                  ? null
                  : controller.resetToDefault,
              style: NeumorphicStyle(
                depth: 8,
                intensity: 0.65,
                surfaceIntensity: 0.15,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                color: controller.isDefaultUrl
                    ? Colors.grey.shade100
                    : Colors.orange.shade50,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color:
                          controller.isDefaultUrl ? Colors.grey : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'إعادة تعيين للافتراضي',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: controller.isDefaultUrl
                            ? Colors.grey
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 20),

        // معلومات إضافية
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Text(
                'العنوان الافتراضي:',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                controller.defaultUrl,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
