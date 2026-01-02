import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

import 'book_upload_controller.dart';

class BookUploadView extends StatelessWidget {
  final BookUploadController controller = Get.put(BookUploadController());

  BookUploadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = Get.isDarkMode;
      final bgColor = _getBackgroundColor(isDarkMode);
      final cardColor = _getCardColor(isDarkMode);
      final textColor = _getTextColor(isDarkMode);

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDarkMode, textColor, cardColor, context),
              Expanded(
                child: controller.isLoading.value
                    ? _buildLoadingState(isDarkMode)
                    : _buildMainContent(
                        isDarkMode, textColor, cardColor, context),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    final responsivePadding = _getResponsivePadding(context);

    return Container(
      padding: responsivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(isDarkMode, () => Get.back()),
          NeumorphicText(
            'إضافة كتاب جديد',
            textStyle: NeumorphicTextStyle(
              fontSize: _getResponsiveFontSize(context, 22),
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            style: NeumorphicStyle(
              color: isDarkMode
                  ? AppColors.lightBackground
                  : AppColors.darkBackground,
              depth: 3,
            ),
          ),
          const SizedBox(width: 48), // للمحافظة على التوازن
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDarkMode, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(isDarkMode);
      }

      return SizedBox(
        width: double.infinity,
        child: NeumorphicButton(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            depth: 3,
            intensity: 1,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            color: homeController.getPrimaryColor(),
            lightSource: LightSource.topLeft,
          ),
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(context, 16),
          ),
          child: Center(
            child: Text(
              'إضافة الكتاب',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            // التحقق من الحقول قبل الإرسال
            final isValid = controller.validateData();
            if (isValid) {
              controller.uploadBook();
            }
          },
        ),
      );
    });
  }

  Widget _buildLoadingState(bool isDarkMode) {
    HomeController homeController = Get.find<HomeController>();

    return Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(homeController.getPrimaryColor()),
          ),
          SizedBox(height: 16),
          Text(
            'جاري رفع الكتاب...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getTextColor(isDarkMode),
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الكتاب الأساسية
            _buildSectionTitle('معلومات الكتاب', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildBasicInfoSection(isDarkMode, textColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 24)),

            // تصنيف الكتاب
            _buildSectionTitle('تصنيف الكتاب', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildCategorySection(isDarkMode, textColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 24)),

            // محددات الوصول
            _buildSectionTitle('محددات الوصول', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildAccessSection(isDarkMode, textColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 24)),

            // ملف الكتاب
            _buildSectionTitle('ملف الكتاب', isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            _buildFileSection(isDarkMode, textColor, cardColor, context),
            SizedBox(height: _getResponsiveSpacing(context, 32)),

            // زر الإضافة
            _buildSubmitButton(isDarkMode, context),
            SizedBox(height: _getResponsiveSpacing(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الكتاب
            _buildInputField(
              context: context,
              isDarkMode: isDarkMode,
              label: 'عنوان الكتاب',
              hint: 'أدخل عنوان الكتاب',
              controller: controller.titleController,
              isRequired: true,
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),

            // اسم المؤلف
            _buildInputField(
              context: context,
              isDarkMode: isDarkMode,
              label: 'اسم المؤلف',
              hint: 'أدخل اسم المؤلف',
              controller: controller.authorController,
              isRequired: true,
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),

            // وصف الكتاب
            _buildInputField(
              context: context,
              isDarkMode: isDarkMode,
              label: 'وصف الكتاب',
              hint: 'أدخل وصفاً مختصراً للكتاب',
              controller: controller.descriptionController,
              maxLines: 4,
              isRequired: true,
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),

            // رمز الكتاب
            _buildInputField(
              context: context,
              isDarkMode: isDarkMode,
              label: 'رمز الكتاب',
              hint: 'أدخل رمز الكتاب (اختياري)',
              controller: controller.codeController,
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التصنيف
// في جزء بناء القائمة المنسدلة للتصنيفات
            _buildDropdownField(
              context: context,
              isDarkMode: isDarkMode,
              label: 'التصنيف',
              hint: 'اختر تصنيف الكتاب',
              value: controller.selectedCategoryId.value == 0
                  ? null
                  : controller.selectedCategoryId.value,
              items: controller.categories
                  .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedCategoryId.value = value as int;
              },
              isRequired: true,
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),

            // // الكلية
            // _buildDropdownField(
            //   context: context,
            //   isDarkMode: isDarkMode,
            //   label: 'الكلية',
            //   hint: 'اختر الكلية (اختياري)',
            //   value: controller.selectedCollegeId.value == 0
            //       ? null
            //       : controller.selectedCollegeId.value,
            //   items: controller.colleges
            //       .map((college) => DropdownMenuItem(
            //             value: college.id,
            //             child: Text(college.name),
            //           ))
            //       .toList(),
            //   onChanged: (value) {
            //     controller.selectedCollegeId.value = value as int;
            //     controller.loadDepartments();
            //   },
            // ),
            // SizedBox(height: _getResponsiveSpacing(context, 16)),

            // // // القسم
            // _buildDropdownField(
            //   context: context,
            //   isDarkMode: isDarkMode,
            //   label: 'القسم',
            //   hint: 'اختر القسم (اختياري)',
            //   value: controller.selectedDepartmentId.value == 0
            //       ? null
            //       : controller.selectedDepartmentId.value,
            //   items: controller.departments
            //       .map((department) => DropdownMenuItem(
            //             value: department.id,
            //             child: Text(department.name),
            //           ))
            //       .toList(),
            //   onChanged: (value) {
            //     controller.selectedDepartmentId.value = value as int;
            //   },
            //   isEnabled: controller.selectedCollegeId.value != 0,
            // ),
            // SizedBox(height: _getResponsiveSpacing(context, 16)),

            // // المستوى
            // _buildDropdownField(
            //   context: context,
            //   isDarkMode: isDarkMode,
            //   label: 'المستوى',
            //   hint: 'اختر المستوى (اختياري)',
            //   value: controller.selectedLevel.value.isEmpty
            //       ? null
            //       : controller.selectedLevel.value,
            //   items: controller.levels
            //       .map((level) => DropdownMenuItem(
            //             value: level,
            //             child: Text(level),
            //           ))
            //       .toList(),
            //   onChanged: (value) {
            //     controller.selectedLevel.value = value as String;
            //   },
            // ),
          ],
        ),
      ),
    );
  }

