import 'package:get/get.dart';
import 'exam_model.dart';
import 'exam_record_model.dart';
import 'exam_filter_model.dart';
import 'exam_repository.dart';
import 'widgets/exam_filter_dialog.dart';

class ExamController extends GetxController {
  final ExamRepository repository;

  // قوائم الامتحانات
  final RxList<Exam> exams = <Exam>[].obs;
  final RxList<Exam> myExams = <Exam>[].obs;
  final RxList<Exam> popularExams = <Exam>[].obs;
  final RxList<Exam> recentExams = <Exam>[].obs;

  // حالة التحميل
  final RxBool isLoading = false.obs;
  final RxBool isMyExamsLoading = false.obs;
  final RxBool isPopularExamsLoading = false.obs;
  final RxBool isRecentExamsLoading = false.obs;

  // الفلتر الحالي
  final Rx<ExamFilter> currentFilter = ExamFilter().obs;

  // الامتحان الحالي
  final Rx<Exam?> currentExam = Rx<Exam?>(null);

  ExamController({required this.repository});

  @override
  void onInit() async{
    super.onInit();
   await loadExams();
    await loadMyExams();
    await loadPopularExams();
    await loadRecentExams();
  }

  // تحميل قائمة الامتحانات المتاحة
  Future<void> loadExams() async {
    isLoading.value = true;
    try {
      final List<Exam> result = await repository.getExams(currentFilter.value);
         exams.assignAll(result);
    } catch (e) {
      print('خطأ في تحميل الامتحانات: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الامتحانات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل قائمة الامتحانات التي قام المستخدم بإجرائها
  Future<void> loadMyExams() async {
    isMyExamsLoading.value = true;
    try {
      final result = await repository.getMyExams();
      myExams.assignAll(result);
    } catch (e) {
      print('خطأ في تحميل امتحاناتي: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل امتحاناتك',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isMyExamsLoading.value = false;
    }
  }

  // تحميل الامتحانات الشائعة
  Future<void> loadPopularExams() async {
    isPopularExamsLoading.value = true;
    try {
      final result = await repository.getPopularExams();
      popularExams.assignAll(result);
    } catch (e) {
      print('خطأ في تحميل الامتحانات الشائعة: $e');
    } finally {
      isPopularExamsLoading.value = false;
    }
  }

  // تحميل الامتحانات الحديثة
  Future<void> loadRecentExams() async {
    isRecentExamsLoading.value = true;
    try {
      final result = await repository.getRecentExams();
      recentExams.assignAll(result);
    } catch (e) {
      print('خطأ في تحميل الامتحانات الحديثة: $e');
    } finally {
      isRecentExamsLoading.value = false;
    }
  }

  // تحميل تفاصيل امتحان محدد
  Future<void> loadExamDetails(String code) async {
    try {
      final exam = await repository.getExamDetails(code);
      currentExam.value =Exam.fromJson(exam);
      
    } catch (e) {
      print('خطأ في تحميل تفاصيل الامتحان: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل تفاصيل الامتحان',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تطبيق فلتر
  Future<void> applyFilter(ExamFilter filter) async {
    currentFilter.value = filter;
    await loadExams();
  }

  // إعادة تعيين الفلتر
  Future<void> resetFilter() async {
    currentFilter.value = currentFilter.value.reset();
    await loadExams();
  }

  // إنشاء امتحان جديد
  Future<bool> createExam(Exam exam) async {
    try {
      final success = true;
      await repository.createExam(exam);
      if (success) {
        await loadExams();
        Get.snackbar(
          'نجاح',
          'تم إنشاء الامتحان بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return success;
    } catch (e) {
      print('خطأ في إنشاء الامتحان: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إنشاء الامتحان',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // حذف امتحان
  Future<bool> deleteExam(String code) async {
    try {
      final bool success = true;
      await repository.deleteExam(code);
      if (success) {
        await loadExams();
        Get.snackbar(
          'نجاح',
          'تم حذف الامتحان بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return success;
    } catch (e) {
      print('خطأ في حذف الامتحان: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الامتحان',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void showFilterDialog() {
    //Get.to(ExamFilterDialog());
  }
}
