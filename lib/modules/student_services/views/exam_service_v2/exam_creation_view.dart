import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/themes/colors.dart';
import 'exam_creation_controller.dart';
import 'neumorphic_widgets.dart';

class ExamCreationView extends StatelessWidget {
  final ExamCreationController controller = Get.find<ExamCreationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isSubmitting.value) {
            return _buildSubmittingView();
          } else if (controller.isSuccess.value) {
            return _buildSuccessView();
          } else {
            return _buildCreationForm();
          }
        }),
      ),
    );
  }

  // واجهة جاري الإرسال
  Widget _buildSubmittingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/uploading.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 16),
          Text(
            'جاري إنشاء الامتحان...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // واجهة النجاح
  Widget _buildSuccessView() {
    final isDarkMode = Get.isDarkMode;
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final accentColor =
        isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/upload_success.json',
            width: 200,
            height: 200,
            repeat: false,
          ),
          SizedBox(height: 16),
          Text(
            'تم إنشاء الامتحان بنجاح!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.successColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك الآن مشاركة الامتحان مع الطلاب',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                onPressed: () {
                  Get.offAllNamed('/exams');
                },
              ),
              SizedBox(width: 16),
              NeumorphicButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color: accentColor,
                child: Text(
                  'عرض الامتحان',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (controller.createdExamCode.value.isNotEmpty) {
                    Get.offNamed(
                        '/exams/details/${controller.createdExamCode.value}');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // نموذج إنشاء الامتحان
  Widget _buildCreationForm() {
    final isDarkMode = Get.isDarkMode;
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final accentColor =
        isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor;

    return Column(
      children: [
        // شريط العنوان
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              NeumorphicButton(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back,
                  color: textColor,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'إنشاء امتحان جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // نموذج الإنشاء
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // رسوم متحركة
              // Center(
              //   child: Lottie.asset(
              //     'assets/animations/cool_emoji.json',
              //     width: 150,
              //     height: 150,
              //   ),
              // ),

              // SizedBox(height: 16),

              // اسم الامتحان
              _buildSectionTitle('معلومات الامتحان'),
              SizedBox(height: 8),
              NeumorphicTextField(
                controller: controller.nameController,
                hintText: 'اسم الامتحان',
                onChanged: (value) {
                  controller.updateExamName(value);
                },
              ),

              SizedBox(height: 16),

              // وصف الامتحان
              NeumorphicTextField(
                controller: controller.descriptionController,
                hintText: 'وصف الامتحان (اختياري)',
                maxLines: 3,
                onChanged: (value) {
                  controller.updateExamDescription(value);
                },
              ),

              SizedBox(height: 24),

              // القسم والمستوى
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'القسم',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => NeumorphicDropdown<int>(
                              value: controller.selectedDepartmentId.value,
                              items: controller.departments.map((dept) {
                                return DropdownMenuItem<int>(
                                  value: dept.id,
                                  child: Text(dept.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.updateDepartment(value);
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المستوى',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => NeumorphicDropdown<String>(
                              value: controller.selectedLevel.value,
                              items: controller.levels.map((level) {
                                return DropdownMenuItem<String>(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.updateLevel(value);
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // نوع الامتحان واللغة
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع الامتحان',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => NeumorphicDropdown<String>(
                              value: controller.selectedType.value,
                              items: controller.examTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.updateType(value);
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لغة الامتحان',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Obx(() => NeumorphicDropdown<String>(
                              value: controller.selectedLanguage.value,
                              items: controller.languages.map((lang) {
                                return DropdownMenuItem<String>(
                                  value: lang,
                                  child: Text(lang),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.updateLanguage(value);
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // قسم الأسئلة
              _buildSectionTitle('الأسئلة'),
              SizedBox(height: 16),

              // قائمة الأسئلة
              Obx(() {
                if (controller.questions.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/animations/no_results.json',
                          width: 150,
                          height: 150,
                        ),
                        Text(
                          'لم تقم بإضافة أي أسئلة بعد',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.questions.length,
                  itemBuilder: (context, index) {
                    final question = controller.questions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NeumorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // رقم السؤال ونوعه
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'السؤال ${index + 1}',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        controller.editQuestion(index);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: AppColors.errorColor,
                                      ),
                                      onPressed: () {
                                        controller.removeQuestion(index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            // نص السؤال
                            Text(
                              question.question,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            SizedBox(height: 12),

                            // الخيارات أو الإجابة الصحيحة
                            if (question.type == 'اختيارات') ...[
                              Text(
                                'الخيارات:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...question.options.map((option) {
                                final isCorrect =
                                    option == question.correctAnswer;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.circle,
                                        size: 16,
                                        color: isCorrect
                                            ? AppColors.successColor
                                            : textColor.withOpacity(0.5),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                          fontWeight: isCorrect
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ] else if (question.type == 'صح و خطأ') ...[
                              Row(
                                children: [
                                  Text(
                                    'الإجابة الصحيحة:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    question.correctAnswer,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              SizedBox(height: 16),

              // زر إضافة سؤال
              NeumorphicButton(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: textColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'إضافة سؤال جديد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  if (Get.context != null) {
                    _showAddQuestionDialog(Get.context!);
                  }
                },
              ),

              SizedBox(height: 32),

              // زر إنشاء الامتحان
              // Obx(() => NeumorphicButton(
              //   padding: EdgeInsets.symmetric(vertical: 16),
              //   color: controller.canSubmit.value ? accentColor : null,
              //   onPressed: () {
              //     if (controller.canSubmit.value) {
              //       controller.submitExam();
              //     }
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Icon(
              //         Icons.check,
              //         color: controller.canSubmit.value ? Colors.white : textColor.withOpacity(0.5),
              //       ),
              //       SizedBox(width: 8),
              //       Text(
              //         'إنشاء الامتحان',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //           color: controller.canSubmit.value ? Colors.white : textColor.withOpacity(0.5),
              //         ),
              //       ),
              //     ],
              //   ),
              // )),

              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // حوار إضافة سؤال
  void _showAddQuestionDialog(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final accentColor =
        isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor;

    final questionController = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());

    final selectedType = controller.selectedType.value.obs;
    final selectedCorrectOption = 0.obs;
    final selectedTrueFalse = 'صح'.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: NeumorphicCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إضافة سؤال جديد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // نص السؤال
                NeumorphicTextField(
                  controller: questionController,
                  hintText: 'نص السؤال',
                  maxLines: 2,
                ),

                SizedBox(height: 16),

                // نوع السؤال
                Text(
                  'نوع السؤال',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: NeumorphicRadioButton<String>(
                            value: 'اختيارات',
                            groupValue: selectedType.value,
                            onChanged: (value) {
                              if (value != null) {
                                selectedType.value = value;
                              }
                            },
                            child: Text(
                              'اختيارات',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: NeumorphicRadioButton<String>(
                            value: 'صح و خطأ',
                            groupValue: selectedType.value,
                            onChanged: (value) {
                              if (value != null) {
                                selectedType.value = value;
                              }
                            },
                            child: Text(
                              'صح و خطأ',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),

                SizedBox(height: 16),

                // الخيارات أو الإجابة الصحيحة
                Obx(() {
                  if (selectedType.value == 'اختيارات') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الخيارات',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Obx(() => Radio<int>(
                                      value: index,
                                      groupValue: selectedCorrectOption.value,
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectedCorrectOption.value = value;
                                        }
                                      },
                                      activeColor: accentColor,
                                    )),
                                Expanded(
                                  child: NeumorphicTextField(
                                    controller: optionControllers[index],
                                    hintText: 'الخيار ${index + 1}',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Text(
                          'اختر الإجابة الصحيحة بالنقر على الدائرة بجانب الخيار',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجابة الصحيحة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: NeumorphicRadioButton<String>(
                                value: 'صح',
                                groupValue: selectedTrueFalse.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedTrueFalse.value = value;
                                  }
                                },
                                child: Text(
                                  'صح',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: NeumorphicRadioButton<String>(
                                value: 'خطأ',
                                groupValue: selectedTrueFalse.value,
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedTrueFalse.value = value;
                                  }
                                },
                                child: Text(
                                  'خطأ',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }),

                SizedBox(height: 24),

                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NeumorphicButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    SizedBox(width: 16),
                    NeumorphicButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: accentColor,
                      child: Text(
                        'إضافة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (questionController.text.isEmpty) {
                          Get.snackbar(
                            'تنبيه',
                            'يرجى إدخال نص السؤال',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (selectedType.value == 'اختيارات') {
                          final options = optionControllers
                              .map((controller) => controller.text.trim())
                              .where((text) => text.isNotEmpty)
                              .toList();

                          if (options.length < 2) {
                            Get.snackbar(
                              'تنبيه',
                              'يرجى إدخال خيارين على الأقل',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          if (selectedCorrectOption.value >= options.length) {
                            Get.snackbar(
                              'تنبيه',
                              'يرجى اختيار الإجابة الصحيحة',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          //   controller.addQuestion(
                          //     questionController.text,
                          //     'اختيارات',
                          //     options,
                          //     options[selectedCorrectOption.value],
                          //   );
                          // } else {
                          //   controller.addQuestion(
                          //     questionController.text,
                          //     'صح و خطأ',
                          //     ['صح', 'خطأ'],
                          //     selectedTrueFalse.value,
                          //   );
                        }

                        Get.back();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // مكونات مساعدة
  Widget _buildSectionTitle(String title) {
    final isDarkMode = Get.isDarkMode;
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final accentColor =
        isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
