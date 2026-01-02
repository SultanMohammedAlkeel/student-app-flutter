import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:student_app/core/network/api_service.dart';
import '../../../../core/services/storage_service.dart';
import 'exam_model.dart';
import 'exam_record_model.dart';
import 'exam_filter_model.dart';

class ExamRepository {
  final Dio _dio = ApiService().dio;

  ExamRepository();

  // الحصول على قائمة الامتحانات مع تطبيق الفلتر
  Future<List<Exam>> getExams(ExamFilter filter) async {
    try {
      final response = await _dio.get(
        '/exams',
        queryParameters: filter.toJson(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['exams'];
        return data.map((examJson) => Exam.fromJson(examJson)).toList();
      }
      throw Exception('Failed to load exams: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load exams');
    }
  }

  // الحصول على قائمة الامتحانات التي قام المستخدم بإجرائها
  Future<List<Exam>> getMyExams() async {
    try {
      final response = await _dio.get('/exams/my-exams');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['exams'];
        return data.map((examJson) => Exam.fromJson(examJson)).toList();
      }
      throw Exception('Failed to load my exams: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load my exams');
    }
  }

  // الحصول على الامتحانات الشائعة
  Future<List<Exam>> getPopularExams() async {
    try {
      final response = await _dio.get('/exams/popular');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['exams'];
        return data.map((examJson) => Exam.fromJson(examJson)).toList();
      }
      throw Exception('Failed to load popular exams: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load popular exams');
    }
  }

  // الحصول على الامتحانات الحديثة
  Future<List<Exam>> getRecentExams() async {
    try {
      final response = await _dio.get('/exams/recent');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['exams'];
        return data.map((examJson) => Exam.fromJson(examJson)).toList();
      }
      throw Exception('Failed to load recent exams: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load recent exams');
    }
  }

  // الحصول على تفاصيل امتحان محدد
  Future<Map<String,dynamic>> getExamDetails(String code) async {
    try {
      final response = await _dio.get('/exams/$code');

      if (response.statusCode == 200) {
        return (response.data['exam']);
      }
      throw Exception('Failed to load exam details: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load exam details');
    }
  }

  // إنشاء امتحان جديد
  Future<Exam> createExam(Exam exam) async {
    try {
      final response = await _dio.post(
        '/exams',
        data: exam.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Exam.fromJson(response.data['data']);
      }
      throw Exception('Failed to create exam: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create exam');
    }
  }

  // تحديث امتحان موجود
  Future<Exam> updateExam(String code, Exam exam) async {
    try {
      final response = await _dio.put(
        '/exams/$code',
        data: exam.toJson(),
      );

      if (response.statusCode == 200) {
        return Exam.fromJson(response.data['data']);
      }
      throw Exception('Failed to update exam: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update exam');
    }
  }

  // حذف امتحان
  Future<void> deleteExam(String code) async {
    try {
      final response = await _dio.delete('/exams/$code');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete exam: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to delete exam');
    }
  }

  // تقديم إجابات الامتحان
Future<ExamRecord> submitExamAnswers(
  String code,
  double score,
  int correct,
  int wrong,
  String answers,
) async {
  try {
    final storage = Get.find<StorageService>();
    final student = storage.read<Map<String, dynamic>>('student_data');
    
    final response = await _dio.post(
      '/exams/$code/submit',
      data: {
        'student_id': student?['id'],
        'exam_id': code,
        'score': score.toString(), // تحويل score إلى String لتجنب مشاكل التحويل
        'correct': correct,
        'wrong': wrong,
        'answers': answers,
      },
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return ExamRecord.fromJson(response.data['record']);
    } else if (response.statusCode == 422) {
      final errors = response.data['errors'];
      throw Exception('Validation error: ${errors.values.join(', ')}');
    }
    throw Exception('Failed to submit exam answers: ${response.statusCode}');
  } on DioException catch (e) {
    throw _handleDioError(e, 'Failed to submit exam answers');
  }
} // الحصول على نتيجة امتحان
  Future<ExamRecord> getExamResult(String recordId) async {
    try {
      final response = await _dio.get('/exams/results/$recordId');

      if (response.statusCode == 200) {
        return ExamRecord.fromJson(response.data['data']);
      }
      throw Exception('Failed to get exam result: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to get exam result');
    }
  }

  // معالجة أخطاء Dio
  Exception _handleDioError(DioException e, String defaultMessage) {
    if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'];
      final errorMessages = errors?.values.map((e) => e.join(', ')).join('\n');
      return Exception('Validation error: $errorMessages');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout, please try again');
    } else if (e.type == DioExceptionType.unknown) {
      return Exception('No internet connection');
    } else {
      return Exception('$defaultMessage: ${e.message}');
    }
  }

  // محاكاة استدعاء API للاختبار (اختياري)
  Future<List<Exam>> getMockExams() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      Exam(
        id: 1,
        code: 'ABC123',
        name: 'امتحان تجريبي 1',
        description: 'وصف الامتحان التجريبي 1',
        language: 'عربي',
        type: 'اختيارات',
        departmentId: 1,
        departmentName: 'علوم الحاسوب',
        level: 'المستوى الثالث',
        createdBy: 1,
        creatorName: 'أحمد محمد',
        examData: jsonEncode([
          {
            'question': 'ما هو عاصمة مصر؟',
            'type': 'اختيارات',
            'options': ['القاهرة', 'الإسكندرية', 'أسوان', 'الأقصر'],
            'correct_answer': 'القاهرة',
          },
          {
            'question': 'ما هو أكبر محيط في العالم؟',
            'type': 'اختيارات',
            'options': ['المحيط الهادئ', 'المحيط الأطلسي', 'المحيط الهندي', 'البحر المتوسط'],
            'correct_answer': 'المحيط الهادئ',
          },
        ]),
        createdAt: DateTime.now(),
      ),
      Exam(
        id: 2,
        code: 'DEF456',
        name: 'امتحان تجريبي 2',
        description: 'وصف الامتحان التجريبي 2',
        language: 'عربي',
        type: 'صح و خطأ',
        departmentId: 1,
        departmentName: 'علوم الحاسوب',
        level: 'المستوى الثالث',
        createdBy: 1,
        creatorName: 'أحمد محمد',
        examData: jsonEncode([
          {
            'question': 'الشمس تدور حول الأرض',
            'type': 'صح و خطأ',
            'options': ['صح', 'خطأ'],
            'correct_answer': 'خطأ',
          },
          {
            'question': 'الماء يغلي عند درجة حرارة 100 درجة مئوية',
            'type': 'صح و خطأ',
            'options': ['صح', 'خطأ'],
            'correct_answer': 'صح',
          },
        ]),
        createdAt: DateTime.now(),
      ),
    ];
  }
}