import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../core/themes/colors.dart';
import 'exam_record_model.dart';
import 'exam_result_controller.dart';
import 'neumorphic_widgets.dart';

class ExamResultView extends StatelessWidget {
  final ExamResultController controller = Get.find<ExamResultController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Get.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/loading_posts.json',
                  width: 200,
                  height: 200,
                ),
              );
            }

            if (controller.exam.value == null ||
                controller.examRecord.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/error.json',
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'لم يتم العثور على نتيجة الامتحان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor
                            : AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () {
                        Get.back();
                      },
                      depth: 3,
                      intensity: 1,
                      child: Text(
                        'العودة',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildResultContent(context);
          }),
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final exam = controller.exam.value!;
    final record = controller.examRecord.value!;
    final isPassed = record.score >= 50;

    return CustomScrollView(
      slivers: [
        // رأس الصفحة
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                NeumorphicButton(
                  onPressed: () {
                    Get.back();
                  },
                  depth: 3,
                  intensity: 1,
                  color: Get.isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  child: Icon(
                    Icons.arrow_back,
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نتيجة الامتحان',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                        ),
                      ),
                      Text(
                        exam.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // رسوم متحركة للنجاح أو الفشل
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Obx(() {
              if (controller.showSuccessAnimation.value) {
                return Lottie.asset(
                  'assets/animations/delete_success.json',
                  repeat: false,
                );
              } else if (controller.showFailureAnimation.value) {
                return Lottie.asset(
                  'assets/animations/error.json',
                  repeat: false,
                );
              }
              return SizedBox();
            }),
          ),
        ),

        // بطاقة النتيجة
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: NeumorphicCard(
              depth: 3,
              intensity: 1,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // النتيجة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'النتيجة: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                        ),
                      ),
                      Text(
                        '${record.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // حالة النجاح أو الفشل
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isPassed ? 'ناجح' : 'راسب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),

                  // إحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'الإجابات الصحيحة',
                        '${record.correct}',
                        Colors.green,
                      ),
                      _buildStatItem(
                        'الإجابات الخاطئة',
                        '${record.wrong}',
                        Colors.red,
                      ),
                      _buildStatItem(
                        'إجمالي الأسئلة',
                        '${controller.questions.length}',
                        Get.isDarkMode
                            ? AppColors.darkPrimaryColor
                            : homeController.getSecondaryColor(),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // رسم بياني للنتيجة
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: record.correct,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                topRight: record.wrong == 0
                                    ? Radius.circular(10)
                                    : Radius.zero,
                                bottomRight: record.wrong == 0
                                    ? Radius.circular(10)
                                    : Radius.zero,
                              ),
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: record.wrong,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                topLeft: record.correct == 0
                                    ? Radius.circular(10)
                                    : Radius.zero,
                                bottomLeft: record.correct == 0
                                    ? Radius.circular(10)
                                    : Radius.zero,
                              ),
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // عنوان مراجعة الإجابات
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.question_answer,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
                SizedBox(width: 8),
                Text(
                  'مراجعة الإجابات',
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
          ),
        ),

        // قائمة الأسئلة والإجابات
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final answer = record.answers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildQuestionAnswerCard(answer, index),
              );
            },
            childCount: record.answers.length,
          ),
        ),

        // أزرار الإجراءات
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeumorphicButton(
                  onPressed: () {
                    controller.retryExam();
                  },
                  depth: 3,
                  intensity: 1,
                  color: Get.isDarkMode
                      ? AppColors.darkTextSecondary
                      : homeController.getSecondaryColor(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                NeumorphicButton(
                  onPressed: () {
                    Get.toNamed('/exams');
                  },
                  depth: 3,
                  intensity: 1,
                  color: homeController.getPrimaryColor(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'الرئيسية',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionAnswerCard(QuestionAnswer answer, int index) {
    HomeController homeController = Get.find<HomeController>();

    final isCorrect = answer.isCorrect;
    final isTrueFalse = answer.questionType == 'صح و خطأ' ||
        answer.userAnswer == 'صح' ||
        answer.userAnswer == 'خطأ' ||
        answer.correctAnswer == 'صح' ||
        answer.correctAnswer == 'خطأ';

    return NeumorphicCard(
      depth: 3,
      intensity: 1,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رقم السؤال والحالة
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'السؤال ${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCorrect ? 'صحيحة' : 'خاطئة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // نص السؤال
          Text(
            answer.question,
            style: TextStyle(
              fontSize: 16,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
            ),
          ),

          SizedBox(height: 16),

          // نوع السؤال
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? AppColors.darkPrimaryColor.withOpacity(0.2)
                  : homeController.getPrimaryColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isTrueFalse ? 'صح وخطأ' : 'اختيارات متعددة',
              style: TextStyle(
                fontSize: 12,
                color: Get.isDarkMode
                    ? AppColors.darkPrimaryColor
                    : homeController.getPrimaryColor(),
              ),
            ),
          ),

          SizedBox(height: 16),

          // عرض الإجابات
          isTrueFalse
              ? _buildTrueFalseAnswers(answer)
              : _buildMultipleChoiceAnswers(answer),
        ],
      ),
    );
  }

  Widget _buildTrueFalseAnswers(QuestionAnswer answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجابتك:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        SizedBox(height: 8),
        _buildAnswerOption(
          answer.userAnswer,
          answer.userAnswer == answer.correctAnswer,
          true,
        ),
        SizedBox(height: 12),
        if (answer.userAnswer != answer.correctAnswer) ...[
          Text(
            'الإجابة الصحيحة:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
            ),
          ),
          SizedBox(height: 8),
          _buildAnswerOption(
            answer.correctAnswer,
            true,
            false,
          ),
        ],
      ],
    );
  }

  Widget _buildMultipleChoiceAnswers(QuestionAnswer answer) {
    final options = answer.options ?? ['خيار 1', 'خيار 2', 'خيار 3', 'خيار 4'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخيارات:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        SizedBox(height: 8),
        ...options.map((option) {
          final isUserAnswer = option == answer.userAnswer;
          final isCorrectAnswer = option == answer.correctAnswer;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildAnswerOption(
              option,
              isCorrectAnswer,
              isUserAnswer,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerOption(String text, bool isCorrect, bool isSelected) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isSelected && isCorrect) {
      // إجابة المستخدم صحيحة
      backgroundColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
      textColor = Colors.green;
    } else if (isSelected && !isCorrect) {
      // إجابة المستخدم خاطئة
      backgroundColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red;
      textColor = Colors.red;
    } else if (!isSelected && isCorrect) {
      // الإجابة الصحيحة التي لم يخترها المستخدم
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green.withOpacity(0.5);
      textColor = Colors.green;
    } else {
      // خيار عادي
      backgroundColor = Colors.grey.withOpacity(0.1);
      borderColor = Colors.grey.withOpacity(0.3);
      textColor =
          Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected || isCorrect
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected) ...[
            SizedBox(width: 8),
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 20,
            ),
          ] else if (isCorrect) ...[
            SizedBox(width: 8),
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Get.isDarkMode
                ? AppColors.darkTextColor.withOpacity(0.7)
                : AppColors.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
