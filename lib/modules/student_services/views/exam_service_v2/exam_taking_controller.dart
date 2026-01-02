import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_model.dart';
import 'exam_record_model.dart';
import 'exam_repository.dart';
import 'exam_filter_model.dart';

class ExamTakingController extends GetxController {
  final ExamRepository repository;
  late PageController pageController;

  // بيانات الامتحان
  final Rx<Exam?> exam = Rx<Exam?>(null);
  final RxList<ExamQuestion> questions = <ExamQuestion>[].obs;
  final RxList<UserAnswer> userAnswers = <UserAnswer>[].obs;

  // حالة الامتحان
  final RxBool isLoading = true.obs;
  final RxBool isExamStarted = false.obs;
  final RxBool isExamCompleted = false.obs;
  final RxInt currentQuestionIndex = 0.obs;

  ExamTakingController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    // الحصول على رمز الامتحان من المسار
    pageController = PageController();

    final String? examCode = Get.parameters['code'];
    if (examCode != null) {
      loadExam(examCode);
    } else {
      isLoading.value = false;
    }
  }

  // تحميل بيانات الامتحان
  Future<void> loadExam(String code) async {
    try {
      isLoading.value = true;

      final loadedExam = await repository.getExamDetails(code);
      print('Exam Data: ${loadedExam.toString()}');

      if (loadedExam != null) {
        exam.value = Exam.fromJson(loadedExam);

        // تحليل بيانات الأسئلة
        final List<dynamic> questionsData = loadedExam['exam_data'] is String
            ? jsonDecode(loadedExam['exam_data'])
            : loadedExam['exam_data'] as List<dynamic>;

        questions.clear();
        for (var questionData in questionsData) {
          final isMultipleChoice = exam.value!.type.contains('اختيار') ||
              exam.value!.type.contains('choice');

          if (isMultipleChoice) {
            // معالجة أسئلة الاختيارات
            final options = <String>[];
            for (int i = 1; i <= 4; i++) {
              final option = questionData['option_$i']?.toString();
              if (option != null && option.isNotEmpty) {
                options.add(option);
              }
            }

            questions.add(ExamQuestion(
              question: questionData['question']?.toString() ?? '',
              type: exam.value!.type,
              options: options,
              correctAnswer: questionData['correct_answer']?.toString() ?? '',
            ));
          } else {
            // معالجة أسئلة الصح/خطأ
            questions.add(ExamQuestion(
              question: questionData['question']?.toString() ?? '',
              type: 'صح و خطأ',
              options: ['صح', 'خطأ'], // الخيارات الثابتة لأسئلة الصح/خطأ
              correctAnswer: questionData['answer']?.toString() ?? '',
            ));
          }
        }

        // تهيئة إجابات المستخدم
        userAnswers.clear();
        for (var i = 0; i < questions.length; i++) {
          userAnswers.add(UserAnswer(questionIndex: i, answer: ''));
        }
      }
    } catch (e, stackTrace) {
      print('خطأ في تحميل الامتحان: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل الامتحان');
    } finally {
      isLoading.value = false;
    }
  }

  // بدء الامتحان
  void startExam() {
    isExamStarted.value = true;
    currentQuestionIndex.value = 0;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      pageController.animateToPage(
        currentQuestionIndex.value,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      pageController.animateToPage(
        currentQuestionIndex.value,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
      pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // تعيين إجابة للسؤال الحالي
  void setAnswer(String answer) {
    final index = currentQuestionIndex.value;
    if (index >= 0 && index < userAnswers.length) {
      userAnswers[index] = UserAnswer(questionIndex: index, answer: answer);
      userAnswers.refresh();
    }
  }

  // التحقق من إجابة جميع الأسئلة
  bool get areAllQuestionsAnswered {
    return userAnswers.every((answer) => answer.answer.isNotEmpty);
  }

  // تقديم الامتحان
  Future<bool> submitExam() async {
    try {
      isExamCompleted.value = true;

      // حساب النتيجة
      int correct = 0;
      int wrong = 0;

      for (int i = 0; i < questions.length; i++) {
        if (userAnswers[i].answer == questions[i].correctAnswer) {
          correct++;
        } else {
          wrong++;
        }
      }

      // حساب النسبة المئوية
      final double score = (correct / questions.length) * 100;

      // تحويل الإجابات إلى JSON
      final String answersJson = userAnswersToJson();

      // تقديم الإجابات إلى الخادم
      final ExamRecord record = await repository.submitExamAnswers(
        exam.value!.code,
        score,
        correct,
        wrong,
        answersJson,
      );

      await Future.delayed(Duration(seconds: 2));
      // التنقل إلى صفحة النتائج مع تمرير البيانات مباشرة
      Get.offNamed('/exams/results/${record.id}',
          arguments: {'record': record, 'exam': exam.value});

      return true;
    } catch (e) {
      print('خطأ في تقديم الامتحان: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تقديم الامتحان');
      return false;
    }
  }

  // تحويل إجابات المستخدم إلى JSON
  String userAnswersToJson() {
    final List<Map<String, dynamic>> answersData = [];

    for (int i = 0; i < questions.length; i++) {
      answersData.add({
        'question_index': i,
        'question': questions[i].question,
        'user_answer': userAnswers[i].answer,
        'correct_answer': questions[i].correctAnswer,
        'is_correct': userAnswers[i].answer == questions[i].correctAnswer,
        'question_type': questions[i].type,
        'options': questions[i].options,
      });
    }

    return jsonEncode(answersData);
  }
}

// نموذج لسؤال الامتحان
class ExamQuestion {
  final String question;
  final String type; // 'true_false' أو 'multiple_choice'
  final List<String> options; // للاختيارات فقط
  final String correctAnswer; // للإجابة الصحيحة

  ExamQuestion({
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    // تحديد نوع السؤال
    final type = json['type']?.toString().toLowerCase() ?? '';
    final isMultipleChoice = type.contains('اختيار') || type.contains('choice');

    // معالجة أسئلة الاختيارات
    if (isMultipleChoice) {
      // إنشاء قائمة الخيارات من الحقول option_1 إلى option_4
      final options = <String>[];
      for (int i = 1; i <= 4; i++) {
        final optionKey = 'option_$i';
        if (json.containsKey(optionKey) && json[optionKey] != null) {
          options.add(json[optionKey].toString());
        }
      }

      return ExamQuestion(
        question: json['question']?.toString() ?? '',
        type: 'اختيارات',
        options: options,
        correctAnswer: json['correct_answer']?.toString() ??
            json['correctAnswer']?.toString() ??
            (options.isNotEmpty ? options[0] : ''),
      );
    }
    // معالجة أسئلة الصح/الخطأ
    else if (json['answer'] != null) {
      return ExamQuestion(
        question: json['question']?.toString() ?? '',
        type: 'صح و خطأ',
        options: ['صح', 'خطأ'],
        correctAnswer: json['answer']?.toString() ?? '',
      );
    }
    // الحالة الافتراضية للسؤال غير المعروف
    else {
      return ExamQuestion(
        question: json['question']?.toString() ?? '',
        type: type,
        options: [],
        correctAnswer: json['correct_answer']?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type,
      'options': options,
      'correct_answer': correctAnswer,
    };
  }
}

// نموذج لإجابة المستخدم
class UserAnswer {
  final int questionIndex;
  final String answer;

  UserAnswer({
    required this.questionIndex,
    required this.answer,
  });
}
