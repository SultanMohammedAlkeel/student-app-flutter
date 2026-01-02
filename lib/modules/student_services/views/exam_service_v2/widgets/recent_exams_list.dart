import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../exam_model.dart';
import '../neumorphic_widgets.dart';

class RecentExamsList extends StatelessWidget {
  final RxList<Exam> exams;
  final bool isLoading;
  final VoidCallback onViewMore;

  const RecentExamsList({
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
                'أحدث الامتحانات',
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

        // قائمة الامتحانات الحديثة
        SizedBox(
          height: 220,
          child: isLoading
              ? Center(
                  child: Lottie.asset(
                    'assets/animations/loading_posts.json',
                    width: 150,
                    height: 150,
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
                            'لا توجد امتحانات حديثة',
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
                        return _buildRecentExamCard(context, exam);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildRecentExamCard(BuildContext context, Exam exam) {
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
            // شريط علوي مع نوع الامتحان
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    Get.isDarkMode ? AppColors.plutoColor : homeController.getSecondaryColor(),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    exam.type == 'اختيارات'
                        ? Icons.check_circle_outline
                        : Icons.rule,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    exam.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                  SizedBox(height: 3),
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
                  SizedBox(height: 3),

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
                  SizedBox(height: 3),
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
                  // شارة "جديد"
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            'جديد',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
