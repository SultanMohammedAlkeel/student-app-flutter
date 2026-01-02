import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDarkMode;
  final Color textColor;
  final bool enabled;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
    required this.isDarkMode,
    required this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    final effectiveTextColor = enabled ? textColor : textColor.withOpacity(0.5);
    final effectiveIconColor =
        enabled ? homeController.getPrimaryColor() : textColor.withOpacity(0.3);

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: isDarkMode ? -1 : 2,
        intensity: 0.6,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: effectiveTextColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: effectiveTextColor.withOpacity(0.7),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (onTap != null && enabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: effectiveTextColor.withOpacity(0.5),
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
}

class SwitchSettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDarkMode;
  final Color textColor;
  final bool enabled;

  const SwitchSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    this.onChanged,
    required this.isDarkMode,
    required this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return SettingTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isDarkMode: isDarkMode,
      textColor: textColor,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: homeController.getPrimaryColor(),
        inactiveThumbColor: textColor.withOpacity(0.5),
        inactiveTrackColor: textColor.withOpacity(0.2),
      ),
    );
  }
}

class RadioSettingTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final bool isDarkMode;
  final Color textColor;
  final bool enabled;

  const RadioSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    this.onChanged,
    required this.isDarkMode,
    required this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    HomeController homeController = Get.find<HomeController>();

    return SettingTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isDarkMode: isDarkMode,
      textColor: textColor,
      enabled: enabled,
      onTap: enabled ? () => onChanged?.call(value) : null,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        activeColor: homeController.getPrimaryColor(),
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return textColor.withOpacity(0.3);
            }
            if (states.contains(MaterialState.selected)) {
              return homeController.getPrimaryColor();
            }
            return textColor.withOpacity(0.5);
          },
        ),
      ),
    );
  }
}

class SliderSettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final bool isDarkMode;
  final Color textColor;
  final bool enabled;
  final String Function(double)? valueFormatter;

  const SliderSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    required this.isDarkMode,
    required this.textColor,
    this.enabled = true,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();

    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: isDarkMode ? -1 : 2,
        intensity: 0.6,
        color:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: enabled
                      ? homeController.getPrimaryColor()
                      : textColor.withOpacity(0.3),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              enabled ? textColor : textColor.withOpacity(0.5),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: enabled
                                ? textColor.withOpacity(0.7)
                                : textColor.withOpacity(0.4),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  valueFormatter?.call(value) ?? value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: enabled
                        ? homeController.getPrimaryColor()
                        : textColor.withOpacity(0.3),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: enabled
                    ? homeController.getPrimaryColor()
                    : textColor.withOpacity(0.2),
                inactiveTrackColor: textColor.withOpacity(0.2),
                thumbColor: enabled
                    ? homeController.getPrimaryColor()
                    : textColor.withOpacity(0.3),
                overlayColor: enabled
                    ? homeController.getPrimaryColor().withOpacity(0.2)
                    : textColor.withOpacity(0.1),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackHeight: 4,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
