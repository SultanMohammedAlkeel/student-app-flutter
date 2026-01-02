import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../exam_taking_controller.dart';
import '../neumorphic_widgets.dart';

class AnimatedQuestionCard extends StatelessWidget {
  final ExamQuestion question;
  final int index;
  final int totalQuestions;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final bool showResult;
  final bool isCorrect;
  final String language;

  const AnimatedQuestionCard({
    Key? key,
    required this.question,
    required this.index,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.language,
    this.showResult = false,
    this.isCorrect = false,
  }) : super(key: key);

  bool get isRTL => language == 'عربي';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Hero(
        tag: 'question_$index',
        child: NeumorphicCard(
          depth: 3,
          intensity: 1,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionHeader(),
              const SizedBox(height: 16),
              _buildQuestionText(),
              const SizedBox(height: 24),
              ..._buildAnswerOptions(context),
              if (showResult && selectedAnswer != null) _buildResultIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuestionNumber(),
        _buildQuestionType(),
      ],
    );
  }

  Widget _buildQuestionNumber() {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? AppColors.darkPrimaryColor
            : homeController.getPrimaryColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isRTL
            ? 'سؤال ${index + 1} من $totalQuestions'
            : 'Question ${index + 1} of $totalQuestions',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQuestionType() {
          HomeController homeController = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkBackground : homeController.getSecondaryColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        question.type,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildQuestionText() {
    return Text(
      question.question,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
      ),
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
    );
  }

  List<Widget> _buildAnswerOptions(BuildContext context) {
    return question.options
        .map((option) => _buildAnswerOption(context, option))
        .toList();
  }

  Widget _buildAnswerOption(BuildContext context, String option) {
    final bool isSelected = selectedAnswer == option;
    final bool isCorrectAnswer = question.correctAnswer == option;

    Color? backgroundColor =
        _getOptionBackgroundColor(isSelected, isCorrectAnswer);

    return GestureDetector(
      onTap: showResult ? null : () => onAnswerSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getOptionBorderColor(isSelected),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (!isRTL) const SizedBox(width: 12),
            _buildOptionSelector(isSelected),
            const SizedBox(width: 12),
            _buildOptionText(option),
            if (isRTL) const SizedBox(width: 12),
            if (showResult) _buildResultIcon(isCorrectAnswer, isSelected),
          ],
        ),
      ),
    );
  }

  Color? _getOptionBackgroundColor(bool isSelected, bool isCorrectAnswer) {
    HomeController homeController = Get.find<HomeController>();

    if (showResult) {
      if (isCorrectAnswer) return Colors.green.withOpacity(0.2);
      if (isSelected && !isCorrectAnswer) return Colors.red.withOpacity(0.2);
    } else if (isSelected) {
      return Get.isDarkMode
          ? AppColors.darkPrimaryColor.withOpacity(0.2)
          : homeController.getPrimaryColor().withOpacity(0.3);
    }
    return null;
  }

  Color _getOptionBorderColor(bool isSelected) {
    HomeController homeController = Get.find<HomeController>();

    return isSelected
        ? (Get.isDarkMode
            ? AppColors.darkPrimaryColor
            : homeController.getPrimaryColor())
        : Colors.grey.withOpacity(0.3);
  }

  Widget _buildOptionSelector(bool isSelected) {
    HomeController homeController = Get.find<HomeController>();

    return Container(

      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? (Get.isDarkMode
                ? AppColors.darkPrimaryColor
                : AppColors.primaryColor)
            : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? (Get.isDarkMode
                  ? AppColors.darkPrimaryColor
                  :  AppColors.primaryColor)
              : Colors.grey.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 16,
              color: homeController.getPrimaryColor(),
            )
          : null,
    );
  }

  Widget _buildOptionText(String option) {
    return Expanded(
      child: Text(
        option,
        style: TextStyle(
          fontSize: 16,
          fontWeight:
              selectedAnswer == option ? FontWeight.bold : FontWeight.normal,
          color: Get.isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
        ),
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
      ),
    );
  }

  Widget _buildResultIcon(bool isCorrectAnswer, bool isSelected) {
    return Icon(
      isCorrectAnswer ? Icons.check_circle : (isSelected ? Icons.cancel : null),
      color: isCorrectAnswer ? Colors.green : Colors.red,
    );
  }

  Widget _buildResultIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCorrect
                  ? isRTL
                      ? 'إجابة صحيحة!'
                      : 'Correct Answer!'
                  : isRTL
                      ? 'إجابة خاطئة. الإجابة الصحيحة هي: ${question.correctAnswer}'
                      : 'Wrong Answer. Correct answer is: ${question.correctAnswer}',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
