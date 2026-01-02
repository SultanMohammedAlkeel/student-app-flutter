import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/themes/colors.dart';
import 'exam_controller.dart';
import 'neumorphic_widgets.dart';
import 'exam_model.dart';

class ViewMoreExamsView extends StatelessWidget {
  final ExamController controller = Get.find<ExamController>();
  final String type;
  final String title;
  
  ViewMoreExamsView({
    Key? key,
    required this.type,
    required this.title,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildExamsList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    
    return Container(
      padding: EdgeInsets.all(16),
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
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          NeumorphicButton(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.filter_list,
              color: textColor,
            ),
            onPressed: () {
              // عرض نافذة الفلترة
              controller.showFilterDialog();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildExamsList() {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    
    return Obx(() {
      // تحديد قائمة الامتحانات المناسبة
      List<Exam> exams = [];
      bool isLoading = false;
      
      if (type == 'popular') {
        exams = controller.popularExams;
        isLoading = controller.isPopularExamsLoading.value;
      } else if (type == 'recent') {
        exams = controller.recentExams;
        isLoading = controller.isRecentExamsLoading.value;
      } else {
        exams = controller.exams;
        isLoading = controller.isLoading.value;
      }
      
      if (isLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading_posts.json',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 16),
              Text(
                'جاري تحميل الامتحانات...',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }
      
      if (exams.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/no_results.json',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 16),
              Text(
                'لا توجد امتحانات متاحة',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              SizedBox(height: 24),
              NeumorphicButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'تحديث',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                onPressed: () {
                  if (type == 'popular') {
                    controller.loadPopularExams();
                  } else if (type == 'recent') {
                    controller.loadRecentExams();
                  } else {
                    controller.loadExams();
                  }
                },
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          if (type == 'popular') {
            await controller.loadPopularExams();
          } else if (type == 'recent') {
            await controller.loadRecentExams();
          } else {
            await controller.loadExams();
          }
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return _buildExamCard(exam);
          },
        ),
      );
    });
  }
  
  Widget _buildExamCard(Exam exam) {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final accentColor = isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor;
    
    return NeumorphicCard(
      margin: EdgeInsets.only(bottom: 16),
      onTap: () {
        Get.toNamed('/exams/details/${exam.code}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الامتحان
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة نوع الامتحان
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  exam.type == 'اختيارات' ? Icons.check_box : Icons.check_circle,
                  color: accentColor,
                  size: 30,
                ),
              ),
              
              SizedBox(width: 12),
              
              // معلومات الامتحان
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      exam.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // معلومات إضافية
          Row(
            children: [
              _buildInfoChip(Icons.school, exam.departmentName ?? 'غير محدد'),
              SizedBox(width: 8),
              _buildInfoChip(Icons.sort, exam.level),
              SizedBox(width: 8),
              _buildInfoChip(Icons.language, exam.language),
            ],
          ),
          
          SizedBox(height: 12),
          
          // إحصائيات الامتحان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // المنشئ
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    exam.creatorName ?? 'غير معروف',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              // التاريخ
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(exam.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              // عدد الأسئلة
              Row(
                children: [
                  Icon(
                    Icons.question_answer,
                    size: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${exam.questionsCount} سؤال',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text) {
    final isDarkMode = Get.isDarkMode;
    final textColor = isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor.withOpacity(0.7),
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'غير معروف';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'منذ ${difference.inHours} ساعة';
      }
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