// في الجزء الخاص بحقول الإدخال، نعدل دالة _buildInputField
  Widget _buildInputField({
    required BuildContext context,
    required bool isDarkMode,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    String? errorText,
  }) {
    final textColor = _getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            depth: -3,
            intensity: 1,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            lightSource: LightSource.topLeft,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: textColor,
              fontSize: _getResponsiveFontSize(context, 14),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: _getResponsiveSpacing(context, 16),
                vertical: _getResponsiveSpacing(context, 12),
              ),
              errorText: errorText,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(
              top: _getResponsiveSpacing(context, 4),
              right: _getResponsiveSpacing(context, 8),
            ),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: _getResponsiveFontSize(context, 12),
              ),
            ),
          ),
      ],
    );
  }

// نعدل دالة _buildDropdownField بنفس الطريقة
  Widget _buildDropdownField<T>({
    required BuildContext context,
    required bool isDarkMode,
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    bool isRequired = false,
    bool isEnabled = true,
    String? errorText,
  }) {
    final textColor = _getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            depth: -3,
            intensity: 1,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            lightSource: LightSource.topLeft,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsiveSpacing(context, 16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
                items: items,
                onChanged: isEnabled ? onChanged : null,
                isExpanded: true,
                dropdownColor: isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                style: TextStyle(
                  color: textColor,
                  fontSize: _getResponsiveFontSize(context, 14),
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(
              top: _getResponsiveSpacing(context, 4),
              right: _getResponsiveSpacing(context, 8),
            ),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: _getResponsiveFontSize(context, 12),
              ),
            ),
          ),
      ],
    );
  }

