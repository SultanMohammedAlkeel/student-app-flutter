import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/core/themes/colors.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _homeController = Get.find<HomeController>();
    final isDarkMode = Get.isDarkMode;

    final bgColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'الدردشة',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: _homeController.getPrimaryColor()),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Neumorphic(
                  margin: const EdgeInsets.only(bottom: 12),
                  style: NeumorphicStyle(
                    color: bgColor,
                    depth: isDarkMode ? -2 : 4,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _homeController.getPrimaryColor().withOpacity(0.1),
                      child: Icon(Icons.person,
                          color: _homeController.getPrimaryColor()),
                    ),
                    title: Text(
                      'اسم المستخدم ${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      'آخر رسالة...',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: isDarkMode
                            ? Colors.grey[400]
                            : AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '10:30',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: _homeController.getPrimaryColor(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(
              color: bgColor,
              depth: 8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file,
                        color: _homeController.getPrimaryColor()),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        hintStyle: TextStyle(fontFamily: 'Tajawal'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: _homeController.getPrimaryColor()),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
