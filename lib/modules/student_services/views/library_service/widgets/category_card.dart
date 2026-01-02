import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category? category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
          HomeController homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: isSelected ? -2 : 2,
            intensity: 0.9,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            color: isSelected
                ? homeController.getPrimaryColor().withOpacity(0.1)
                : AppColors.getBackgroundColor(Get.isDarkMode),
            lightSource: LightSource.topLeft,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة التصنيف
              Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: isSelected ? 2 : 3,
                  intensity: 0.8,
                  color: isSelected
                      ? homeController.getPrimaryColor()
                      : AppColors.lightBackground,
                  lightSource: LightSource.topLeft,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _getCategoryIcon(),
                    color: isSelected ? Colors.white : homeController.getPrimaryColor(),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // اسم التصنيف
              NeumorphicText(
                category?.name ?? 'الكل',
                textStyle: NeumorphicTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
                style: NeumorphicStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              // عدد الكتب (إذا كان متاحاً)
              if (category != null)
                NeumorphicText(
                  '${category!.booksCount} كتاب',
                  textStyle: NeumorphicTextStyle(
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                  ),
                  style: NeumorphicStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (category == null) {
      return Icons.category;
    }

    // يمكن تخصيص أيقونات مختلفة حسب اسم التصنيف
    final name = category!.name.toLowerCase();

    if (name.contains('علم') || name.contains('علوم')) {
      return Icons.science;
    } else if (name.contains('أدب') || name.contains('شعر')) {
      return Icons.menu_book;
    } else if (name.contains('تاريخ')) {
      return Icons.history_edu;
    } else if (name.contains('دين') || name.contains('إسلام')) {
      return Icons.mosque;
    } else if (name.contains('فن') || name.contains('موسيقى')) {
      return Icons.palette;
    } else if (name.contains('تقنية') ||
        name.contains('برمجة') ||
        name.contains('حاسوب')) {
      return Icons.computer;
    } else if (name.contains('طب') || name.contains('صحة')) {
      return Icons.medical_services;
    } else if (name.contains('اقتصاد') || name.contains('تجارة')) {
      return Icons.attach_money;
    } else if (name.contains('قانون')) {
      return Icons.gavel;
    } else if (name.contains('هندسة')) {
      return Icons.architecture;
    }

    // أيقونة افتراضية
    return Icons.book;
  }
}
