import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../exam_model.dart';
import '../neumorphic_widgets.dart';

class MostPopularExamsList extends StatelessWidget {
  final RxList<Exam> exams;
  final bool isLoading;
  final VoidCallback onViewMore;

  const MostPopularExamsList({
    Key? key,
    required this.exams,
    required this.isLoading,
    required this.onViewMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان وزر عرض المزيد
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الامتحانات الأكثر شعبية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.textColor,
                ),
              ),
              TextButton.icon(
                onPressed: onViewMore,
                icon: Icon(Icons.arrow_forward),
                label: Text('عرض الكل'),
              ),
            ],
          ),
        ),

        // قائمة الامتحانات الشائعة
        SizedBox(
          height: 230,
          child: isLoading
              ? Center(
                  child: Lottie.asset(
                    'assets/animations/loading_posts.json',
                    width: 150,
                    height: 160,
                  ),
                )
              : exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/no_results.json',
                            width: 120,
                            height: 120,
                          ),
                          Text(
                            'لا توجد امتحانات شائعة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Get.isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: exams.length,
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return _buildPopularExamCard(context, exam);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPopularExamCard(BuildContext context, Exam exam) {
    HomeController homeController = Get.find<HomeController>();

    return Container(
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: NeumorphicCard(
        depth: 3,
        intensity: 1,
        onTap: () {
          Get.toNamed('/exams/take/${exam.code}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة نوع الامتحان
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? AppColors.darkBackground
                    : homeController.getSecondaryColor(),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  exam.type == 'اختيارات'
                      ? Icons.check_circle_outline
                      : Icons.rule,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الامتحان
                  Text(
                    exam.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Get.isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 16,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor.withOpacity(0.7)
                            : AppColors.textColor.withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        exam.departmentName ?? 'غير محدد',
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),

                  // المستوى
                  Row(
                    children: [
                      Icon(
                        Icons.layers,
                        size: 14,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor.withOpacity(0.7)
                            : AppColors.textColor.withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        exam.level,
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),

                  // اللغة
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.language,
                        size: 14,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor.withOpacity(0.7)
                            : AppColors.textColor.withOpacity(0.7),
                      ),
                      SizedBox(width: 4),
                      Text(
                        exam.language,
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        exam.takenCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 16,
                        color: Get.isDarkMode
                            ? AppColors.darkTextColor.withOpacity(0.7)
                            : AppColors.textColor.withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
