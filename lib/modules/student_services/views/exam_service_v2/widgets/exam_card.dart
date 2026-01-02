import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';
import '../exam_model.dart';
import '../neumorphic_widgets.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;
  final bool isCompleted;

  const ExamCard({
    Key? key,
    required this.exam,
    required this.onTap,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
          HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: NeumorphicCard(
        depth: 3,
        intensity: 1,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الامتحان
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة نوع الامتحان
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? AppColors.darkTextSecondary
                        : homeController.getSecondaryColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      exam.type == 'اختيارات'
                          ? Icons.check_circle_outline
                          : Icons.rule,
                      color: Get.isDarkMode
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // تفاصيل الامتحان
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        exam.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // معلومات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // القسم والمستوى
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      children: [
                        Icon(
                          Icons.layers,
                          size: 16,
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
                        ),
                      ],
                    ),
                  ],
                ),

                // عدد الأسئلة واللغة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Get.isDarkMode
                              ? AppColors.darkTextColor.withOpacity(0.7)
                              : AppColors.textColor.withOpacity(0.7),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${exam.questionsCount} سؤال',
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
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 16,
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
                  ],
                ),
              ],
            ),

            // شارة الاكتمال إذا كان الامتحان مكتملاً
            if (isCompleted)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'مكتمل',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
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
