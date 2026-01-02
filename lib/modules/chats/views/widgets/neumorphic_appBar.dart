// ignore_for_file: use_super_parameters, camel_case_types

// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

class NeumorphicApp_Bar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? color;

  const NeumorphicApp_Bar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.elevation = 0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = NeumorphicTheme.isUsingDark(context);
    final backgroundColor =
        Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: elevation,
        color: color,
        boxShape: NeumorphicBoxShape.rect(),
      ),
      child: AppBar(
        automaticallyImplyLeading: false, // إزالة السهم التلقائي
        shadowColor: backgroundColor,
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
