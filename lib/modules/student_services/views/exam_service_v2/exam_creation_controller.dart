import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_model.dart';
import 'exam_repository.dart';
import 'exam_taking_controller.dart';

class ExamCreationController extends GetxController {
  final ExamRepository repository;
  
  // نموذج الامتحان
  final RxString examName = ''.obs;
  final RxString examDescription = ''.obs;
  final RxInt selectedDepartmentId = 0.obs;
  final RxString selectedLevel = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString selectedLanguage = ''.obs;
  
  // قائمة الأسئلة
  final RxList<ExamQuestion> questions = <ExamQuestion>[].obs;
  
  // حالة الإرسال
  final RxBool isSubmitting = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString createdExamCode = ''.obs;
  
  // حالة تحرير السؤال
  final RxBool isEditingQuestion = false.obs;
  final RxInt editingQuestionIndex = (-1).obs;
  
  // وحدات تحكم النص
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();
  final List<TextEditingController> optionsControllers = List.generate(4, (_) => TextEditingController());
  
  // قوائم البيانات
  final RxList<Department> departments = <Department>[].obs;
  final RxList<String> levels = <String>[
    'المستوى الاول',
    'المستوى الثاني',
    'المستوى الثالث',
    'المستوى الرابع',
    'المستوى الخامس',
    'المستوى السادس',
    'المستوى السابع'
  ].obs;
  final RxList<String> examTypes = <String>['اختيارات', 'صح و خطأ'].obs;
  final RxList<String> languages = <String>['عربي', 'انجليزي'].obs;
  
  ExamCreationController({required this.repository});
  
  @override
  void onInit() {
    super.onInit();
    loadDepartments();
    
    // تعيين القيم الافتراضية
    selectedType.value = examTypes[0];
    selectedLanguage.value = languages[0];
    selectedLevel.value = levels[0];
  }
  
  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    questionController.dispose();
    correctAnswerController.dispose();
    for (var controller in optionsControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  
  // تحميل الأقسام
  Future<void> loadDepartments() async {
    try {
      // هنا يمكن استدعاء API للحصول على الأقسام
      // لأغراض المثال، سنستخدم بيانات وهمية
      departments.assignAll([
        Department(id: 1, name: 'علوم الحاسوب'),
        Department(id: 2, name: 'هندسة البرمجيات'),
        Department(id: 3, name: 'نظم المعلومات'),
        Department(id: 4, name: 'الذكاء الاصطناعي'),
      ]);
      
      if (departments.isNotEmpty) {
        selectedDepartmentId.value = departments[0].id;
      }
    } catch (e) {
      print('خطأ في تحميل الأقسام: $e');
    }
  }
  
  // تحديث اسم الامتحان
  void updateExamName(String name) {
    examName.value = name;
  }
  
  // تحديث وصف الامتحان
  void updateExamDescription(String description) {
    examDescription.value = description;
  }
  
  // تحديث القسم
  void updateDepartment(int departmentId) {
    selectedDepartmentId.value = departmentId;
  }
  
  // تحديث المستوى
  void updateLevel(String level) {
    selectedLevel.value = level;
  }
  
  // تحديث نوع الامتحان
  void updateType(String type) {
    selectedType.value = type;
    
    // إذا تم تغيير النوع إلى "صح و خطأ"، تحديث الخيارات لجميع الأسئلة
    if (type == 'صح و خطأ') {
      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        questions[i] = ExamQuestion(
          question: question.question,
          type: type,
          options: ['صح', 'خطأ'],
          correctAnswer: question.correctAnswer == 'صح' || question.correctAnswer == 'خطأ' 
              ? question.correctAnswer 
              : 'صح',
        );
      }
    }
  }
  
