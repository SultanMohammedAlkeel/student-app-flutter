import 'dart:convert';

import 'package:get/get.dart';
import 'exam_model.dart';
import 'exam_record_model.dart';
import 'exam_repository.dart';
import 'exam_taking_controller.dart';

class ExamResultController extends GetxController {
  final ExamRepository repository;
  
  // بيانات النتيجة
  final Rx<Exam?> exam = Rx<Exam?>(null);
  final Rx<ExamRecord?> examRecord = Rx<ExamRecord?>(null);
  final RxList<ExamQuestion> questions = <ExamQuestion>[].obs;
  
  // حالة التحميل
  final RxBool isLoading = true.obs;
  
  // حالة الرسوم المتحركة
  final RxBool showSuccessAnimation = false.obs;
  final RxBool showFailureAnimation = false.obs;
  
  ExamResultController({required this.repository});
  
  @override
  void onInit() {
    super.onInit();
    
    // الحصول على معرف السجل من المسار أو من البيانات المرسلة
    final dynamic recordData = Get.arguments;
    
    if (recordData != null) {
      // إذا كان هناك بيانات مرسلة مباشرة من شاشة تقديم الامتحان
      if (recordData is Map<String, dynamic>) {
        if (recordData.containsKey('record') && recordData.containsKey('exam')) {
          // استخدام البيانات المرسلة مباشرة
          processExamData(recordData['exam'], recordData['record']);
        } else if (recordData.containsKey('record_id')) {
          // استخدام معرف السجل للحصول على البيانات
          loadExamResult(recordData['record_id'].toString());
        }
      } else if (recordData is ExamRecord) {
        // إذا كان السجل مرسل ككائن مباشرة
        examRecord.value = recordData;
        loadExamDetails(recordData.examId.toString());
      }
    } else {
      // محاولة الحصول على معرف السجل من المسار
      final String? recordId = Get.parameters['code'];
      if (recordId != null) {
        loadExamResult(recordId);
      } else {
        isLoading.value = false;
      }
    }
  }
  
  // تحميل نتيجة الامتحان باستخدام معرف السجل
  Future<void> loadExamResult(String recordId) async {
    try {
      isLoading.value = true;
      
      final record = await repository.getExamResult(recordId);
      examRecord.value = record;
      
      // تحميل تفاصيل الامتحان
      await loadExamDetails(record.examId.toString());
      
    } catch (e) {
      print('خطأ في تحميل نتيجة الامتحان: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تحميل نتيجة الامتحان');
    } finally {
      isLoading.value = false;
      _showResultAnimation();
    }
  }
  
  // تحميل تفاصيل الامتحان
  Future<void> loadExamDetails(String examId) async {
    try {
      final examData = await repository.getExamDetails(examId);
      
      if (examData != null) {
        exam.value = Exam.fromJson(examData);
        
        // تحليل بيانات الأسئلة
        final List<dynamic> questionsData = examData['exam_data'] is String
            ? jsonDecode(examData['exam_data'])
            : examData['exam_data'] as List<dynamic>;
        
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
              type: exam.value!.type,
              options: ['صح', 'خطأ'], // الخيارات الثابتة لأسئلة الصح/خطأ
              correctAnswer: questionData['answer']?.toString() ?? '',
            ));
          }
        }
      }
    } catch (e) {
      print('خطأ في تحميل تفاصيل الامتحان: $e');
    }
  }
  
  // معالجة بيانات الامتحان المرسلة مباشرة
  void processExamData(dynamic examData, dynamic recordData) {
    try {
      // معالجة بيانات الامتحان
      if (examData != null) {
        exam.value = examData is Exam ? examData : Exam.fromJson(examData);
      }
      
      // معالجة بيانات السجل
      if (recordData != null) {
        examRecord.value = recordData is ExamRecord 
            ? recordData 
            : ExamRecord.fromJson(recordData);
        
        // استخراج الأسئلة من سجل الإجابات
        if (examRecord.value != null && examRecord.value!.answers.isNotEmpty) {
          questions.clear();
          
          for (var answer in examRecord.value!.answers) {
            // تحديد نوع السؤال
            final isMultipleChoice = answer.questionType == 'اختيارات' || 
                (answer.correctAnswer != 'صح' && answer.correctAnswer != 'خطأ');
            
            if (isMultipleChoice) {
              // أسئلة الاختيارات
              questions.add(ExamQuestion(
                question: answer.question,
                type: 'اختيارات',
                options: answer.options ?? [],
                correctAnswer: answer.correctAnswer,
              ));
            } else {
              // أسئلة الصح/خطأ
              questions.add(ExamQuestion(
                question: answer.question,
                type: 'صح و خطأ',
                options: ['صح', 'خطأ'],
                correctAnswer: answer.correctAnswer,
              ));
            }
          }
        }
      }
      
      isLoading.value = false;
      _showResultAnimation();
    } catch (e) {
      print('خطأ في معالجة بيانات الامتحان: $e');
      isLoading.value = false;
    }
  }
  
  // الحصول على إجابة المستخدم لسؤال محدد
  String getUserAnswer(int index) {
    if (examRecord.value == null || examRecord.value!.answers.isEmpty) {
      return '';
    }
    
    if (index < examRecord.value!.answers.length) {
      return examRecord.value!.answers[index].userAnswer;
    }
    
    return '';
  }
  
  // التحقق مما إذا كانت إجابة المستخدم صحيحة
  bool isAnswerCorrect(int index) {
    if (examRecord.value == null || examRecord.value!.answers.isEmpty) {
      return false;
    }
    
    if (index < examRecord.value!.answers.length) {
      return examRecord.value!.answers[index].isCorrect;
    }
    
    return false;
  }
  
  // عرض الرسوم المتحركة للنجاح أو الفشل
  void _showResultAnimation() {
    if (examRecord.value != null) {
      if (examRecord.value!.score >= 50) {
        showSuccessAnimation.value = true;
      } else {
        showFailureAnimation.value = true;
      }
    }
  }
  
  // إعادة محاولة الامتحان
  void retryExam() {
    if (exam.value != null) {
      Get.toNamed('/exams/take/${exam.value!.code}');
    }
  }
}
