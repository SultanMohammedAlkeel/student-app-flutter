import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../../core/themes/colors.dart';
import '../../models/appearance_settings_model.dart';

class ThemePresetCard extends StatelessWidget {
  final ThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ThemePresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(int.parse(preset.primaryColor));
    final secondaryColor = Color(int.parse(preset.secondaryColor));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            depth: isSelected ? -4 : (isDarkMode ? -2 : 3),
            intensity: 0.8,
            color: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            border: isSelected
                ? NeumorphicBorder(
                    color: primaryColor,
                    width: 2,
                  )
                : NeumorphicBorder.none(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorPreview(primaryColor, secondaryColor),
                const SizedBox(height: 8),
                Text(
                  preset.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? primaryColor
                        : (isDarkMode ? Colors.white : AppColors.textPrimary),
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Text(
                //   preset.description,
                //   style: TextStyle(
                //     fontSize: 10,
                //     color:
                //         isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
                //     fontFamily: 'Tajawal',
                //   ),
                //   textAlign: TextAlign.center,
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                // ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color primaryColor, Color secondaryColor) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                depth: isDarkMode ? -1 : 2,
                intensity: 0.6,
                color: primaryColor,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                depth: isDarkMode ? -1 : 2,
                intensity: 0.6,
                color: secondaryColor,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