  // تحديث لغة الامتحان
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }
  
  // إضافة سؤال جديد
  void addQuestion() {
    if (questionController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال نص السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (selectedType.value == 'اختيارات') {
      // التحقق من إدخال الخيارات
      final options = optionsControllers.map((c) => c.text.trim()).toList();
      if (options.any((option) => option.isEmpty)) {
        Get.snackbar(
          'خطأ',
          'يرجى إدخال جميع الخيارات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // التحقق من الإجابة الصحيحة
      if (!options.contains(correctAnswerController.text.trim())) {
        Get.snackbar(
          'خطأ',
          'الإجابة الصحيحة يجب أن تكون أحد الخيارات',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // إضافة السؤال
      if (isEditingQuestion.value && editingQuestionIndex.value >= 0) {
        // تحديث سؤال موجود
        questions[editingQuestionIndex.value] = ExamQuestion(
          question: questionController.text.trim(),
          type: selectedType.value,
          options: options,
          correctAnswer: correctAnswerController.text.trim(),
        );
      } else {
        // إضافة سؤال جديد
        questions.add(ExamQuestion(
          question: questionController.text.trim(),
          type: selectedType.value,
          options: options,
          correctAnswer: correctAnswerController.text.trim(),
        ));
      }
    } else {
      // سؤال صح وخطأ
      if (correctAnswerController.text.trim() != 'صح' && correctAnswerController.text.trim() != 'خطأ') {
        Get.snackbar(
          'خطأ',
          'الإجابة الصحيحة يجب أن تكون "صح" أو "خطأ"',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // إضافة السؤال
      if (isEditingQuestion.value && editingQuestionIndex.value >= 0) {
        // تحديث سؤال موجود
        questions[editingQuestionIndex.value] = ExamQuestion(
          question: questionController.text.trim(),
          type: selectedType.value,
          options: ['صح', 'خطأ'],
          correctAnswer: correctAnswerController.text.trim(),
        );
      } else {
        // إضافة سؤال جديد
        questions.add(ExamQuestion(
          question: questionController.text.trim(),
          type: selectedType.value,
          options: ['صح', 'خطأ'],
          correctAnswer: correctAnswerController.text.trim(),
        ));
      }
    }
    
    // إعادة تعيين حقول الإدخال
    resetQuestionForm();
  }
  
  // تحرير سؤال موجود
  void editQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      final question = questions[index];
      
      questionController.text = question.question;
      correctAnswerController.text = question.correctAnswer;
      
      if (question.type == 'اختيارات') {
        for (var i = 0; i < question.options.length && i < optionsControllers.length; i++) {
          optionsControllers[i].text = question.options[i];
        }
      }
      
      isEditingQuestion.value = true;
      editingQuestionIndex.value = index;
    }
  }
  
  // إزالة سؤال
  void removeQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      questions.removeAt(index);
    }
  }
  
  // إعادة تعيين نموذج السؤال
  void resetQuestionForm() {
    questionController.clear();
    correctAnswerController.clear();
    for (var controller in optionsControllers) {
      controller.clear();
    }
    isEditingQuestion.value = false;
    editingQuestionIndex.value = -1;
  }
  
  // إنشاء الامتحان
  Future<void> createExam() async {
    if (examName.value.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال اسم الامتحان',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (selectedDepartmentId.value == 0) {
      Get.snackbar(
        'خطأ',
        'يرجى اختيار القسم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (questions.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إضافة سؤال واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      // تحويل الأسئلة إلى JSON
      final questionsJson = questions.map((q) => q.toJson()).toList();
      final examData = jsonEncode(questionsJson);
      
      // إنشاء نموذج الامتحان
      final exam = Exam(
        code: '', // سيتم توليده بواسطة الخادم
        name: examName.value,
        description: examDescription.value,
        language: selectedLanguage.value,
        type: selectedType.value,
        departmentId: selectedDepartmentId.value,
        level: selectedLevel.value,
        createdBy: 0, // سيتم تعيينه بواسطة الخادم
        examData: examData,
      );
      
      // إرسال الامتحان إلى الخادم
      final success = await repository.createExam(exam);
      
      if (success== true) {
        // تعيين رمز الامتحان المنشأ (في الواقع، يجب الحصول عليه من استجابة الخادم)
        createdExamCode.value = 'EXAM${DateTime.now().millisecondsSinceEpoch}';
        isSuccess.value = true;
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إنشاء الامتحان',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('خطأ في إنشاء الامتحان: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الامتحان',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

// نموذج للقسم (للاستخدام الداخلي فقط)
class Department {
  final int id;
  final String name;
  
  Department({
    required this.id,
    required this.name,
  });
}
