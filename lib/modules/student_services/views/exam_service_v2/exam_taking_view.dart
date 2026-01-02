import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../core/themes/colors.dart';
import 'widgets/animated_question_card.dart';
import 'exam_taking_controller.dart';
import 'neumorphic_widgets.dart';

class ExamTakingView extends StatelessWidget {
  final ExamTakingController controller = Get.find<ExamTakingController>();

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

            if (controller.exam.value == null) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/error.json',
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        'لم يتم العثور على الامتحان',
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
                ),
              );
            }

            if (!controller.isExamStarted.value) {
              return _buildExamIntro(context);
            }

            if (controller.isExamCompleted.value) {
              return _buildExamCompleted(context);
            }

            return _buildExamContent(context);
          }),
        ),
      ),
    );
  }

  Widget _buildExamIntro(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final exam = controller.exam.value!;

    return Container(
      color:
          Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // زر العودة
          NeumorphicButton(
            color: Get.isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            onPressed: () {
              Get.back();
            },
            depth: Get.isDarkMode ? -2 : 2,
            intensity: 1,
            child: Icon(
              Icons.arrow_back,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
            ),
          ),

          SizedBox(height: 24),

          // معلومات الامتحان
          NeumorphicCard(
            depth: 3,
            intensity: 1,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  exam.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor.withOpacity(0.7)
                        : AppColors.textColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),

                // معلومات إضافية
                _buildInfoRow(Icons.help_outline, 'عدد الأسئلة',
                    '${controller.questions.length} سؤال'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.category, 'نوع الامتحان', exam.type),
                SizedBox(height: 8),
                _buildInfoRow(Icons.language, 'اللغة', exam.language),
                SizedBox(height: 8),
                _buildInfoRow(
                    Icons.school, 'القسم', exam.departmentName ?? 'غير محدد'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.layers, 'المستوى', exam.level),
              ],
            ),
          ),

          Spacer(),

          // تعليمات الامتحان
          NeumorphicCard(
            depth: 3,
            intensity: 1,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعليمات الامتحان',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
                  ),
                ),
                SizedBox(height: 8),
                _buildInstructionRow('يجب الإجابة على جميع الأسئلة'),
                _buildInstructionRow('يمكنك التنقل بين الأسئلة بحرية'),
                _buildInstructionRow('يمكنك تغيير إجاباتك قبل تسليم الامتحان'),
                _buildInstructionRow(
                    'بعد تسليم الامتحان، لا يمكنك تغيير إجاباتك'),
              ],
            ),
          ),

          SizedBox(height: 24),

          // زر بدء الامتحان
          NeumorphicButton(
            color: Get.isDarkMode
                ? AppColors.darkTextSecondary
                : homeController.getPrimaryColor(),
            onPressed: () {
              controller.startExam();
            },
            depth: 3,
            intensity: 1,
            width: 300,
            height: 50,
            child: Text(
              'بدء الامتحان',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamContent(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Column(
      children: [
        // شريط التقدم
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السؤال ${controller.currentQuestionIndex.value + 1} من ${controller.questions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Get.isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${controller.userAnswers.where((a) => a.answer.isNotEmpty).length} / ${controller.questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: controller.questions.isEmpty
                    ? 0
                    : (controller.currentQuestionIndex.value + 1) /
                        controller.questions.length,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  homeController.getPrimaryColor(),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),

        // بطاقة السؤال
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PageView.builder(
              itemCount: controller.questions.length,
              controller: controller
                  .pageController, // استخدم PageController من الـ controller
              onPageChanged: (index) {
                controller.currentQuestionIndex.value =
                    index; // تحديث المؤشر عند السحب
              },
              itemBuilder: (context, index) {
                final question = controller.questions[index];
                final answer = index < controller.userAnswers.length
                    ? controller.userAnswers[index].answer
                    : '';

                return AnimatedQuestionCard(
                  language: controller.exam.value!.language,
                  question: question,
                  index: index,
                  totalQuestions: controller.questions.length,
                  selectedAnswer: answer,
                  onAnswerSelected: (selectedAnswer) {
                    controller.setAnswer(selectedAnswer);
                  },
                );
              },
            ),
          ),
        ),
        // أزرار التنقل
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر السؤال السابق
              NeumorphicButton(
                color: Get.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                child: Icon(
                  Icons.arrow_back,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
                onPressed: controller.currentQuestionIndex.value > 0
                    ? () {
                        controller.previousQuestion();
                      }
                    : () {},
                depth: 3,
                intensity: 1,
              ),

              // زر تسليم الامتحان
              NeumorphicButton(
                color: Get.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                onPressed: controller.areAllQuestionsAnswered
                    ? () => _showSubmitConfirmationDialog(context)
                    : () {},
                depth: 3,
                intensity: 1,
                child: Text(
                  'تسليم الامتحان',
                  style: TextStyle(
                    color: Get.isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
                  ),
                ),
              ),

              // زر السؤال التالي
              NeumorphicButton(
                color: Get.isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                onPressed: controller.currentQuestionIndex.value <
                        controller.questions.length - 1
                    ? () {
                        controller.nextQuestion();
                      }
                    : () {},
                depth: 3,
                intensity: 1,
                child: Icon(
                  Icons.arrow_forward,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamCompleted(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/upload_success.json',
            width: 200,
            height: 200,
          ),
          Text(
            'تم تسليم الامتحان بنجاح',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحويلك إلى صفحة النتائج...',
            style: TextStyle(
              fontSize: 16,
              color: Get.isDarkMode
                  ? AppColors.darkTextColor.withOpacity(0.7)
                  : AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Get.isDarkMode
              ? AppColors.darkTextColor.withOpacity(0.7)
              : AppColors.textColor.withOpacity(0.7),
        ),
        SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Get.isDarkMode
                ? AppColors.darkTextColor.withOpacity(0.7)
                : AppColors.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String text) {
    HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Get.isDarkMode
                ? AppColors.darkPrimaryColor
                : homeController.getPrimaryColor(),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmationDialog(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: NeumorphicCard(
          depth: 3,
          intensity: 1,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/warning.json',
                width: 100,
                height: 100,
              ),
              Text(
                'تأكيد تسليم الامتحان',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'هل أنت متأكد من تسليم الامتحان؟ لن تتمكن من تغيير إجاباتك بعد التسليم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor.withOpacity(0.7)
                      : AppColors.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    depth: 3,
                    intensity: 1,
                    color: Colors.grey,
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  NeumorphicButton(
                    color: Get.isDarkMode
                        ? AppColors.darkPrimaryColor
                        : homeController.getPrimaryColor(),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await controller.submitExam();
                      // if (success == true) {
                      //   // الانتظار قليلاً لعرض رسالة النجاح
                      //   await Future.delayed(Duration(seconds: 2));
                      //   Get.offNamed(
                      //       '/exams/results/${controller.exam.value!.code}');
                      // }
                    },
                    depth: 3,
                    intensity: 1,
                    child: Text(
                      'تسليم',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
