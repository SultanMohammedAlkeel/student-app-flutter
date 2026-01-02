import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';

import '../widgets/background_design.dart';
import '../widgets/login_credentials.dart';

class LoginScreen extends GetView {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode
          ? AppColors.darkBackground
          : AppColors.lightBackground, // Similar to your white constant
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: Stack(
            children: [
              BackgroundDesign(),
              LoginCredentials(),
              //   BottomContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