// نعدل دالة _buildFileSection لإظهار رسائل الخطأ
  Widget _buildFileSection(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ملف الكتاب',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            Obx(() {
              if (controller.selectedFile.value == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilePickerButton(isDarkMode, context),
                    if (controller.hasError.value &&
                        controller.selectedFile.value == null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: _getResponsiveSpacing(context, 4),
                          right: _getResponsiveSpacing(context, 8),
                        ),
                        child: Text(
                          'ملف الكتاب مطلوب',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: _getResponsiveFontSize(context, 12),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                return _buildSelectedFileInfo(isDarkMode, textColor, context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessSection(
      bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        color: cardColor,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نوع الكتاب',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: _getResponsiveSpacing(context, 12)),
            Obx(() => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildBookTypeChip(
                      context,
                      isDarkMode,
                      'عام',
                      controller.selectedBookType.value == 'عام',
                      () => controller.selectedBookType.value = 'عام',
                    ),
                    _buildBookTypeChip(
                      context,
                      isDarkMode,
                      'خاص',
                      controller.selectedBookType.value == 'خاص',
                      () => controller.selectedBookType.value = 'خاص',
                    ),
                    _buildBookTypeChip(
                      context,
                      isDarkMode,
                      'مشترك',
                      controller.selectedBookType.value == 'مشترك',
                      () => controller.selectedBookType.value = 'مشترك',
                    ),
                    _buildBookTypeChip(
                      context,
                      isDarkMode,
                      'محدد',
                      controller.selectedBookType.value == 'محدد',
                      () => controller.selectedBookType.value = 'محدد',
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTypeChip(BuildContext context, bool isDarkMode, String label,
      bool isSelected, VoidCallback onTap) {
    HomeController homeController = Get.find<HomeController>();

    return InkWell(
      onTap: onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: isSelected ? -3 : 3,
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
          color: isSelected
              ? homeController.getPrimaryColor()
              : isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
          lightSource: LightSource.topLeft,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSpacing(context, 16),
            vertical: _getResponsiveSpacing(context, 8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: isSelected
                  ? Colors.white
                  : isDarkMode
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildFileSection(
  //     bool isDarkMode, Color textColor, Color cardColor, BuildContext context) {
  //   return Neumorphic(
  //     style: NeumorphicStyle(
  //       shape: NeumorphicShape.flat,
  //       depth: 3,
  //       intensity: 1,
  //       boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
  //       color: cardColor,
  //       lightSource: LightSource.topLeft,
  //     ),
  //     child: Padding(
  //       padding: _getResponsivePadding(context),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Text(
  //                 'ملف الكتاب',
  //                 style: TextStyle(
  //                   fontSize: _getResponsiveFontSize(context, 16),
  //                   fontWeight: FontWeight.bold,
  //                   color: textColor,
  //                 ),
  //               ),
  //               Text(
  //                 ' *',
  //                 style: TextStyle(
  //                   fontSize: _getResponsiveFontSize(context, 16),
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.red,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: _getResponsiveSpacing(context, 16)),
  //           Obx(() => controller.selectedFile.value == null
  //               ? _buildFilePickerButton(isDarkMode, context)
  //               : _buildSelectedFileInfo(isDarkMode, textColor, context)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFilePickerButton(bool isDarkMode, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return InkWell(
      onTap: () => controller.pickFile(),
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          depth: 3,
          intensity: 1,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          color:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          lightSource: LightSource.topLeft,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: _getResponsiveSpacing(context, 24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: homeController.getPrimaryColor(),
              ),
              SizedBox(height: _getResponsiveSpacing(context, 12)),
              Text(
                'اضغط لاختيار ملف',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: _getResponsiveSpacing(context, 8)),
              Text(
                'PDF, Word, Excel, PowerPoint (الحد الأقصى: 20 ميجابايت)',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileInfo(
      bool isDarkMode, Color textColor, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final file = controller.selectedFile.value!;
    final fileName = file.path.split('/').last;
    final fileSize = _formatFileSize(file.lengthSync());
    final fileIcon = _getFileIcon(fileName);

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 16)),
        child: Row(
          children: [
            Icon(
              fileIcon,
              size: 40,
              color: homeController.getPrimaryColor(),
            ),
            SizedBox(width: _getResponsiveSpacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _getResponsiveSpacing(context, 4)),
                  Text(
                    fileSize,
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red,
              onPressed: () => controller.clearSelectedFile(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSubmitButton(bool isDarkMode, BuildContext context) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: NeumorphicButton(
  //       style: NeumorphicStyle(
  //         shape: NeumorphicShape.flat,
  //         depth: 3,
  //         intensity: 1,
  //         boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  //         color: homeController.getPrimaryColor(),
  //         lightSource: LightSource.topLeft,
  //       ),
  //       padding: EdgeInsets.symmetric(
  //         vertical: _getResponsiveSpacing(context, 16),
  //       ),
  //       child: Center(
  //         child: Text(
  //           'إضافة الكتاب',
  //           style: TextStyle(
  //             fontSize: _getResponsiveFontSize(context, 18),
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //       onPressed: () => controller.uploadBook(),
  //     ),
  //   );
  // }

  // Widget _buildInputField({
  //   required BuildContext context,
  //   required bool isDarkMode,
  //   required String label,
  //   required String hint,
  //   required TextEditingController controller,
  //   bool isRequired = false,
  //   int maxLines = 1,
  // }) {
  //   final textColor = _getTextColor(isDarkMode);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: _getResponsiveFontSize(context, 16),
  //               fontWeight: FontWeight.bold,
  //               color: textColor,
  //             ),
  //           ),
  //           if (isRequired)
  //             Text(
  //               ' *',
  //               style: TextStyle(
  //                 fontSize: _getResponsiveFontSize(context, 16),
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.red,
  //               ),
  //             ),
  //         ],
  //       ),
  //       SizedBox(height: _getResponsiveSpacing(context, 8)),
  //       Neumorphic(
  //         style: NeumorphicStyle(
  //           shape: NeumorphicShape.flat,
  //           depth: -3,
  //           intensity: 1,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  //           color: isDarkMode
  //               ? AppColors.darkBackground
  //               : AppColors.lightBackground,
  //           lightSource: LightSource.topLeft,
  //         ),
  //         child: TextField(
  //           controller: controller,
  //           maxLines: maxLines,
  //           style: TextStyle(
  //             color: textColor,
  //             fontSize: _getResponsiveFontSize(context, 14),
  //           ),
  //           decoration: InputDecoration(
  //             hintText: hint,
  //             hintStyle: TextStyle(
  //               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
  //               fontSize: _getResponsiveFontSize(context, 14),
  //             ),
  //             border: InputBorder.none,
  //             contentPadding: EdgeInsets.symmetric(
  //               horizontal: _getResponsiveSpacing(context, 16),
  //               vertical: _getResponsiveSpacing(context, 12),
  //             ),
  //           ),
  //           textDirection: TextDirection.rtl,
  //           textAlign: TextAlign.right,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDropdownField<T>({
  //   required BuildContext context,
  //   required bool isDarkMode,
  //   required String label,
  //   required String hint,
  //   required T? value,
  //   required List<DropdownMenuItem<T>> items,
  //   required void Function(T?) onChanged,
  //   bool isRequired = false,
  //   bool isEnabled = true,
  // }) {
  //   final textColor = _getTextColor(isDarkMode);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: _getResponsiveFontSize(context, 16),
  //               fontWeight: FontWeight.bold,
  //               color: textColor,
  //             ),
  //           ),
  //           if (isRequired)
  //             Text(
  //               ' *',
  //               style: TextStyle(
  //                 fontSize: _getResponsiveFontSize(context, 16),
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.red,
  //               ),
  //             ),
  //         ],
  //       ),
  //       SizedBox(height: _getResponsiveSpacing(context, 8)),
  //       Neumorphic(
  //         style: NeumorphicStyle(
  //           shape: NeumorphicShape.flat,
  //           depth: -3,
  //           intensity: 1,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
  //           color: isDarkMode
  //               ? AppColors.darkBackground
  //               : AppColors.lightBackground,
  //           lightSource: LightSource.topLeft,
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(
  //             horizontal: _getResponsiveSpacing(context, 16),
  //           ),
  //           child: DropdownButtonHideUnderline(
  //             child: DropdownButton<T>(
  //               value: value,
  //               hint: Text(
  //                 hint,
  //                 style: TextStyle(
  //                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
  //                   fontSize: _getResponsiveFontSize(context, 14),
  //                 ),
  //               ),
  //               items: items,
  //               onChanged: isEnabled ? onChanged : null,
  //               isExpanded: true,
  //               dropdownColor: isDarkMode
  //                   ? AppColors.darkBackground
  //                   : AppColors.lightBackground,
  //               style: TextStyle(
  //                 color: textColor,
  //                 fontSize: _getResponsiveFontSize(context, 14),
  //               ),
  //               icon: Icon(
  //                 Icons.arrow_drop_down,
  //                 color: textColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSectionTitle(
      String title, bool isDarkMode, BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _getResponsiveSpacing(context, 8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.bold,
          color: homeController.getPrimaryColor(),
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDarkMode, VoidCallback onPressed) {
    HomeController homeController = Get.find<HomeController>();

    return NeumorphicButton(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 3,
        intensity: 1,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        color: _getCardColor(isDarkMode),
        lightSource: LightSource.topLeft,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: homeController.getPrimaryColor(),
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  // Widget _buildLoadingState(bool isDarkMode) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         NeumorphicProgress(
  //           height: 10.0,
  //           percent: 0.8,
  //           style: ProgressStyle(
  //             accent: homeController.getPrimaryColor(),
  //             variant: homeController.getPrimaryColor().withOpacity(0.5),
  //             depth: 3,
  //             lightSource: LightSource.topLeft,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Text(
  //           'جاري رفع الكتاب...',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //             color: _getTextColor(isDarkMode),
  //             fontFamily: 'Tajawal',
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // دوال مساعدة
  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  }

  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : const Color(0xFF333333);
  }

  double _getResponsiveFontSize(BuildContext context, double size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return size * 0.8;
    if (screenWidth < 600) return size * 0.9;
    if (screenWidth < 900) return size;
    return size * 1.1;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return const EdgeInsets.all(12);
    if (screenWidth < 600) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  double _getResponsiveSpacing(BuildContext context, double spacing) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return spacing * 0.8;
    if (screenWidth < 600) return spacing * 0.9;
    if (screenWidth < 900) return spacing;
    return spacing * 1.1;
  }

  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
