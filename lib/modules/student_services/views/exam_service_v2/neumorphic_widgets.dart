import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';

import '../../../../core/themes/colors.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkBackground : AppColors.lightBackground);

    final borderRadiusValue = borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: margin,
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: isDarkMode ? -2 : 2,
            intensity: 1,
            color: backgroundColor,
            boxShape: NeumorphicBoxShape.roundRect(borderRadiusValue),
          ),
          child: ClipRRect(
            borderRadius: borderRadiusValue,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final double? width;
  final double? height;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = widget.color ??
        (isDarkMode ? AppColors.darkPrimaryColor :  AppColors.primaryColor);
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final borderRadiusValue = widget.borderRadius ?? BorderRadius.circular(16);

    return Container(
      padding: widget.margin,
      color:
          Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: widget.depth,
          intensity: widget.intensity,
          color: backgroundColor,
          boxShape: NeumorphicBoxShape.roundRect(borderRadiusValue),
          shadowDarkColor: shadowDarkColor,
          shadowLightColor: shadowLightColor,
        ),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: ClipRRect(
            borderRadius: borderRadiusValue,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final int? maxLines;
  final int? minLines;

  const NeumorphicTextField({
    Key? key,
    required this.controller,
    this.hintText = '',
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkPrimaryColor :  AppColors.primaryColor);
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final borderRadiusValue = borderRadius ?? BorderRadius.circular(16);

    return Neumorphic(
      style: NeumorphicStyle(
        depth: depth,
        intensity: intensity,
        color: backgroundColor,
        boxShape: NeumorphicBoxShape.roundRect(borderRadiusValue),
        shadowDarkColor: shadowDarkColor,
        shadowLightColor: shadowLightColor,
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: padding,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
      ),
    );
  }
}

class NeumorphicRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget child;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? selectedColor;

  const NeumorphicRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.child,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkPrimaryColor :  AppColors.primaryColor);
    final accentColor = selectedColor ??
        (isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor);
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final isSelected = value == groupValue;
    final borderRadiusValue = borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadiusValue,
          boxShadow: isSelected
              ? [
                  // ظل داخلي داكن
                  BoxShadow(
                    color: shadowDarkColor.withOpacity(0.5 * intensity),
                    offset: Offset(depth / 2, depth / 2),
                    blurRadius: depth,
                    spreadRadius: 0,
                  ),
                  // ظل داخلي فاتح
                  BoxShadow(
                    color: shadowLightColor.withOpacity(0.5 * intensity),
                    offset: Offset(-depth / 2, -depth / 2),
                    blurRadius: depth,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  // ظل خارجي داكن
                  BoxShadow(
                    color: shadowDarkColor.withOpacity(0.5 * intensity),
                    offset: Offset(depth, depth),
                    blurRadius: depth * 2,
                    spreadRadius: 0,
                  ),
                  // ظل خارجي فاتح
                  BoxShadow(
                    color: shadowLightColor.withOpacity(0.5 * intensity),
                    offset: Offset(-depth, -depth),
                    blurRadius: depth * 2,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: borderRadiusValue,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              border:
                  isSelected ? Border.all(color: accentColor, width: 2) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? label;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? selectedColor;

  const NeumorphicCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkPrimaryColor : AppColors.primaryColor);
    final accentColor = selectedColor ??
        (isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor);
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final borderRadiusValue = borderRadius ?? BorderRadius.circular(8);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: margin,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadiusValue,
                boxShadow: value
                    ? [
                        // ظل داخلي داكن
                        BoxShadow(
                          color: shadowDarkColor.withOpacity(0.5 * intensity),
                          offset: Offset(depth / 2, depth / 2),
                          blurRadius: depth,
                          spreadRadius: 0,
                        ),
                        // ظل داخلي فاتح
                        BoxShadow(
                          color: shadowLightColor.withOpacity(0.5 * intensity),
                          offset: Offset(-depth / 2, -depth / 2),
                          blurRadius: depth,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        // ظل خارجي داكن
                        BoxShadow(
                          color: shadowDarkColor.withOpacity(0.5 * intensity),
                          offset: Offset(depth, depth),
                          blurRadius: depth * 2,
                          spreadRadius: 0,
                        ),
                        // ظل خارجي فاتح
                        BoxShadow(
                          color: shadowLightColor.withOpacity(0.5 * intensity),
                          offset: Offset(-depth, -depth),
                          blurRadius: depth * 2,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: accentColor,
                    )
                  : null,
            ),
            if (label != null) ...[
              SizedBox(width: 12),
              label!,
            ],
          ],
        ),
      ),
    );
  }
}

class NeumorphicDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;

  const NeumorphicDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkPrimaryColor : AppColors.primaryColor);
    final textColor =
        isDarkMode ? AppColors.darkTextColor : AppColors.textColor;
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final borderRadiusValue = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadiusValue,
        boxShadow: [
          // ظل داخلي داكن
          BoxShadow(
            color: shadowDarkColor.withOpacity(0.5 * intensity),
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
          // ظل داخلي فاتح
          BoxShadow(
            color: shadowLightColor.withOpacity(0.5 * intensity),
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: padding,
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        hint: hint != null
            ? Text(hint!, style: TextStyle(color: textColor.withOpacity(0.5)))
            : null,
        style: TextStyle(color: textColor),
        icon: Icon(Icons.arrow_drop_down, color: textColor),
        underline: SizedBox(),
        isExpanded: true,
        dropdownColor: backgroundColor,
      ),
    );
  }
}

class NeumorphicFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double size;

  const NeumorphicFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.depth = 3,
    this.intensity = 1,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.size = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final backgroundColor = color ??
        (isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor);
    final shadowDarkColor = isDarkMode
        ? AppColors.darkShadowDark.withOpacity(0.5)
        : AppColors.shadowDark.withOpacity(0.5);
    final shadowLightColor = isDarkMode
        ? AppColors.darkShadowLight.withOpacity(0.5)
        : AppColors.shadowLight.withOpacity(0.5);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            // ظل داكن
            BoxShadow(
              color: shadowDarkColor.withOpacity(0.5 * intensity),
              offset: Offset(depth, depth),
              blurRadius: depth * 2,
              spreadRadius: 0,
            ),
            // ظل فاتح
            BoxShadow(
              color: shadowLightColor.withOpacity(0.5 * intensity),
              offset: Offset(-depth, -depth),
              blurRadius: depth * 2,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class NeumorphicProgressBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final double height;
  final double depth;
  final double intensity;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? progressColor;

  const NeumorphicProgressBar({
    Key? key,
    required this.value,
    this.maxValue = 100,
    this.height = 16,
    this.depth = 3,
    this.intensity = 1,
    this.margin = const EdgeInsets.all(8),
    this.borderRadius,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final bgColor = backgroundColor ??
        (isDarkMode ? AppColors.darkPrimaryColor : AppColors.primaryColor);
    final pgColor = progressColor ??
        (isDarkMode ? AppColors.darkAccentColor : AppColors.accentColor);
    final shadowDarkColor =
        isDarkMode ? AppColors.darkShadowDark : AppColors.shadowDark;
    final shadowLightColor =
        isDarkMode ? AppColors.darkShadowLight : AppColors.shadowLight;

    final borderRadiusValue = borderRadius ?? BorderRadius.circular(height / 2);
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadiusValue,
        boxShadow: [
          // ظل داخلي داكن
          BoxShadow(
            color: shadowDarkColor.withOpacity(0.5 * intensity),
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
          // ظل داخلي فاتح
          BoxShadow(
            color: shadowLightColor.withOpacity(0.5 * intensity),
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Expanded(
              flex: (progress * 100).toInt(),
              child: Container(
                decoration: BoxDecoration(
                  color: pgColor,
                  borderRadius:
                      borderRadiusValue.subtract(BorderRadius.circular(2)),
                  boxShadow: [
                    BoxShadow(
                      color: shadowLightColor.withOpacity(0.3 * intensity),
                      offset: Offset(depth / 4, depth / 4),
                      blurRadius: depth / 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
            if (progress < 1.0)
              Expanded(
                flex: ((1 - progress) * 100).toInt(),
                child: Container(),
              ),
          ],
        ),
      ),
    );
  }
}
