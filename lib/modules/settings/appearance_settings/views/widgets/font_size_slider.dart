import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:student_app/modules/home/controllers/home_controller.dart';
import '../../../../../core/themes/colors.dart';

class FontSizeSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onPreview;
  final bool isDarkMode;

  const FontSizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onPreview,
    required this.isDarkMode,
  });

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
        HomeController homeController = Get.find<HomeController>();

  late double _currentValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(FontSizeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.value != _currentValue) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(textColor),
        const SizedBox(height: 16),
        _buildSlider(textColor),
        const SizedBox(height: 16),
        _buildPreview(textColor),
      ],
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'حجم الخط',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: 'Tajawal',
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: homeController.getPrimaryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: homeController.getPrimaryColor().withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${_currentValue.toInt()} نقطة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: homeController.getPrimaryColor(),
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(Color textColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
        depth: widget.isDarkMode ? 2 : -2,
        intensity: 0.6,
        color: widget.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(
              Icons.text_decrease,
              color: textColor.withOpacity(0.6),
              size: 20,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: homeController.getPrimaryColor(),
                  inactiveTrackColor: textColor.withOpacity(0.2),
                  thumbColor: homeController.getPrimaryColor(),
                  overlayColor: homeController.getPrimaryColor().withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _currentValue,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                      _isDragging = true;
                    });
                    if (widget.onPreview != null) {
                      widget.onPreview!(value);
                    }
                  },
                  onChangeEnd: (value) {
                    _isDragging = false;
                    widget.onChanged(value);
                  },
                ),
              ),
            ),
            Icon(
              Icons.text_increase,
              color: textColor.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(Color textColor) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: widget.isDarkMode ? -1 : 2,
        intensity: 0.6,
        color: widget.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معاينة النص',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذا نص تجريبي لمعاينة حجم الخط المحدد',
              style: TextStyle(
                fontSize: _currentValue,
                color: textColor,
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a sample text to preview the selected font size',
              style: TextStyle(
                fontSize: _currentValue,
                color: textColor.withOpacity(0.8),
                fontFamily: 'Tajawal',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

