import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';

class HomeDrawerMenu extends StatelessWidget {
  const HomeDrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Drawer(
      backgroundColor: NeumorphicTheme.baseColor(context),
      child: Column(
        children: [
          Neumorphic(
            margin: const EdgeInsets.only(bottom: 16),
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(
                const BorderRadius.only(bottomRight: Radius.circular(20)),
              ),
              depth: 4,
            ),
            child: DrawerHeader(
              child: Center(
                child: NeumorphicText(
                  'Student Menu',
                  style: NeumorphicStyle(
                    color: Colors.black87,
                  ),
                  textStyle: NeumorphicTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            label: 'Profile',
            onTap: () {
              controller.changePage(3);
              Get.back();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              // Navigate to settings
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            onTap: controller.logout,
          ),
          _buildMenuItem(context, icon: Icons.info, label: "About", onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Student App',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.school),
              children: [
                const Text(
                    'This app is designed to help students manage their academic life.'),
              ],
            );
          })
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          boxShape: NeumorphicBoxShape.circle(),
          depth: 2,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: NeumorphicTheme.isUsingDark(context)
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
      title: NeumorphicText(
        label,
        style: NeumorphicStyle(
          color: NeumorphicTheme.isUsingDark(context)
              ? Colors.white
              : Colors.black87,
        ),
        textStyle: NeumorphicTextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}
